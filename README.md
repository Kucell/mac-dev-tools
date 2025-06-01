# Mac 开发环境配置脚本

这是一个用于配置 Mac 开发环境的自动化脚本，包含了常用开发工具的安装和配置。

## 功能列表

- ZSH 配置
  - 安装并设置 zsh 为默认 shell
  - 安装 oh-my-zsh 
  - 安装常用插件（zsh-autosuggestions, zsh-syntax-highlighting）

- Node.js 环境配置
  - 配置 npm 全局安装路径
  - 安装 n（Node.js 版本管理器）
  - 安装 volta（项目级 Node.js 版本管理器）
  - 安装 pnpm（包管理器）
  - 安装 nrm（npm 镜像源管理器）

## 使用方法

### 完整安装

1. 给脚本添加执行权限：
```bash
chmod +x setup.sh