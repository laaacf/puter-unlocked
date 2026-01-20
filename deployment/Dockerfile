# 如果需要从源代码构建自定义镜像，使用此 Dockerfile
FROM node:24-bookworm-slim

# 设置工作目录
WORKDIR /usr/src/puter

# 安装依赖
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 克隆修改后的仓库
RUN git clone https://github.com/laaacf/puter_test.git .

# 构建项目
RUN npm install
RUN npm run build

# 暴露端口
EXPOSE 4100

# 启动命令
CMD ["npm", "start"]
