# 软风游戏陪玩系统

> 商用授权软件 · 著作权归 **陇南市软风科技有限公司** 所有 · 商标 **软风 / SoftFeng**

一套面向游戏陪玩、语音社交场景的一体化系统：用户端（H5 / 小程序）+ 管理后台 + 服务端，
包含陪玩入驻审核、商品与规格、下单接单、钱包充值与提现、优惠券、礼物、评价、
即时聊天（WebSocket）、动态与相册、会员等级、邀请奖励、授权中心等模块。

**本仓库是发布仓库，只提供运行产物，不含服务端源码与前端源码。**
公开发布仅为便于已获授权的客户下载安装，使用前请先取得有效授权码，详见 [LICENSE](./LICENSE)。

---

## 一、仓库内容

| 路径 | 说明 |
| --- | --- |
| `server/bin/linux-amd64/server` | 服务端可执行程序（x86_64，静态编译，无需安装 Go） |
| `server/bin/linux-arm64/server` | 服务端可执行程序（ARM64，适配鲲鹏 / 倚天 / Apple 容器等） |
| `server/config/config.yaml` | 服务端配置模板（数据库、Redis、JWT、上传、授权等） |
| `admin/dist/` | 已构建完成的管理后台静态资源（访问路径 `/admin/`） |
| `deploy/install.sh` | 一键安装 / 升级脚本（Docker Compose） |
| `deploy/docker-compose.yml` | MySQL + Redis + 服务端 + Nginx 编排 |
| `deploy/Dockerfile.server` | 服务端镜像（直接使用预编译二进制） |
| `deploy/Dockerfile.admin` | 管理端镜像（直接使用已构建的 dist） |
| `deploy/nginx.conf` | 反向代理与静态资源配置（含 WebSocket） |
| `deploy/init.sql` | 单文件初始化 SQL（备用：给 DBA 或离线建库） |
| `deploy/.env.example` | 环境变量样例 |
| `deploy/README.md` | 更详细的部署、升级、排错说明 |
| `NOTICE.md` | 权利归属、商标与第三方开源组件声明 |
| `LICENSE` | 商用授权协议 |

**不在本仓库**：服务端 Go 源码、管理端源码、H5 / 小程序源码。
H5 产物由授权方按授权单独提供，放到 `deploy/data/h5` 即可。

---

## 二、快速开始（Docker，推荐）

### 环境要求

- Linux 服务器（x86_64 或 arm64），2 核 4G 起，建议 4 核 8G
- Docker 24+ 与 Docker Compose v2（`docker compose version` 可正常输出）
- 已解析到本机的域名（支付回调、授权激活都需要公网可访问地址）
- 放行 80 / 443 端口；**不要**对公网开放 3306、6379

### 安装

```bash
git clone https://github.com/softfengweb/SoftFengGame.git
cd SoftFengGame/deploy
bash install.sh
```

脚本会依次完成：

1. 检查 docker / compose；
2. 交互式询问站点地址、授权中控地址、授权码（可留空）、HTTP 端口；
3. 自动生成数据库、Redis、JWT 的随机密码，写入 `deploy/.env`（权限 600）；
4. 创建 `deploy/data/{uploads,logs,h5}`；
5. 构建镜像并启动 MySQL、Redis、服务端、Nginx；
6. 等待服务端 `/health` 就绪，打印访问地址与默认管理员。

安装完成后：

- 用户端 H5：`http(s)://你的域名/`（未放 H5 产物时显示占位页）
- 管理后台：`http(s)://你的域名/admin/`
- 管理员：安装时填写的用户名与密码（密码留空则自动生成并打印；留空账号则保留 `admin / admin123`）

非交互安装（适合批量交付）：

```bash
PEIWAN_PUBLIC_URL=https://pw.example.com \
PEIWAN_HTTP_PORT=80 \
bash install.sh --yes
```

### 升级

```bash
cd SoftFengGame
git pull
bash deploy/install.sh --upgrade
```

数据库结构在服务端启动时自动增量迁移（`-migrate`），已执行过的版本不会重复执行。
升级前建议备份数据库与 `deploy/data/uploads`。

---

## 三、不使用 Docker 安装

适用于已有 MySQL / Redis、或不允许使用容器的环境。

### 1. 部署程序

```bash
mkdir -p /opt/softfeng/{config,uploads,logs}
cp server/bin/linux-amd64/server /opt/softfeng/server      # arm64 机器换 linux-arm64
cp server/config/config.yaml /opt/softfeng/config/config.yaml
chmod +x /opt/softfeng/server
```

### 2. 初始化数据库

方式 A（推荐，程序自动迁移）：启动命令带上 `-migrate`，首次启动自动建表并写入种子数据。

方式 B（DBA 手工建库）：

```bash
mysql -uroot -p < deploy/init.sql     # 内含建库、全部表结构与种子数据、迁移记账
```

### 3. 修改配置

编辑 `/opt/softfeng/config/config.yaml`，至少确认：

```yaml
server:
  mode: release            # 生产必须是 release
  public_url: "https://pw.example.com"
database:
  host: 127.0.0.1
  user: peiwan_db
  password: "你的数据库密码"
  dbname: peiwan_db
redis:
  host: 127.0.0.1
  password: "你的 Redis 密码"
jwt:
  secret: "至少 32 位随机串"
  admin_secret: "另一个至少 32 位随机串"
zk:
  enabled: true
  base_url: "授权中控地址"
```

也可以用环境变量覆盖（推荐，避免密码落盘）：`PEIWAN_DB_PASSWORD`、`PEIWAN_REDIS_PASSWORD`、
`PEIWAN_JWT_SECRET`、`PEIWAN_JWT_ADMIN_SECRET`、`PEIWAN_PUBLIC_URL` 等，见 `deploy/.env.example`。

### 4. systemd 托管

```ini
# /etc/systemd/system/softfeng.service
[Unit]
Description=SoftFeng Game Companion Server
After=network.target mysql.service redis.service

[Service]
Type=simple
WorkingDirectory=/opt/softfeng
Environment=PEIWAN_DB_PASSWORD=你的数据库密码
Environment=PEIWAN_REDIS_PASSWORD=你的Redis密码
Environment=PEIWAN_JWT_SECRET=你的JWT密钥
Environment=PEIWAN_JWT_ADMIN_SECRET=你的管理端JWT密钥
ExecStart=/opt/softfeng/server -config /opt/softfeng/config/config.yaml -migrate
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload && systemctl enable --now softfeng
curl http://127.0.0.1:8088/health
```

### 5. 前置 Nginx

`deploy/nginx.conf` 可直接复用：`/admin/` 指到管理端 dist，`/api/` 与 `/uploads/` 反代到
`127.0.0.1:8088`（含 WebSocket 升级与长连接超时）。记得把 `proxy_pass` 的 `server:8088`
改成 `127.0.0.1:8088`，并把 HTTPS 证书配好。

---

## 四、放置 H5 用户端

1. 从授权方获取与当前版本匹配的 H5 产物包；
2. 解压到 `deploy/data/h5`（Docker 部署）或站点根目录（非 Docker 部署）；
3. 确认 `index.html` 位于该目录根部，刷新页面即可。

H5 与后端不同域时，需在 `.env` 里配置 `PEIWAN_CORS_ORIGINS`，并在后台「系统配置 → 站点设置」
填写 H5 地址。

---

## 五、备份与恢复

```bash
# 备份数据库
docker exec peiwan-mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction peiwan_db' > peiwan-$(date +%F).sql

# 备份上传文件与配置
tar czf peiwan-data-$(date +%F).tar.gz deploy/data/uploads deploy/.env

# 恢复
docker exec -i peiwan-mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" peiwan_db' < peiwan-2026-11-03.sql
tar xzf peiwan-data-2026-11-03.tar.gz
```

迁移服务器时，数据库中的 `zk_license` 表要一并带走，否则需要重新激活授权。

---

## 六、授权

- 授权码在管理后台「系统设置 → 授权中心」填写，激活后按到期时间判定；
- 授权与实例绑定，换服务器 / 换域名请先阅读 `deploy/README.md` 的「授权」章节；
- 授权到期后进入合同约定宽限期，宽限期结束只限制新增业务入口，已产生的订单与支付回调
  仍会正常处理，不会影响客户收款。

**授权校验是强制的，没有关闭开关**：未激活时只能登录管理后台与「授权中心」，用户端接口
全部返回未授权；填好授权码激活后立即恢复，不需要重启。已过期（宽限期结束后）只拦截新的
下单、支付、充值、提现、送礼，已有订单与收款回调照常处理。

---

## 七、安全建议

1. 安装时设置独立的管理员账号与强密码，不要把默认 `admin/admin123` 带上线；
2. 生产环境务必使用 HTTPS（Nginx / 云负载均衡均可），`server.public_url` 填 https 地址；
3. 只对公网开放 80 / 443，MySQL 与 Redis 不映射端口；
4. `.env` 与 `config.yaml` 含明文密码，权限设为 600，不要提交到任何仓库；
5. 定期升级到最新发布版本，升级前先备份。

---

## 八、支持

- 文档：`deploy/README.md`（部署细节与排错）
- 技术支持与授权：xunuowl@qq.com

© 2026 陇南市软风科技有限公司 版权所有。「软风」「SoftFeng」为本公司商标。
