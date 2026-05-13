#!/bin/sh
# Puter Docker 容器启动脚本
# 功能：首次启动自动生成包含随机密钥的 config.json

set -e

CONFIG_DIR="${CONFIG_PATH:-/etc/puter}"
RUNTIME_DIR="${RUNTIME_PATH:-/var/puter}"
CONFIG_FILE="${CONFIG_DIR}/config.json"

mkdir -p "${CONFIG_DIR}" "${RUNTIME_DIR}"

if [ ! -f "${CONFIG_FILE}" ]; then
    echo "[puter-entrypoint] 未发现 config.json，正在生成: ${CONFIG_FILE}"

    # 用 Node 的 crypto 生成所有必需的密钥，避免再踩 jwt_secret 等坑
    node -e "
        const crypto = require('crypto');
        const fs = require('fs');

        const env = process.env;
        const config = {
            config_name: 'puter-docker',
            env: env.PUTER_ENV || 'production',
            protocol: env.PUTER_PROTOCOL || 'http',
            domain: env.PUTER_DOMAIN || 'puter.localhost',
            http_port: parseInt(env.PUTER_HTTP_PORT || '4100', 10),
            server_id: 'docker',
            contact_email: env.PUTER_CONTACT_EMAIL || 'admin@example.com',

            // 认证相关密钥（容器销毁后也保留在挂载卷中）
            jwt_secret: crypto.randomUUID(),
            cookie_name: crypto.randomUUID(),
            url_signature_secret: crypto.randomUUID(),
            private_uid_secret: crypto.randomBytes(24).toString('hex'),
            private_uid_namespace: crypto.randomUUID(),

            // 部署兼容性选项
            allow_all_host_values: true,
            allow_nipio_domains: true,
            disable_ip_validate_event: true,
            custom_domains_enabled: true,
            experimental_no_subdomain: true,

            // 服务策略（不写会导致 data 扩展加载失败）
            services: {
                database: {
                    engine: 'sqlite',
                    path: '/var/puter/puter-database.sqlite',
                },
                dynamo: {
                    path: '/var/puter/puter-ddb',
                },
                thumbnails: {
                    engine: 'purejs',
                },
                'file-cache': {
                    disk_limit: 16384,
                    disk_max_size: 16384,
                    precache_size: 16384,
                    path: '/var/puter/file-cache',
                },
            },
        };

        fs.writeFileSync('${CONFIG_FILE}', JSON.stringify(config, null, 4) + '\n');
        console.log('[puter-entrypoint] config.json 已生成');
    "
else
    echo "[puter-entrypoint] 使用已存在的配置: ${CONFIG_FILE}"
fi

# 交给后续命令（默认 npm start）
exec "$@"
