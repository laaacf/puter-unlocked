# Puter Docker 部署指南

这个部署方案使用 Docker 容器化部署，**完全避免 Node.js 版本问题**。

## 为什么使用 Docker？

### 传统部署的问题
- ❌ Node.js 版本冲突（系统版本 vs NVM 版本）
- ❌ 依赖包版本不一致
- ❌ 环境配置复杂
- ❌ 难以迁移和备份

### Docker 部署的优势
- ✅ **固定 Node.js 版本**：使用 Node.js 24-alpine
- ✅ **环境隔离**：不影响系统环境
- ✅ **一键部署**：自动构建和启动
- ✅ **易于管理**：简单的命令管理服务
- ✅ **数据持久化**：配置和数据独立存储

---

## 快速开始

### 前置要求

服务器需要安装：
- Docker
- Docker Compose

**安装 Docker（如果没有）：**
```bash
curl -fsSL https://get.docker.com | sh
```

### 方式一：自动部署（推荐）

1. **上传部署文件到服务器**
   ```bash
   # 在本地，将整个 docker-deploy 目录上传到服务器
   scp -r deployment/docker-deploy your-server:~/
   ```

2. **在服务器上运行部署脚本**
   ```bash
   cd ~/docker-deploy
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **等待构建完成**
   - 第一次构建需要 5-10 分钟
   - 构建完成后自动启动

4. **访问服务**
   - http://你的服务器IP:4100

### 方式二：手动部署

1. **创建目录结构**
   ```bash
   mkdir -p ~/docker-puter/config
   mkdir -p ~/docker-puter/data
   ```

2. **复制配置文件**
   ```bash
   # 将 config.json 复制到 ~/docker-puter/config/
   # 将 docker-compose.yml 复制到 ~/docker-puter/
   ```

3. **设置权限**
   ```bash
   sudo chown -R 1000:1000 ~/docker-puter
   ```

4. **构建并启动**
   ```bash
   cd ~/docker-puter
   docker compose build
   docker compose up -d
   ```

---

## 管理命令

### 查看服务状态
```bash
cd ~/docker-puter
docker compose ps
```

### 查看日志
```bash
# 实时查看日志
docker compose logs -f

# 查看最近 100 行日志
docker compose logs --tail=100
```

### 重启服务
```bash
docker compose restart
```

### 停止服务
```bash
docker compose down
```

### 重新构建镜像
```bash
# 代码更新后，重新构建
docker compose build
docker compose up -d
```

### 更新代码后重新部署
```bash
cd ~/docker-puter
# 1. 拉取最新代码
git pull

# 2. 重新构建镜像
docker compose build

# 3. 重启服务
docker compose up -d
```

---

## 目录结构

```
~/docker-puter/
├── docker-compose.yml      # Docker Compose 配置文件
├── config/
│   └── config.json         # Puter 配置文件
├── data/                   # 数据目录（自动创建）
│   ├── puter-database.sqlite      # SQLite 数据库
│   ├── puter-ddb                  # DynamoDB 本地数据
│   └── file-cache                 # 文件缓存
└── deploy.sh               # 部署脚本
```

---

## 配置反向代理

### Nginx 配置示例

```nginx
server {
    listen 443 ssl;
    server_name puter.3868088.xyz;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:4100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
    }
}
```

### Nginx Proxy Manager

如果使用 Nginx Proxy Manager：
1. **添加新的 Proxy Host**
2. **域名**：`puter.3868088.xyz`
3. **转发地址**：`http://127.0.0.1:4100`
4. **开启 WebSocket 支持**
5. **开启 SSL**

---

## 数据备份

### 备份配置和数据
```bash
# 创建备份目录
mkdir -p ~/backups/puter-$(date +%Y%m%d)

# 复制配置和数据
cp -r ~/docker-puter/config ~/backups/puter-$(date +%Y%m%d)/
cp -r ~/docker-puter/data ~/backups/puter-$(date +%Y%m%d)/

# 打包
tar -czf ~/backups/puter-$(date +%Y%m%d).tar.gz ~/backups/puter-$(date +%Y%m%d)/
```

### 恢复数据
```bash
# 停止服务
cd ~/docker-puter
docker compose down

# 恢复数据
cp -r ~/backups/puter-20250120/config/* ~/docker-puter/config/
cp -r ~/backups/puter-20250120/data/* ~/docker-puter/data/

# 重启服务
docker compose up -d
```

---

## 常见问题

### 1. 容器启动失败
**检查日志：**
```bash
docker compose logs -f
```

**常见原因：**
- 端口 4100 被占用
- 权限问题
- 配置文件错误

### 2. 构建失败
**清理并重新构建：**
```bash
docker compose down
docker system prune -a
docker compose build --no-cache
docker compose up -d
```

### 3. 数据丢失
**确保数据目录正确挂载：**
```bash
docker compose exec puter ls -la /var/puter
```

### 4. 性能问题
**增加容器资源限制：**
在 `docker-compose.yml` 中添加：
```yaml
services:
  puter:
    deploy:
      resources:
        limits:
          memory: 1G
```

---

## 技术细节

### Docker 镜像
- **基础镜像**：node:24-alpine
- **工作目录**：/opt/puter/app
- **运行用户**：node (UID 1000)
- **暴露端口**：4100

### 持久化存储
- **配置**：`./config:/etc/puter`
- **数据**：`./data:/var/puter`

### 健康检查
```yaml
HEALTHCHECK --interval=30s --timeout=3s
    CMD wget --no-verbose --tries=1 --spider http://puter.localhost:4100/test || exit 1
```

---

## 从旧版本迁移

如果你之前使用 `npm start` 部署，迁移到 Docker：

1. **备份数据**
   ```bash
   # 旧数据位置
   cp -r ~/docker/puter-unloaded/volatile ~/backups/puter-old
   ```

2. **停止旧服务**
   ```bash
   pkill -f 'node.*run-selfhosted'
   ```

3. **使用 Docker 部署**
   ```bash
   # 按照上面的步骤部署
   ```

4. **验证迁移**
   - 检查用户数据是否完整
   - 检查文件是否可以正常访问

---

## 贡献

如果有问题或建议，请提交 Issue 或 Pull Request。
