# Puter Docker 完整部署指南

本目录包含完整的 Docker 部署方案，支持在服务器上手动构建镜像。

## 📦 方案特点

- ✅ 使用项目 Dockerfile 构建自定义镜像
- ✅ 包含所有源代码修改（支持反向代理）
- ✅ 可使用 Portainer 或命令行部署
- ✅ 一键部署脚本

---

## 🚀 方式 1：命令行部署（推荐）

### 在服务器上执行：

```bash
# 1. 克隆仓库
git clone https://github.com/laaacf/puter-unlocked.git ~/docker/puter
cd ~/docker/puter

# 2. 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

部署脚本会自动：
- 检查 Docker 环境
- 创建目录结构
- 生成配置文件
- 构建 Docker 镜像
- 启动容器

---

## 🎨 方式 2：Portainer 部署

### 步骤 1：克隆仓库到服务器

```bash
git clone https://github.com/laaacf/puter-unlocked.git ~/docker/puter
cd ~/docker/puter

# 创建目录和配置
mkdir -p config data
sudo chown -R 1000:1000 config data
```

### 步骤 2：创建配置文件

将以下内容保存到 `config/config.json`：

```json
{
    "env": "production",
    "http_port": 4100,
    "domain": "puter.localhost",
    "protocol": "http",
    "contact_email": "your-email@example.com",
    "allow_all_host_values": true,
    "allow_nipio_domains": true,
    "disable_ip_validate_event": true,
    "custom_domains_enabled": true,
    "experimental_no_subdomain": true,
    "services": {
        "database": {
            "engine": "sqlite",
            "path": "/var/puter/puter-database.sqlite"
        },
        "dynamo": {
            "path": "/var/puter/puter-ddb"
        },
        "thumbnails": {
            "engine": "purejs"
        },
        "file-cache": {
            "disk_limit": 16384,
            "disk_max_size": 16384,
            "precache_size": 16384,
            "path": "/var/puter/file-cache"
        }
    }
}
```

### 步骤 3：在 Portainer 中创建 Stack

1. 打开 Portainer
2. 点击 **Stacks** → **Add stack**
3. 粘贴以下配置：

```yaml
---
version: "3.8"
services:
  puter:
    container_name: puter
    build:
      context: /home/laaa/docker/puter
      dockerfile: Dockerfile
    image: puter-custom:latest
    restart: unless-stopped
    ports:
      - '4100:4100'
    environment:
      TZ: Asia/Shanghai
      PUID: 1000
      PGID: 1000
    volumes:
      - /home/laaa/docker/puter/config:/etc/puter
      - /home/laaa/docker/puter/data:/var/puter
    healthcheck:
      test: wget --no-verbose --tries=1 --spider http://127.0.0.1:4100/test || exit 1
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 30s
```

4. **重要**：修改路径为你的实际路径
5. 点击 **Deploy the stack**

### 步骤 4：查看构建日志

在 Portainer 中：
1. 点击容器名称 `puter`
2. 查看 **Console** 输出
3. 或点击 **Logs** 查看详细日志

---

## 📝 配置说明

### 关键配置项

| 配置项 | 说明 |
|--------|------|
| `allow_all_host_values` | 允许任意域名访问 |
| `experimental_no_subdomain` | API 使用同一域名 |
| `disable_ip_validate_event` | 允许 IP 直接访问 |
| `custom_domains_enabled` | 允许自定义域名 |

### 数据持久化

- `./config` - 配置文件目录
- `./data` - 数据文件目录
- SQLite 数据库在 `data/puter-database.sqlite`

---

## 🛠️ 管理命令

### 命令行管理

```bash
cd ~/docker/puter

# 查看状态
sudo docker compose ps

# 查看日志
sudo docker compose logs -f puter

# 重启
sudo docker compose restart

# 停止
sudo docker compose stop

# 启动
sudo docker compose start

# 删除容器（保留数据）
sudo docker compose down

# 完全删除（包括数据）
sudo docker compose down -v
sudo rm -rf data
```

### Portainer 管理

在 Portainer 界面中：
- **Containers** - 查看和管理容器
- **Logs** - 查看日志
- **Console** - 连接到容器终端
- **Restart/Stop/Start** - 管理容器状态

---

## 🌐 访问方式

部署成功后，可以通过以下方式访问：

- **本地**: `http://localhost:4100`
- **IP 地址**: `http://服务器IP:4100`
- **域名**: `http://your-domain.com`（需要配置 DNS）
- **反向代理**: 通过 Nginx 等反向代理访问

---

## 🔧 故障排除

### 问题 1：构建失败

```bash
# 查看构建日志
sudo docker compose build --no-cache

# 或单独构建镜像
sudo docker build -t puter-custom:latest .
```

### 问题 2：容器无法启动

```bash
# 查看详细日志
sudo docker compose logs puter

# 检查配置文件
cat config/config.json

# 检查目录权限
ls -la config data
```

### 问题 3：无法访问

```bash
# 检查容器是否运行
sudo docker ps | grep puter

# 检查端口是否开放
sudo netstat -tulpn | grep 4100

# 测试本地访问
curl http://localhost:4100
```

---

## 📊 性能优化

### 镜像构建优化

```bash
# 使用构建缓存
sudo docker compose build

# 清理未使用的镜像
sudo docker image prune -a
```

### 资源限制

在 `docker-compose.yml` 中添加：

```yaml
services:
  puter:
    # ... 其他配置
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          memory: 512M
```

---

## 🔒 安全建议

1. **修改默认密码**
   - 首次登录后立即修改管理员密码

2. **配置防火墙**
   ```bash
   sudo ufw allow 4100/tcp
   ```

3. **使用 HTTPS**
   - 配置反向代理（Nginx + Let's Encrypt）
   - 或使用 Cloudflare

4. **定期备份**
   ```bash
   # 备份数据目录
   sudo tar -czf puter-backup-$(date +%Y%m%d).tar.gz ~/docker/puter/data
   ```

---

## 📚 相关链接

- 原项目：https://github.com/HeyPuter/puter
- 修改版本：https://github.com/laaacf/puter-unlocked
- Portainer 文档：https://docs.portainer.io/

---

## ✨ 功能特性

- ✅ 支持反向代理
- ✅ 支持任意域名访问
- ✅ 支持 IP 直接访问
- ✅ API 和 GUI 使用同一域名
- ✅ 完整的源代码修改

---

## 🎉 开始部署

选择你喜欢的方式开始部署吧！

推荐：使用命令行部署脚本 `./deploy.sh`，一键完成所有步骤！
