# Puter Docker Compose 部署

极简的一键部署方案。首次启动自动生成所有必需的配置和密钥，不用手写 config.json。

## 快速开始

```bash
# 1. 进入 docker 目录
cd docker

# 2. 创建 .env 文件（按需修改里面的域名/端口）
cp .env.example .env

# 3. 启动（首次会自动构建镜像，耗时 3-5 分钟）
docker compose up -d

# 4. 查看启动日志，等到看见 "Puter is now live at..."
docker compose logs -f

# 5. 获取管理员密码
docker compose logs | grep "Password:"
```

然后浏览器打开 http://localhost:4100，用 `admin` + 日志里的密码登录。

## 目录结构

```
docker/
├── docker-compose.yml    # Compose 定义，通常不需要改
├── .env.example          # 配置模板
├── .env                  # 你的实际配置（gitignore）
├── entrypoint.sh         # 首次启动生成 config.json
└── data/                 # 数据目录（自动创建）
    ├── config/           # 配置文件（config.json 在这里）
    └── runtime/          # 运行数据：SQLite、文件缓存、日志、用户文件
```

## 常见配置

改 `.env` 里的这几项就能覆盖大多数场景：

| 变量 | 默认 | 说明 |
|------|------|------|
| `PUTER_HTTP_PORT` | 4100 | 端口。改了之后浏览器地址也要改 |
| `PUTER_DOMAIN` | puter.localhost | 访问域名。局域网填 IP，公网填域名 |
| `PUTER_PROTOCOL` | http | 走 HTTPS 反代时改成 https |
| `TZ` | Asia/Shanghai | 时区 |

修改 `.env` 后执行 `docker compose up -d` 让改动生效。

注意：**改域名或协议后，已生成的 `data/config/config.json` 不会被覆盖**。如需重新生成，先删掉该文件再重启。

## 管理命令

```bash
# 查看状态
docker compose ps

# 查看日志（实时）
docker compose logs -f puter

# 重启
docker compose restart

# 停止（保留数据）
docker compose down

# 停止并删除所有数据（慎用）
docker compose down
rm -rf data

# 重新构建（改了项目源码后）
docker compose up -d --build

# 进入容器
docker compose exec puter sh
```

## 数据备份

```bash
# 备份整个 data 目录
tar -czf puter-backup-$(date +%Y%m%d).tar.gz data/

# 只备份数据库
cp data/runtime/puter-database.sqlite backup/

# 恢复：停止服务后把备份解压回 data/
docker compose down
tar -xzf puter-backup-20260512.tar.gz
docker compose up -d
```

## 走 HTTPS 反向代理

推荐前面放一个 Caddy / Nginx Proxy Manager。示例 Caddyfile：

```
puter.example.com {
    reverse_proxy localhost:4100
}
```

同时 `.env` 里改：
```
PUTER_DOMAIN=puter.example.com
PUTER_PROTOCOL=https
```

删掉旧的 `data/config/config.json` 再启动，这样新配置才会被生成。

## 排障

**容器启动失败**：先看日志
```bash
docker compose logs puter | tail -100
```

**界面图标大小混乱、布局错乱**：镜像构建时 GUI 资源没打好，重建镜像
```bash
docker compose up -d --build --force-recreate
```

**改了 `.env` 不生效**：记住 `.env` 只影响**首次**生成 config.json。已有配置需要手动改 `data/config/config.json` 或删掉让它重新生成。

**端口被占用**：改 `.env` 里的 `PUTER_HTTP_PORT`。

**Linux 下 `EACCES: permission denied`**：容器里以 UID 1000 运行，但 docker 创建的 `./data/` 目录属主是 root。首次启动前执行：
```bash
mkdir -p data/config data/runtime
sudo chown -R 1000:1000 data
```
macOS / Windows Docker Desktop 通常不需要这一步。

## 与旧方案的区别

仓库里 `deployment/` 下已有几份 compose 文件，但有这些问题：
- 需要手写完整的 `config.json`（要记得加 jwt_secret、services、protocol 等）
- 路径写死在 yaml 里（比如 `/home/laaa/...`）
- 没有 `.env` 参数化

本方案通过 `entrypoint.sh` 在首次启动时自动生成完整配置，用户只需要改 `.env`。
