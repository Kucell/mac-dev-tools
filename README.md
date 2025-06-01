# Mac 开发环境配置脚本

这是一个用于配置 Mac 开发环境的自动化脚本，包含了常用开发工具的安装和配置，适用于前端开发者快速搭建本地开发环境。

## 功能列表

### 🐚 ZSH 配置
- 安装并设置 `zsh` 为默认 shell（如未安装）
- 安装 [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- 安装常用插件：
  - `zsh-autosuggestions`：命令自动补全
  - `zsh-syntax-highlighting`：语法高亮

### 📦 Node.js 环境配置
- 设置 npm 全局安装路径 (`~/.npm_global`)
- 安装 `n`（Node.js 版本管理器）
- 安装 [volta](https://volta.sh)（项目级 Node.js 版本管理器）
- 安装 `pnpm`（高性能包管理器）
- 安装 `nrm`（npm 镜像源管理器，含淘宝镜像）

### 🧰 系统工具
- **Homebrew**：macOS 缺失的包管理器，用于安装和管理开发工具
- **tmux**：终端复用工具，支持多窗口、多标签页、断开重连等功能，适合远程开发和长时间任务管理

### 💻 开发效率工具
- **zsh-autosuggestions**：命令自动补全功能，提高终端输入效率
- **zsh-syntax-highlighting**：终端命令语法高亮，增强可读性和安全性
- **http-server**：快速启动本地静态文件服务器，适合前端调试
- **nodemon**：监听文件变化并自动重启 Node.js 应用，适用于开发环境
- **ESLint / Prettier**：代码检查与格式化工具，统一代码风格
- **nrm**：切换 npm 镜像源，提升包下载速度（默认配置淘宝镜像）
- **volta**：精准控制项目使用的 Node.js 和包管理器版本
- **tmux**：终端复用工具，支持多窗口、多标签页、断开重连等功能，适合远程开发和长时间任务管理

### 🧰 前端开发工具
- **http-server**：静态文件服务器
- **Vue CLI**：Vue 项目脚手架工具
- **create-vite**：Vite 项目初始化工具
- **ESLint**：代码规范工具
- **Prettier**：代码格式化工具
- **TypeScript**：JavaScript 的超集编译器
- **nodemon**：监听文件变化并自动重启 Node 应用

## 使用方法

### 完整安装
1. 给脚本添加执行权限：
```bash
chmod +x setup.sh
```

2. 执行脚本：
```bash
./setup.sh
```

3. 更新当前 shell 配置：
```bash
source ~/.zshrc
```

> ⚠️ 注意：脚本运行过程中会提示确认部分操作（例如是否安装某个工具），请根据需要选择 `y` 或 `n`。

## 自定义配置
你可以在脚本中修改以下配置项以适应个人需求：
- `VOLTA_NPM_REGISTRY`：Volta 默认使用的 NPM 镜像源
- `.zshrc` 插件列表：可增删其他 zsh 插件

## 已知依赖
- Homebrew（推荐）：用于安装系统级工具（如 `zsh`, `n` 等）
- Git：用于克隆 zsh 插件仓库

