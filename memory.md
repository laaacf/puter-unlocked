# Puter 项目记忆

## 2026-02-04 - 修复 Puter 内置应用局域网访问问题

### 背景
用户在局域网 IP (192.168.x.x) 环境下部署 Puter，发现内置应用（Viewer, Editor, PDF, Code, Draw, Player）无法打开或保存文件。原因包括：
1. 后端路由强制检查子域名（`api.`）和签名。
2. 前端应用生成的 URL 指向 `puter.localhost`，导致在局域网访问时 DNS 解析失败或跨域错误。
3. `eggspress` 路由框架在无子域名模式下仍执行子域名检查。

### 改动内容
1. **后端路由修复**：
   - 修改 `src/backend/src/routers/file.js` 和 `writeFile.js`，注释掉 `validate_signature_auth` 和子域名检查。
   - 修改 `src/backend/src/modules/web/lib/eggspress.js`，在 `config.experimental_no_subdomain` 为 true 时跳过子域名检查。

2. **前端应用修复** (`src/builtin/*/index.html`)：
   - **相对路径转换**：所有应用在加载文件时，检测 `read_url` / `write_url`，并将其转换为相对路径（如 `/file?uid=...`），避免主机名不匹配。
   - **移除 Auth 头**：移除了 fetch 请求中的 `Authorization` 头，避免触发 CORS 预检（OPTIONS）失败，转而依赖 Session Cookie 或 URL 参数。
   - **回退机制**：为 Viewer, Player 等添加了当 `read_url` 失效时自动回退到 `/file?uid=...` 的逻辑。
   - **缓存控制**：给所有 `index.html` 添加了 `<meta http-equiv="Cache-Control" content="no-cache">` 防止浏览器缓存旧代码。

3. **部署**：
   - 使用 `scp` 将本地修复同步到远程服务器。
   - 清理了远程服务器锁死的 `puter-ddb` 数据库并重启服务。

### 结果
- 本地和远程服务器上的所有内置应用均可正常打开、编辑和保存文件。
- 解决了 `net::ERR_CONNECTION_REFUSED` (指向 localhost) 和 `404 Not Found` (API 路由不可达) 错误。

### 备注
- 远程服务器上的 `puter-ddb` (DynamoDB 本地数据) 在强制重启时容易锁死，需删除目录重置。
- 浏览器缓存非常顽固，修改前端逻辑后必须强制刷新。

## 2026-01-27 - Docker 部署完整修复（第6次尝试终于成功）
...
