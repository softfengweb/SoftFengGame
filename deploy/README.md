# 部署说明

面向运维/交付的详细文档。只想快速装起来的看仓库根目录 [README](../README.md) 即可。

本目录的镜像构建**不编译源码**：服务端用 `server/bin/linux-*/server`，管理端用 `admin/dist`，
所以构建很快（1-3 分钟），也不需要安装 Go / Node。

---

## 一、架构

```
                    ┌──────────────────────────────┐
  浏览器 / 小程序 ──▶│  nginx (容器 web, 80)         │
                    │   /admin/  → 管理端静态资源   │
                    │   /        → H5 静态资源      │
                    │   /api/    → server:8088     │
                    │   /uploads/→ server:8088     │
                    └──────────────┬───────────────┘
                                   │ compose 内网
                    ┌──────────────▼───────────────┐
                    │  server (8088, -migrate)     │
                    └───────┬──────────────┬───────┘
                    ┌───────▼──────┐ ┌─────▼───────┐
                    │ mysql:8.0    │ │ redis:7     │
                    │ 仅内网访问    │ │ 仅内网访问   │
                    └──────────────┘ └─────────────┘
```

对外只映射一个端口（默认 80），MySQL 与 Redis 不映射到宿主机。

## 二、目录

| 文件 | 作用 |
| --- | --- |
| `install.sh` | 一键安装 / 升级：生成 `.env`、建目录、构建并启动、等健康检查 |
| `docker-compose.yml` | 四个服务：mysql、redis、server、web(nginx) |
| `Dockerfile.server` | 复制预编译二进制 + 配置，安装 ffmpeg / tzdata |
| `Dockerfile.admin` | 复制 `admin/dist` 到 nginx |
| `nginx.conf` | 反代 `/api`、`/uploads`、`/payment`、`/health`，静态 `/admin/` 与 H5 |
| `.env.example` | 环境变量样例（安装脚本会生成 `.env`） |
| `init.sql` | 单文件初始化 SQL（备用，见第四节） |
| `data/uploads` | 上传文件（挂载，需备份） |
| `data/logs` | 服务端日志（挂载） |
| `data/h5` | H5 产物（挂载，只读） |

## 三、安装

```bash
cd deploy
bash install.sh
```

会依次询问：站点访问地址（必填）、授权中控地址（必填）、授权码（可留空）、HTTP 端口。
数据库/Redis/JWT 密码全部随机生成写入 `.env`（`chmod 600`），不需要手填。

批量交付用非交互模式：

```bash
PEIWAN_PUBLIC_URL=https://pw.example.com \
PEIWAN_HTTP_PORT=80 \
PEIWAN_ZK_BASE_URL=https://zk.softfeng.cn \
bash install.sh --yes
```

### 环境变量

| 变量 | 必填 | 说明 |
| --- | --- | --- |
| `PEIWAN_PUBLIC_URL` | 是 | 站点/API 域名，支付回调与授权上报都用它 |
| `PEIWAN_HTTP_PORT` | 否 | 宿主机端口，默认 80 |
| `PEIWAN_H5_URL` | 否 | H5 与后端不同域时填写 |
| `PEIWAN_CORS_ORIGINS` | 否 | H5 直连后端时的跨域白名单，逗号分隔 |
| `PEIWAN_DB_ROOT_PASSWORD` | 是 | MySQL root 密码（仅容器内使用） |
| `PEIWAN_DB_NAME` / `PEIWAN_DB_USER` / `PEIWAN_DB_PASSWORD` | 是 | 业务库与账号 |
| `PEIWAN_REDIS_PASSWORD` | 是 | Redis 密码 |
| `PEIWAN_JWT_SECRET` / `PEIWAN_JWT_ADMIN_SECRET` | 是 | 用户端与管理端 JWT 密钥，建议 `openssl rand -hex 32` |
| `PEIWAN_ZK_BASE_URL` | 是 | 授权中控地址（激活与心跳必需） |
| `PEIWAN_ZK_LICENSE_KEY` | 否 | 授权码，可装完在后台填写 |
| `PEIWAN_VERSION` | 否 | 版本号，写入二进制展示，默认取仓库根目录 `VERSION` |

改完 `.env` 后 `docker compose -f docker-compose.yml up -d` 生效（不需要重新构建）。

## 四、数据库初始化

正常部署**不需要手工导 SQL**：服务端启动命令带 `-migrate`，首次启动自动建全部表并写入
种子数据，执行记录保存在 `schema_migrations`，升级时只跑增量。

需要先给客户/DBA 一份建库脚本时，用 `init.sql`：

```bash
mysql -uroot -p < init.sql
```

导入后启动服务端，`-migrate` 会看到版本已记账而跳过，不会重复建表。
`init.sql` 与当前版本一一对应，**升级版本后请使用新版仓库里的 `init.sql`**。

## 五、升级

```bash
cd ..            # 回到仓库根目录
git pull
bash deploy/install.sh --upgrade
```

脚本会按现有 `.env` 重建镜像并重启，然后等健康检查通过。
升级前建议先备份（见第七节）。

## 六、授权

1. 授权码在管理后台「系统设置 → 授权中心」填写并激活，激活后按到期时间判定；
2. 授权与实例绑定：实例标识（`install_id`）首次启动自动生成并保存在 `zk_license` 表；
3. **换域名**：只改 `.env` 里的 `PEIWAN_PUBLIC_URL` 再 `up -d`，中控下次心跳会自动更新；
4. **换服务器**：数据库整体迁移时把 `zk_license` 表一起带走，或在后台重新填写授权码；
5. **到期/宽限期**：宽限期内业务正常；宽限期结束后只限制新增业务入口，已产生的订单与
   支付回调继续处理，不影响收款；
6. 容器化部署不支持后台「立即更新」，升级一律通过替换镜像完成（脚本已设置
   `PEIWAN_ZK_DISABLE_UPDATE=1`）。

### 授权是强制的，没有关闭开关

配置里没有 `zk.enabled` 之类的开关，改 `.env` 或改配置文件都关不掉校验（只有未注入版本号的
开发构建会跳过）。未授权时的限制规则：

| 状态 | 用户端 | 管理端 |
| --- | --- | --- |
| 未激活 / 授权无效 | 全站接口拒绝（除支付、提现回调） | 只放行登录与「授权中心」，其余拒绝 |
| 已过期（宽限期结束） | 拒绝「新下单 / 支付 / 充值 / 提现 / 送礼 / 缴保证金」，已有订单的取消、确认、退款、接单照常 | 全部放行（便于处理存量业务） |
| 正常 / 宽限期内 | 全部放行 | 全部放行 |

也就是说：不激活等于装了一个只能登录后台的壳子；填好授权码激活后立即恢复，不需要重启。

## 七、备份与恢复

```bash
# 数据库
docker exec peiwan-mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction peiwan_db' > peiwan-$(date +%F).sql
# 上传文件 + 配置
tar czf peiwan-files-$(date +%F).tar.gz data/uploads .env

# 恢复
docker exec -i peiwan-mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" peiwan_db' < peiwan-2026-11-03.sql
tar xzf peiwan-files-2026-11-03.tar.gz
```

## 八、H5 产物

1. 从授权方获取与当前版本匹配的 H5 包；
2. 解压到 `deploy/data/h5`，保证 `index.html` 在该目录根部；
3. 刷新页面即可（nginx 已做 history 路由回退）。

## 九、排错

| 现象 | 排查 |
| --- | --- |
| `服务端健康检查未通过` | `docker compose -f deploy/docker-compose.yml logs --tail=200 server` |
| 服务端反复重启 | 多半是数据库密码不一致（改过 `.env` 但 MySQL 卷里还是旧密码）或 JWT 密钥为空 |
| 后台打开 404 | 确认访问 `/admin/`（带斜杠）；检查 `web` 容器是否启动 |
| 接口 502 | `server` 未就绪，看 `docker compose ps` 与 server 日志 |
| 授权一直「未激活」 | 检查 `PEIWAN_ZK_BASE_URL` 是否可达、授权码是否有效、服务器时间是否准确 |
| 上传后图片 404 | 确认 `data/uploads` 挂载存在且权限可写（容器内以 root 运行） |

常用命令：

```bash
docker compose -f deploy/docker-compose.yml ps
docker compose -f deploy/docker-compose.yml logs -f server
docker compose -f deploy/docker-compose.yml restart server
```

## 十、安全建议

- 首次登录立即修改默认管理员密码（`admin / admin123`）；
- 只暴露 80/443，3306 与 6379 不要映射到宿主机；
- `.env` 与 `server/config/config.yaml` 权限 600，不进版本库；
- 生产使用 HTTPS，并保证 `PEIWAN_PUBLIC_URL` 与证书域名一致；
- 定期 `git pull` 升级并关注 `CHANGELOG.md`。
