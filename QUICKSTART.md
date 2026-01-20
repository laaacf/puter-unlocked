# 🚀 Puter 快速部署指南

## ⚡ 超级简单（3 步完成）

### 在你的服务器上运行：

```bash
# 1️⃣ 克隆仓库
git clone https://github.com/laaacf/puter-unlocked.git
cd puter-unlocked

# 2️⃣ 运行部署脚本
chmod +x deploy.sh
./deploy.sh

# 3️⃣ 完成！访问你的服务器
# http://你的服务器IP:4100
```

**就这么简单！** 🎉

---

## 📦 已包含的功能

- ✅ **反向代理支持** - 可以用 Nginx 等反向代理
- ✅ **任意域名访问** - 不限制访问域名
- ✅ **IP 直接访问** - 支持直接用 IP 访问
- ✅ **自动配置** - 无需手动修改参数
- ✅ **一键部署** - 自动构建和启动

---

## 🎯 适用场景

✅ **个人云服务器** - 搭建自己的私有云
✅ **内网文件共享** - 局域网内文件共享
✅ **反向代理部署** - 域名访问
✅ **多域名支持** - 一个实例多个域名

---

## 📂 项目文件说明

| 文件 | 说明 |
|------|------|
| `deploy.sh` | 一键部署脚本（核心文件）|
| `config.prod.json` | 通用配置文件 |
| `docker-compose.prod.yml` | Docker Compose 配置 |
| `README.md` | 项目说明 |
| `DEPLOYMENT.md` | 详细部署文档 |

---

## 🛠️ 常用命令

```bash
# 查看状态
docker compose ps

# 查看日志
docker compose logs -f puter

# 重启服务
docker compose restart

# 停止服务
docker compose stop

# 启动服务
docker compose start
```

---

## 🌐 访问方式

部署成功后，可以通过以下方式访问：

- 本地：`http://localhost:4100`
- IP：`http://服务器IP:4100`
- 域名：`http://your-domain.com`
- 反向代理：通过 Nginx 等访问

---

## 🔧 高级配置

### 使用 Portainer

1. 在 Portainer 中创建 Stack
2. 使用 `docker-compose.prod.yml` 配置
3. 修改 volumes 路径为实际路径
4. 部署

详见 [DEPLOYMENT.md](DEPLOYMENT.md)

---

## ❓ 常见问题

### Q: 部署需要多久？
A: 首次构建镜像需要 10-15 分钟，后续启动秒级。

### Q: 占用多少资源？
A: 容器约占用 500MB-1GB 内存，视使用情况而定。

### Q: 数据安全吗？
A: 所有数据存储在本地 `data/` 目录，建议定期备份。

### Q: 支持多用户吗？
A: 支持，可以注册多个用户账号。

### Q: 可以升级吗？
A: 可以，运行 `git pull` 更新代码，然后 `docker compose build` 重新构建。

---

## 📞 需要帮助？

- 📖 查看详细文档：[DEPLOYMENT.md](DEPLOYMENT.md)
- 🐛 提交问题：[GitHub Issues](https://github.com/laaacf/puter-unlocked/issues)
- 📚 原项目文档：[HeyPuter/puter](https://github.com/HeyPuter/puter)

---

## ⭐ 版本信息

- **版本**: v1.0
- **基于**: HeyPuter/puter
- **修改日期**: 2025-01-20
- **主要特性**: 反向代理支持、灵活域名访问

---

**开始使用你的私人云系统吧！** 🎉
