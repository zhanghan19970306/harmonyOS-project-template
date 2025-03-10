#!/bin/sh

# 获取执行脚本时的当前工作目录
EXECUTION_DIR=$(pwd)

# 引用 common.sh
. "$EXECUTION_DIR/scripts/common.sh"

# 使用绝对路径来设置 Git 配置和更改文件权限
git config core.ignorecase false
git config advice.ignoredHook false
git config core.hooksPath "$EXECUTION_DIR/scripts/git-hooks/hooks"
chmod 700 "$EXECUTION_DIR/scripts/git-hooks/hooks/"*

echo "${GREEN}Git-hooks初始化成功!${NC}"