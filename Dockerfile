# /!\ NOTICE /!\
# Many of the developers DO NOT USE the Dockerfile or image.
# While we do test new changes to Docker configuration, it's
# possible that future changes to the repo might break it.
# When changing this file, please try to make it as resiliant
# to such changes as possible; developers shouldn't need to
# worry about Docker unless the build/run process changes.

# ========== Build stage ==========
FROM node:24-alpine AS build

RUN apk add --no-cache git python3 make g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app

COPY . .

RUN test -f package.json && test -f package-lock.json

# 带重试的 npm ci
RUN npm cache clean --force && \
    for i in 1 2 3; do \
        npm ci && break || \
        if [ $i -lt 3 ]; then sleep 15; else exit 1; fi; \
    done

ARG PUTER_API_ORIGIN=""
ENV PUTER_API_ORIGIN=${PUTER_API_ORIGIN}

RUN cd src/puter-js && npm run build
RUN cd src/gui && npm run build

# ========== Production stage ==========
FROM node:24-alpine

LABEL repo="https://github.com/HeyPuter/puter"
LABEL license="AGPL-3.0,https://github.com/HeyPuter/puter/blob/master/LICENSE.txt"
LABEL version="1.2.46-beta-1"

# Puter 运行时用 git 查版本
RUN apk add --no-cache git

WORKDIR /opt/puter/app

# 一次性把 build 阶段整个 /app 拷过来，node_modules（含 workspace 嵌套的子包）、
# 构建产物、源码全部保留原样，避免生产阶段再跑一次冗余 npm install
COPY --from=build /app ./

# Puter 前端在 prod 模式下从 /opt/puter/app/sdk/puter.dev.js 加载 SDK
RUN mkdir -p ./sdk && cp ./src/puter-js/dist/puter.js ./sdk/puter.dev.js

RUN chown -R node:node /opt/puter/app
USER node

EXPOSE 4100

# 用首页做探针（Puter 的 /test 返回 400，不能用作 healthcheck）
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:4100/ || exit 1

CMD ["npm", "start"]
