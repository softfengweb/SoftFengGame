#!/usr/bin/env bash
# ============================================================================
# 软风游戏陪玩系统 · 一键安装 / 升级脚本（Linux + Docker Compose v2）
#
# 本仓库是发布仓库：服务端二进制与管理端静态资源都已经打包好，
# 脚本只负责生成配置、构建轻量镜像并启动容器，不会编译源码。
#
# 用法：
#   bash install.sh              # 交互式安装，逐项确认
#   bash install.sh --upgrade    # 只重建镜像并重启，不改 .env（日常升级）
#   bash install.sh --yes        # 非交互，用环境变量/默认值直接装
#
# 非交互安装可提前设置：PEIWAN_PUBLIC_URL、PEIWAN_ZK_BASE_URL、PEIWAN_ZK_LICENSE_KEY、
# PEIWAN_HTTP_PORT、PEIWAN_DB_PASSWORD、PEIWAN_REDIS_PASSWORD 等（见 .env.example）。
#
# 授权填写策略（重点）：
#   - 授权域名：不单独让用户填，直接用安装时输入的「站点访问地址」（PEIWAN_PUBLIC_URL）。
#     激活时服务端会把它上报给中控，作为该实例的域名记录；换域名改 .env 重启即可。
#   - 授权码：可选。装了机器但还没拿到授权码时不卡安装，装完登录后台
#     「系统设置 → 授权中心」填写即可；安装时填了则启动约 20 秒后自动激活。
#   - 授权校验强制开启，没有关闭开关：未激活时只放行后台登录、授权中心与
#     支付/提现回调，其余接口一律拒绝；激活后立即恢复，不需要重启。
# ============================================================================
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DEPLOY_DIR/.." && pwd)"
ENV_FILE="$DEPLOY_DIR/.env"
COMPOSE_FILE="$DEPLOY_DIR/docker-compose.yml"
DATA_DIR="$DEPLOY_DIR/data"
H5_DIR="$DATA_DIR/h5"

ASSUME_YES=0
UPGRADE_ONLY=0
for arg in "$@"; do
	case "$arg" in
		-y|--yes) ASSUME_YES=1 ;;
		--upgrade) UPGRADE_ONLY=1 ;;
		-h|--help)
			sed -n '2,26p' "$0"
			exit 0
			;;
		*)
			echo "未知参数：$arg（可用 --yes / --upgrade / --help）" >&2
			exit 1
			;;
	esac
done

log()  { printf '\033[32m[peiwan]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[peiwan]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[peiwan]\033[0m %s\n' "$*" >&2; exit 1; }

# ---------- 环境检查 ----------
command -v docker >/dev/null 2>&1 || die "未找到 docker，请先安装 Docker 24+ 与 compose v2"
docker compose version >/dev/null 2>&1 || die "未找到 docker compose（v2），请升级 Docker 或安装 compose 插件"

# 与 Dockerfile 里 TARGETARCH 的取值保持一致：x86_64 -> amd64，aarch64 -> arm64
case "$(uname -m)" in
	x86_64|amd64)  ARCH=amd64 ;;
	aarch64|arm64) ARCH=arm64 ;;
	*) die "不支持的 CPU 架构：$(uname -m)（已提供 amd64 与 arm64 版本）" ;;
esac
BIN_FILE="$ROOT_DIR/server/bin/linux-$ARCH/server"
[ -f "$BIN_FILE" ] || die "缺少服务端程序：$BIN_FILE（请完整克隆仓库，或确认架构与发布包一致）"
log "CPU 架构：$(uname -m)（使用 server/bin/linux-$ARCH/server）"

# BuildKit 才能自动注入 TARGETARCH；老版本 builder 会把 ARM 服务器装成 amd64 二进制
if [ "$ARCH" = "arm64" ]; then
	docker buildx version >/dev/null 2>&1 || die "arm64 服务器需要 Docker BuildKit（docker buildx），请升级 Docker 到 24+"
	export DOCKER_BUILDKIT=1
fi

VERSION_DEFAULT="$(tr -d ' \r\n' < "$ROOT_DIR/VERSION" 2>/dev/null || true)"
VERSION_DEFAULT="${VERSION_DEFAULT:-1.0.0}"

# 读取密码/密钥：优先环境变量，其次随机生成
rand_hex() {
	if command -v openssl >/dev/null 2>&1; then
		openssl rand -hex "$1"
	else
		head -c "$1" /dev/urandom | od -An -tx1 | tr -d ' \n'
	fi
}
pick() { # pick 变量名 默认值：环境变量优先，否则用默认值
	local var="$1" def="$2"
	local cur="${!var:-}"
	if [ -n "$cur" ]; then printf '%s' "$cur"; return; fi
	printf '%s' "$def"
}

# 等后端健康：失败时给出可直接执行的排查命令
wait_healthy() {
	log "等待服务端就绪（首次启动会自动建表，可能需要 1-2 分钟）…"
	local ready=0
	for _ in $(seq 1 90); do
		if docker exec peiwan-server wget -qO- http://127.0.0.1:8088/health >/dev/null 2>&1; then
			ready=1
			break
		fi
		sleep 2
	done
	if [ "$ready" != "1" ]; then
		warn "服务端健康检查未通过，请查看日志定位："
		warn "  docker compose -f $COMPOSE_FILE logs --tail=200 server"
		exit 1
	fi
	log "服务端已就绪"
}

# ---------- 升级模式：只重建 ----------
if [ "$UPGRADE_ONLY" = "1" ]; then
	[ -f "$ENV_FILE" ] || die "缺少 $ENV_FILE，升级前请先完成一次安装"
	log "升级：按当前 .env 重建镜像并重启（配置不变）"
	docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --build
	docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
	wait_healthy
	log "升级完成。数据库结构已在启动时自动迁移。"
	exit 0
fi

# ---------- 已有 .env：确认是覆盖还是复用 ----------
REUSE_ENV=0
if [ -f "$ENV_FILE" ]; then
	warn "检测到已存在的 $ENV_FILE"
	if [ "$ASSUME_YES" = "1" ]; then
		REUSE_ENV=1
		log "非交互模式：沿用现有 .env，仅重建容器"
	else
		read -r -p "沿用现有配置只重启？[Y/n] " ans
		case "${ans:-Y}" in
			[yY]*) REUSE_ENV=1 ;;
			*) warn "将重新生成配置（原文件备份为 .env.bak）" ;;
		esac
	fi
fi

if [ "$REUSE_ENV" = "1" ]; then
	docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --build
	docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
	wait_healthy
	log "已按现有配置启动。"
	exit 0
fi

# ---------- 交互收集 ----------
ask() { # ask 提示 默认值 变量名
	local prompt="$1" def="$2" var="$3" val=""
	if [ "$ASSUME_YES" = "1" ]; then
		printf -v "$var" '%s' "$def"
		return
	fi
	if [ -n "$def" ]; then
		read -r -p "$prompt [$def]: " val
		printf -v "$var" '%s' "${val:-$def}"
	else
		read -r -p "$prompt: " val
		printf -v "$var" '%s' "$val"
	fi
}

PUBLIC_URL="${PEIWAN_PUBLIC_URL:-}"
if [ -z "$PUBLIC_URL" ]; then
	ask "站点访问地址（必填，如 https://pw.example.com，不要带结尾斜杠）" "" PUBLIC_URL
fi
[ -n "$PUBLIC_URL" ] || die "站点访问地址不能为空"
case "$PUBLIC_URL" in
	http://*|https://*) ;;
	*) die "站点访问地址必须以 http:// 或 https:// 开头" ;;
esac
PUBLIC_URL="${PUBLIC_URL%/}"

ZK_BASE_URL="${PEIWAN_ZK_BASE_URL:-}"
if [ -z "$ZK_BASE_URL" ] && [ "$ASSUME_YES" != "1" ]; then
	ask "授权中控地址（必填：授权在此激活，改了也关不掉校验）" "https://zk.softfeng.cn" ZK_BASE_URL
	if [ "$ZK_BASE_URL" = "https://zk.softfeng.cn" ]; then
		warn "使用官方中控地址，正式交付请确认该域名可访问"
	fi
fi
ZK_BASE_URL="${ZK_BASE_URL%/}"
# 授权校验强制开启且无法关闭：没有中控地址就激活不了，装完只会得到一个被限制的站点
[ -n "$ZK_BASE_URL" ] || die "授权中控地址不能为空（可先用 https://zk.softfeng.cn 占位，装完在 .env 里改）"

LICENSE_KEY="${PEIWAN_ZK_LICENSE_KEY:-}"
if [ -z "$LICENSE_KEY" ] && [ "$ASSUME_YES" != "1" ]; then
	echo "授权码可以现在填，也可以装完登录后台「系统设置 → 授权中心」再填（未激活时只能进后台与授权中心）。"
	ask "授权码（可留空）" "" LICENSE_KEY
fi
LICENSE_KEY="$(printf '%s' "$LICENSE_KEY" | tr '[:lower:]' '[:upper:]')"

ADMIN_USER="${PEIWAN_INIT_ADMIN_USERNAME:-}"
if [ -z "$ADMIN_USER" ]; then
	ask "管理员用户名" "admin" ADMIN_USER
fi
case "$ADMIN_USER" in
	''|*[!A-Za-z0-9_.-]*) die "管理员用户名只能包含字母、数字、下划线、短横线与点：$ADMIN_USER" ;;
esac

ADMIN_PASS="${PEIWAN_INIT_ADMIN_PASSWORD:-}"
ADMIN_PASS_GENERATED=0
if [ -z "$ADMIN_PASS" ] && [ "$ASSUME_YES" != "1" ]; then
	echo "管理员密码至少 8 位；直接回车则自动生成随机密码。"
	read -r -s -p "管理员密码: " p1; echo
	if [ -n "$p1" ]; then
		read -r -s -p "再输入一次: " p2; echo
		[ "$p1" = "$p2" ] || die "两次输入不一致"
		ADMIN_PASS="$p1"
	fi
fi
if [ -z "$ADMIN_PASS" ]; then
	ADMIN_PASS="$(rand_hex 8)"
	ADMIN_PASS_GENERATED=1
fi
[ "${#ADMIN_PASS}" -ge 8 ] || die "管理员密码至少 8 位"

HTTP_PORT="${PEIWAN_HTTP_PORT:-}"
if [ -z "$HTTP_PORT" ]; then
	ask "宿主机 HTTP 端口" "80" HTTP_PORT
fi
case "$HTTP_PORT" in
	''|*[!0-9]*) die "HTTP 端口必须是数字：$HTTP_PORT" ;;
esac

# 密码：环境变量优先，否则自动生成（避免默认弱密码）
DB_ROOT_PASSWORD="$(pick PEIWAN_DB_ROOT_PASSWORD "$(rand_hex 16)")"
DB_NAME="$(pick PEIWAN_DB_NAME "peiwan_db")"
DB_USER="$(pick PEIWAN_DB_USER "peiwan_db")"
DB_PASSWORD="$(pick PEIWAN_DB_PASSWORD "$(rand_hex 16)")"
REDIS_PASSWORD="$(pick PEIWAN_REDIS_PASSWORD "$(rand_hex 16)")"
JWT_SECRET="$(pick PEIWAN_JWT_SECRET "$(rand_hex 32)")"
JWT_ADMIN_SECRET="$(pick PEIWAN_JWT_ADMIN_SECRET "$(rand_hex 32)")"
VERSION="${PEIWAN_VERSION:-$VERSION_DEFAULT}"

# 库名会拼进 compose 与 CREATE DATABASE，限制字符集避免意外
case "$DB_NAME" in
	*[!A-Za-z0-9_]*) die "数据库名只能包含字母、数字与下划线：$DB_NAME" ;;
esac

if [ "$ASSUME_YES" != "1" ]; then
	echo
	echo "---------- 即将安装 ----------"
	echo "站点地址   : $PUBLIC_URL"
	echo "管理端     : $PUBLIC_URL/admin/"
	echo "HTTP 端口  : $HTTP_PORT"
	echo "版本       : $VERSION"
	echo "授权中控   : $ZK_BASE_URL（授权校验强制开启）"
	echo "授权码     : ${LICENSE_KEY:-（留空，装完后在后台填写）}"
	echo "管理员     : $ADMIN_USER"
	echo "数据库     : $DB_NAME / $DB_USER（密码自动生成）"
	echo "------------------------------"
	read -r -p "确认开始？[Y/n] " ok
	case "${ok:-Y}" in
		[yY]*) ;;
		*) die "已取消" ;;
	esac
fi

# ---------- 写 .env ----------
[ -f "$ENV_FILE" ] && cp -f "$ENV_FILE" "$ENV_FILE.bak"
umask 077
cat > "$ENV_FILE" <<EOF
# 由 deploy/install.sh 于 $(date '+%Y-%m-%d %H:%M:%S') 生成，含明文密码，请勿提交版本库
PEIWAN_PUBLIC_URL=$PUBLIC_URL
PEIWAN_H5_URL=${PEIWAN_H5_URL:-}
PEIWAN_CORS_ORIGINS=${PEIWAN_CORS_ORIGINS:-}
PEIWAN_HTTP_PORT=$HTTP_PORT
PEIWAN_VERSION=$VERSION

PEIWAN_DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
PEIWAN_DB_NAME=$DB_NAME
PEIWAN_DB_USER=$DB_USER
PEIWAN_DB_PASSWORD=$DB_PASSWORD

PEIWAN_REDIS_PASSWORD=$REDIS_PASSWORD

PEIWAN_JWT_SECRET=$JWT_SECRET
PEIWAN_JWT_ADMIN_SECRET=$JWT_ADMIN_SECRET

# 只在数据库还是出厂默认密码时生效；客户改过密码后这两行不再起作用
PEIWAN_INIT_ADMIN_USERNAME=$ADMIN_USER
PEIWAN_INIT_ADMIN_PASSWORD=$ADMIN_PASS

PEIWAN_ZK_BASE_URL=$ZK_BASE_URL
PEIWAN_ZK_LICENSE_KEY=$LICENSE_KEY
PEIWAN_ZK_PRODUCT=${PEIWAN_ZK_PRODUCT:-peiwan}
EOF
chmod 600 "$ENV_FILE"
log "已生成 $ENV_FILE"

# ---------- 目录 ----------
mkdir -p "$DATA_DIR/uploads" "$DATA_DIR/logs" "$H5_DIR"
if [ -z "$(ls -A "$H5_DIR" 2>/dev/null)" ]; then
	cat > "$H5_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="zh-CN">
<head><meta charset="utf-8"><title>软风游戏陪玩系统</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>body{font-family:system-ui,-apple-system,"Microsoft YaHei",sans-serif;background:#f7f8fa;color:#1d2129;display:flex;align-items:center;justify-content:center;height:100vh;margin:0}
.card{background:#fff;padding:40px 48px;border-radius:16px;box-shadow:0 10px 40px rgba(0,0,0,.08);text-align:center}
h1{font-size:22px;margin:0 0 12px}p{color:#86909c;font-size:14px;margin:6px 0}a{color:#165dff;text-decoration:none}</style>
</head>
<body><div class="card"><h1>软风游戏陪玩系统</h1>
<p>后端已启动，管理端入口：<a href="/admin/">/admin/</a></p>
<p>H5 产物请放到 deploy/data/h5 后刷新本页</p></div></body></html>
HTML
	log "已写入 H5 占位页（正式 H5 请把授权方提供的产物拷到 $H5_DIR）"
fi

# ---------- 启动 ----------
# 先校验一次变量插值，缺项/写法错误能在构建前就暴露，不用等 10 分钟构建完才报错
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" config --quiet \
	|| die "compose 配置校验失败，请检查 $ENV_FILE"

log "开始构建并启动容器（首次构建约 1-3 分钟）"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --build

wait_healthy

docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps

cat <<EOF

============================================================
安装完成（版本 $VERSION）

  用户端 H5 : $PUBLIC_URL/
  管理端    : $PUBLIC_URL/admin/
  管理员    : $ADMIN_USER / $ADMIN_PASS   ← 登录后可在后台修改
  上传目录  : $DATA_DIR/uploads
  日志      : $DATA_DIR/logs

授权（强制校验，关不掉）：
  1) 已在安装时填写授权码：容器启动约 20 秒后自动激活，
     登录后台「系统设置 → 授权中心」确认状态为「正版授权」。
  2) 未填授权码：此时站点只能登录后台与授权中心，填好授权码激活后自动恢复。
  3) 授权域名不用单独填：中控记录的就是上面的站点地址，
     换域名后改 $ENV_FILE 里的 PEIWAN_PUBLIC_URL 再
     docker compose -f $COMPOSE_FILE up -d 即可。

常用命令：
  查看状态  docker compose -f $COMPOSE_FILE ps
  查看日志  docker compose -f $COMPOSE_FILE logs -f server
  升级      bash $DEPLOY_DIR/install.sh --upgrade
  备份      mysqldump 导出数据 + 打包 $DATA_DIR
============================================================
EOF
