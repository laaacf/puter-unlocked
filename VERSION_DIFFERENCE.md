# Puter 版本差异说明

## 📊 版本对比

### 两个版本的差异

#### 1. 配置文件差异（已统一）

现在两个版本使用**相同的配置文件** `volatile/config/config.json`：

```json
{
    "config_name": "Puter Universal Config",
    "env": "dev",
    "http_port": "auto",  // 自动检测端口，支持本地和服务器
    "allow_all_host_values": true,        // 允许任意域名访问
    "allow_nipio_domains": true,          // 允许 nip.io 域名
    "disable_ip_validate_event": true,    // 允许 IP 直接访问
    "custom_domains_enabled": true,       // 允许自定义域名
    "experimental_no_subdomain": true     // API 和 GUI 使用同一域名
}
```

**关键配置说明：**
- `http_port: "auto"` - 自动端口，本地开发时使用随机端口，生产环境可指定
- `allow_all_host_values: true` - 支持反向代理访问
- `experimental_no_subdomain: true` - 不强制使用 api 子域名

#### 2. 代码修改（已统一）

两个版本的代码**完全相同**，包含以下修改：

##### A. 支持反向代理的协议识别

**文件：** `src/backend/src/routers/_default.js`

```javascript
// 检查 X-Forwarded-Proto 头以识别反向代理的真实协议
const protocol = req.get('X-Forwarded-Proto') || req.protocol;
const host = req.get('X-Forwarded-Host') || req.get('host');
let canonical_url = `${protocol}://${host}${path}`;
```

**作用：** 当使用 Nginx 等反向代理时，正确识别原始协议（HTTP/HTTPS）

##### B. API 配置动态生成

**文件：** `src/backend/src/services/PuterHomepageService.js`

```javascript
// 检查 X-Forwarded-Proto 和 X-Forwarded-Host 头
const actual_protocol = req.get('X-Forwarded-Proto') || req.protocol;
const actual_host = req.get('X-Forwarded-Host') || req.get('host');
const actual_origin = `${actual_protocol}://${actual_host}`;
```

**作用：** 前端配置使用实际的协议和主机名，支持反向代理

##### C. 禁用注册的 Bot 检测

**文件：** `src/backend/src/routers/signup.js`

```javascript
abuse: {
    no_bots: false,  // 禁用 bot 检测以支持灵活访问
    // ...
},
mw: [], // 禁用 captcha 中间件
```

**作用：** 允许从不同来源注册，不限制 User-Agent

##### D. 禁用登录的 Captcha

**文件：** `src/backend/src/routers/login.js`

```javascript
// 移除了 requireCaptcha 中间件
router.post('/login', express.json(), body_parser_error_handler,
    async (req, res, next) => {
        // 登录逻辑
    }
);
```

**作用：** 简化登录流程，无需 captcha 验证

---

## 🎯 统一后的特性

两个版本现在**完全一致**，具有以下特性：

### ✅ 核心功能
1. **支持任意域名访问** - 不限制访问域名
2. **支持 IP 直接访问** - 可以用 IP 地址访问
3. **支持反向代理** - 正确处理 HTTPS 反向代理
4. **API 同域名** - 不强制使用 api 子域名

### ✅ 简化的认证
1. **无需 captcha** - 注册和登录都不需要 captcha
2. **不限制 User-Agent** - 允许 curl 等工具访问

### ✅ 灵活的部署
1. **本地开发** - `npm start` 直接运行
2. **Docker 部署** - 使用 docker-compose
3. **服务器部署** - npm start 或 Docker

---

## 🚀 部署方式

### 方式 1：本地开发

```bash
# 克隆仓库
git clone https://github.com/laaacf/puter-unlocked.git
cd puter-unlocked

# 安装依赖
npm install

# 启动服务
npm start

# 访问：http://localhost:4100
```

### 方式 2：服务器部署（npm start）

```bash
# 克隆仓库
git clone https://github.com/laaacf/puter-unlocked.git
cd puter-unlocked

# 安装依赖（需要 Node.js >= 24）
npm install

# 启动服务（后台运行）
nohup npm start > /tmp/puter.log 2>&1 &

# 查看日志
tail -f /tmp/puter.log

# 停止服务
pkill -f 'node ./tools/run-selfhosted.js'
```

### 方式 3：Docker 部署

```bash
# 克隆仓库
git clone https://github.com/laaacf/puter-unlocked.git
cd puter-unlocked

# 构建镜像
docker build -t puter-custom:latest .

# 运行容器
docker run -d \
  --name puter \
  -p 4100:4100 \
  -v $(pwd)/volatile/config:/etc/puter \
  -v $(pwd)/volatile/runtime:/var/puter \
  puter-custom:latest
```

---

## 🌐 访问方式

部署后可以通过以下方式访问：

1. **本地访问**
   - http://localhost:4100

2. **IP 访问**
   - http://服务器IP:4100

3. **域名访问**
   - http://your-domain.com

4. **反向代理（推荐）**
   - 配置 Nginx 反向代理
   - 支持 HTTPS
   - 示例：https://gpt.3868088.xyz/

---

## 🔧 Nginx 反向代理配置示例

```nginx
server {
    listen 443 ssl http2;
    server_name gpt.3868088.xyz;

    # SSL 证书配置
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # 重要：转发原始协议和主机头
    location / {
        proxy_pass http://127.0.0.1:4100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;  # 关键：传递原始协议
        proxy_set_header X-Forwarded-Host $host;     # 关键：传递原始主机
    }
}
```

---

## 📝 默认登录凭据

首次启动时，系统会自动创建管理员账户：

- **用户名：** `admin`
- **密码：** 查看启动日志中的提示

**重要：** 首次登录后请立即修改密码！

---

## 🔍 故障排除

### 问题 1：反向代理显示空白页面

**原因：** 协议不匹配（HTTP vs HTTPS）

**解决：**
1. 确认 Nginx 配置包含 `X-Forwarded-Proto` 头
2. 检查前端配置中的 `api_origin` 是否使用正确的协议

### 问题 2：无法注册新用户

**原因：** Bot 检测或 captcha 限制

**解决：**
1. 确认配置文件中有 `disable_abuse_checks: true` 或相关路由已禁用检测
2. 检查 `signup.js` 和 `login.js` 的修改

### 问题 3：Docker 容器无法启动

**原因：** 目录权限问题

**解决：**
```bash
sudo chown -R 1000:1000 volatile/config volatile/runtime
```

---

## 📚 相关链接

- **原项目：** https://github.com/HeyPuter/puter
- **修改版本：** https://github.com/laaacf/puter-unlocked
- **问题反馈：** https://github.com/laaacf/puter-unlocked/issues

---

## ✨ 总结

现在**两个版本完全统一**，可以在任何环境中使用相同的配置和代码。

**主要特点：**
- ✅ 支持反向代理
- ✅ 支持任意域名访问
- ✅ 支持 IP 直接访问
- ✅ 简化的认证流程
- ✅ 灵活的部署方式

**推荐部署方式：**
- 开发环境：`npm start`
- 生产环境：Docker 或 systemd 服务
- 访问方式：Nginx 反向代理 + HTTPS
