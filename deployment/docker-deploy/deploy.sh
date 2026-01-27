#!/bin/bash
# Puter Docker 部署脚本
# 在服务器上运行此脚本，自动完成 Docker 部署

set -e  # 遇到错误立即退出

echo "======================================"
echo "  Puter Docker 部署脚本"
echo "======================================"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误：Docker 未安装"
    echo ""
    echo "请先安装 Docker："
    echo "  curl -fsSL https://get.docker.com | sh"
    echo ""
    exit 1
fi

if ! command -v docker compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ 错误：Docker Compose 未安装"
    echo ""
    echo "请先安装 Docker Compose"
    echo ""
    exit 1
fi

echo "✓ Docker 环境检查通过"
echo ""

# 1. 创建目录结构
echo "📁 创建目录结构..."
mkdir -p ~/docker-puter/config
mkdir -p ~/docker-puter/data
echo "  ✓ 目录创建完成"
echo ""

# 2. 停止并删除旧容器（如果存在）
echo "🧹 清理旧容器..."
if docker ps -a | grep -q puter; then
    docker stop puter 2>/dev/null || true
    docker rm puter 2>/dev/null || true
    echo "  ✓ 旧容器已清理"
else
    echo "  ⚠ 没有旧容器需要清理"
fi
echo ""

# 3. 复制文件到目标目录
echo "📋 复制配置文件..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/config.json" ~/docker-puter/config/config.json
cp "$SCRIPT_DIR/docker-compose.yml" ~/docker-puter/docker-compose.yml
echo "  ✓ 配置文件复制完成"
echo ""

# 4. 设置权限
echo "🔐 设置目录权限..."
sudo chown -R 1000:1000 ~/docker-puter
echo "  ✓ 权限设置完成"
echo ""

# 5. 构建并启动容器
echo "🚀 开始构建并启动容器..."
cd ~/docker-puter

echo "  → 构建镜像（这可能需要几分钟）..."
docker compose build

echo "  → 启动容器..."
docker compose up -d

echo ""
echo "======================================"
echo "  部署完成！"
echo "======================================"
echo ""
echo "访问地址："
echo "  - http://localhost:4100"
echo "  - http://你的服务器IP:4100"
echo ""
echo "管理命令："
echo "  - 查看日志：docker compose logs -f"
echo "  - 停止服务：docker compose down"
echo "  - 重启服务：docker compose restart"
echo "  - 查看状态：docker compose ps"
echo ""
echo "数据位置："
echo "  - 配置：~/docker-puter/config"
echo "  - 数据：~/docker-puter/data"
echo ""
