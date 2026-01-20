# Puter 配置说明

## 🌐 浏览器自动打开配置

### 问题
Safari 浏览器不允许程序自动打开链接。

### 解决方案

#### 方案 1：在配置文件中禁用自动打开（推荐）

在你的 `config.json` 或 `volatile/config/config.json` 中添加：

```json
{
    "no_browser_launch": true,
    ...
}
```

这样服务器启动时不会尝试打开浏览器，你可以在终端看到链接后手动打开。

#### 方案 2：使用 Chrome 或 Firefox

如果使用 Chrome 或 Firefox，自动打开功能可以正常工作。

#### 方案 3：在配置文件中指定浏览器

修改配置添加：
```json
{
    "browser_app": "google chrome",
    ...
}
```

---

## 🚀 快速配置

### 本地开发（禁用自动打开）

```bash
# 编辑配置文件
nano volatile/config/config.json
```

添加这一行：
```json
"no_browser_launch": true
```

### 服务器部署

服务器部署时，应该设置 `env: "production"`，这样就不会自动打开浏览器：

```json
{
    "env": "production",
    ...
}
```

---

## 📝 配置示例

### 开发环境配置（禁用自动打开）
```json
{
    "env": "dev",
    "no_browser_launch": true,
    ...
}
```

### 生产环境配置
```json
{
    "env": "production",
    ...
}
```
生产环境默认不会打开浏览器。
