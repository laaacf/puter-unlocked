#!/bin/bash
set -e

echo "=== Puter 一键部署脚本 ==="

# 1. 确保使用正确的 Node.js 版本
export PATH="/usr/bin:$PATH"
echo "Node.js 版本: $(node --version)"

# 2. 安装依赖
echo "=== 安装依赖 ==="
npm install

# 3. 编译后端 TypeScript
echo "=== 编译后端 ==="
npm run build:ts

# 4. 重新编译原生模块（如果需要）
echo "=== 重新编译原生模块 ==="
npm rebuild better-sqlite3

# 5. **构建前端 GUI（关键步骤！）**
echo "=== 构建前端 GUI ==="
cd src/gui
node ./build.js
cd ../..

# 6. 设置权限
echo "=== 设置权限 ==="
mkdir -p volatile/runtime
chmod 777 volatile/runtime

# 7. 重启服务
echo "=== 重启服务 ==="
pkill -f 'node.*run-selfhosted' || true
sleep 2
nohup node ./tools/run-selfhosted.js > /tmp/puter.log 2>&1 &

# 8. 等待服务启动
echo "=== 等待服务启动 ==="
sleep 5

# 9. 检查服务状态
echo "=== 检查服务状态 ==="
tail -10 /tmp/puter.log | grep -E "(Puter is now live|ERROR)" || echo "服务可能还在启动中，请检查日志: tail -f /tmp/puter.log"

echo "=== 部署完成 ==="
echo "访问地址: http://localhost:4100"
