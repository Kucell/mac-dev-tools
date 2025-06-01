#!/bin/bash

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# 打印带颜色的信息
print_message() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

# 确认函数
confirm() {
    echo -n "$1 [y/N] "
    read answer
    case $answer in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 检查并安装 zsh
setup_zsh() {
    if [ "$SHELL" != "/bin/zsh" ]; then
        if ! command -v zsh &> /dev/null; then
            if confirm "zsh 未安装，是否安装？"; then
                print_message "安装 zsh..."
                if command -v brew &> /dev/null; then
                    brew install zsh
                else
                    print_warning "请先安装 Homebrew，然后重新运行此脚本"
                    exit 1
                fi
            fi
        fi
        
        # 设置 zsh 为默认 shell
        if confirm "是否将 zsh 设置为默认 shell？"; then
            print_message "设置 zsh 为默认 shell..."
            chsh -s $(which zsh)
        fi
    else
        print_message "zsh 已经是默认 shell"
    fi

    # 安装 oh-my-zsh（如果未安装）
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if confirm "是否安装 oh-my-zsh？"; then
            print_message "安装 oh-my-zsh..."
            # 备份现有的 .zshrc
            if [ -f "$HOME/.zshrc" ]; then
                mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
            fi
            # 安装 oh-my-zsh
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            # 如果有备份，还原备份
            if [ -f "$HOME/.zshrc.backup" ]; then
                mv "$HOME/.zshrc.backup" "$HOME/.zshrc"
            fi
        fi
    else
        print_message "oh-my-zsh 已安装"
    fi

    # 创建 .bash_profile 如果不存在
    if [ ! -f "$HOME/.bash_profile" ]; then
        print_message "创建 .bash_profile..."
        touch "$HOME/.bash_profile"
    fi
}

# 创建必要的目录
setup_directories() {
    print_message "创建 npm 全局安装目录和缓存目录..."
    mkdir -p ~/.npm_global
    mkdir -p ~/.npm_cache
}

# 配置 npm
setup_npm() {
    if ! command -v npm &> /dev/null; then
        print_warning "npm 未安装，请先安装 Node.js"
        return 1
    fi

    if confirm "是否配置 npm 全局安装路径？"; then
        print_message "配置 npm..."
        npm config set prefix "$HOME/.npm_global"
        npm config set cache "$HOME/.npm_cache"
        
        # 添加 PATH 到 .zshrc
        if ! grep -q "export PATH=~/.npm_global/bin:\$PATH" ~/.zshrc; then
            echo 'export PATH=~/.npm_global/bin:$PATH' >> ~/.zshrc
        fi
        
        # 设置权限
        sudo chown -R $(whoami) ~/.npm 2>/dev/null || true
        sudo chown -R $(whoami) ~/.npm_global
        npm cache clean --force
        npm config set prefix ~/.npm_global
        npm install -g npm
    fi
}

# 安装 n 版本管理器
install_n() {
    if command -v n &> /dev/null; then
        print_message "n 已安装"
        return 0
    fi

    if confirm "是否安装 n (Node.js 版本管理器)？"; then
        print_message "安装 n..."
        if command -v brew &> /dev/null; then
            brew install n
        else
            npm install -g n
        fi
        
        # 添加 N_PREFIX 到 .zshrc
        if ! grep -q "export N_PREFIX" ~/.zshrc; then
            echo 'export N_PREFIX="$HOME/.n"' >> ~/.zshrc
            echo 'export PATH="$N_PREFIX/bin:$PATH"' >> ~/.zshrc
        fi
    fi
}

# 安装 volta
install_volta() {
    if command -v volta &> /dev/null; then
        print_message "volta 已安装"
        return 0
    fi

    if confirm "是否安装 volta？"; then
        print_message "安装 volta..."
        curl https://get.volta.sh | bash
        
        # 配置 volta
        mkdir -p ~/.volta/tools/user
        cat > ~/.volta/tools/user/platform.json << EOL
{
  "node": null,
  "pnpm": null,
  "yarn": null
}
EOL
        
        # 添加 volta 配置到 .zshrc
        if ! grep -q "VOLTA_HOME" ~/.zshrc; then
            echo 'export VOLTA_HOME="$HOME/.volta"' >> ~/.zshrc
            echo 'export PATH="$VOLTA_HOME/bin:$PATH"' >> ~/.zshrc
            echo 'export VOLTA_FEATURE_PNPM=1' >> ~/.zshrc
            echo 'export VOLTA_NPM_REGISTRY="https://registry.npmmirror.com"' >> ~/.zshrc
        fi
    fi
}

# 安装 pnpm
install_pnpm() {
    if command -v pnpm &> /dev/null; then
        print_message "pnpm 已安装"
        return 0
    fi

    if confirm "是否安装 pnpm？"; then
        print_message "安装 pnpm..."
        npm install -g pnpm
    fi
}

# 安装 zsh 插件
install_zsh_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # 安装 zsh-autosuggestions
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        print_message "安装 zsh-autosuggestions 插件..."
        git clone https://github.com/zsh-users/zsh-autosuggestions $plugins_dir/zsh-autosuggestions
    fi
    
    # 安装 zsh-syntax-highlighting
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        print_message "安装 zsh-syntax-highlighting 插件..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $plugins_dir/zsh-syntax-highlighting
    fi
    
    # 更新 .zshrc 中的插件配置
    if ! grep -q "plugins=(.*zsh-autosuggestions.*zsh-syntax-highlighting.*)" ~/.zshrc; then
        # 备份原始文件
        cp ~/.zshrc ~/.zshrc.bak
        # 更新插件列表
        sed -i '' 's/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    fi
}

# 安装 pnpm
install_pnpm() {
    if command -v pnpm &> /dev/null; then
        print_message "pnpm 已安装"
        return 0
    fi

    if confirm "是否安装 pnpm？"; then
        print_message "安装 pnpm..."
        npm install -g pnpm
    fi
}

# 安装 zsh 插件
install_zsh_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # 安装 zsh-autosuggestions
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        print_message "安装 zsh-autosuggestions 插件..."
        git clone https://github.com/zsh-users/zsh-autosuggestions $plugins_dir/zsh-autosuggestions
    fi
    
    # 安装 zsh-syntax-highlighting
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        print_message "安装 zsh-syntax-highlighting 插件..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $plugins_dir/zsh-syntax-highlighting
    fi
    
    # 更新 .zshrc 中的插件配置
    if ! grep -q "plugins=(.*zsh-autosuggestions.*zsh-syntax-highlighting.*)" ~/.zshrc; then
        # 备份原始文件
        cp ~/.zshrc ~/.zshrc.bak
        # 更新插件列表
        sed -i '' 's/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    fi
}

# 安装 nrm
install_nrm() {
    if ! command -v nrm &> /dev/null; then
        if confirm "是否安装 nrm (npm registry 管理器)？"; then
            print_message "安装 nrm..."
            npm install -g nrm
            
            # 添加淘宝镜像源
            if command -v nrm &> /dev/null; then
                print_message "配置 nrm..."
                nrm add taobao https://registry.npmmirror.com
                nrm use taobao
            fi
        fi
    else
        print_message "nrm 已安装"
    fi
}

# 安装前端开发工具
install_frontend_tools() {
    print_message "开始安装前端开发工具..."
    
    # nrm
    if ! command -v nrm &> /dev/null; then
        if confirm "是否安装 nrm (npm 镜像源管理工具)？"; then
            print_message "安装 nrm..."
            npm install -g nrm
            # 添加淘宝镜像
            nrm add taobao https://registry.npmmirror.com
            nrm use taobao
        fi
    else
        print_message "nrm 已安装"
    fi
    
    # http-server
    if ! command -v http-server &> /dev/null; then
        if confirm "是否安装 http-server (静态文件服务器)？"; then
            print_message "安装 http-server..."
            npm install -g http-server
        fi
    else
        print_message "http-server 已安装"
    fi
    
    # @vue/cli
    if ! command -v vue &> /dev/null; then
        if confirm "是否安装 Vue CLI？"; then
            print_message "安装 Vue CLI..."
            npm install -g @vue/cli
        fi
    else
        print_message "Vue CLI 已安装"
    fi
    
    # create-vite
    if confirm "是否安装 create-vite？"; then
        print_message "安装 create-vite..."
        npm install -g create-vite
    fi
    
    # eslint
    if ! command -v eslint &> /dev/null; then
        if confirm "是否安装 ESLint？"; then
            print_message "安装 ESLint..."
            npm install -g eslint
        fi
    else
        print_message "ESLint 已安装"
    fi
    
    # prettier
    if ! command -v prettier &> /dev/null; then
        if confirm "是否安装 Prettier？"; then
            print_message "安装 Prettier..."
            npm install -g prettier
        fi
    else
        print_message "Prettier 已安装"
    fi
    
    # typescript
    if ! command -v tsc &> /dev/null; then
        if confirm "是否安装 TypeScript？"; then
            print_message "安装 TypeScript..."
            npm install -g typescript
        fi
    else
        print_message "TypeScript 已安装"
    fi
    
    # nodemon
    if ! command -v nodemon &> /dev/null; then
        if confirm "是否安装 nodemon？"; then
            print_message "安装 nodemon..."
            npm install -g nodemon
        fi
    else
        print_message "nodemon 已安装"
    fi
}

# 主函数
main() {
    print_message "开始设置开发环境..."
    
    # 基础环境设置
    setup_zsh
    setup_directories
    
    # 前端开发环境
    if confirm "是否配置前端开发环境？"; then
        setup_frontend_env
    fi
    
    print_message "配置完成！请运行 'source ~/.zshrc' 使配置生效。"
}

# 运行主函数
main