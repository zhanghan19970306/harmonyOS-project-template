#!/bin/sh

# 获取执行脚本时的当前工作目录
EXECUTION_DIR=$(pwd)

# 引用 common.sh
. "$EXECUTION_DIR/scripts/common.sh"

# 检查当前分支是否为master
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != "master" ]]; then
    echo "${RED}当前不在master分支，请切换到master分支再运行脚本。${NC}"
    exit 0
fi

# 定义文件路径
json_file="AppScope/app.json5"

# 提取versionName和versionCode
versionName=$(grep '"versionName"' "$json_file" | sed -E 's/.*"versionName": *"([^"]+)".*/\1/')
versionCode=$(grep '"versionCode"' "$json_file" | sed -E 's/.*"versionCode": *([0-9]+).*/\1/')

# 检查读取的结果
if [[ -z "$versionName" || -z "$versionCode" ]]; then
    echo "${RED}读取失败，检查app.json5格式是否正确。${NC}"
    exit 0
fi

# 分割versionName为主版本号、次版本号和修订号
IFS='.' read -r major minor patch <<< "$versionName"

# 提示用户选择要升级的部分
echo "${BLUE}当前版本号: ${YELLOW}$versionName${GRAY} ($versionCode)${NC}"
echo "请选择要升级的部分:"

# 显示可选项
options=(
    "主版本号 - $((major + 1)).0.0"
    "次版本号 - $major.$((minor + 1)).0"
    "修订号 - $major.$minor.$((patch + 1))"
)

select option in "${options[@]}"; do
    case $option in
        "主版本号 - $((major + 1)).0.0")
            major=$((major + 1))
            minor=0
            patch=0
            break
            ;;
        "次版本号 - $major.$((minor + 1)).0")
            minor=$((minor + 1))
            patch=0
            break
            ;;
        "修订号 - $major.$minor.$((patch + 1))")
            patch=$((patch + 1))
            break
            ;;
        *)
            echo "${RED}无效选择，请重新选择。${NC}"
            ;;
    esac
done

# 生成新的版本号
new_versionName="$major.$minor.$patch"
new_versionCode=$((versionCode + 1))

# 显示新的版本信息，并询问是否确认更新
echo "${BLUE}升级后的版本号: ${YELLOW}$new_versionName ${GRAY}($new_versionCode)${NC}"
echo "确认更新版本信息吗？${GRAY}(y/n)${NC}: "
read confirm

# 根据用户输入执行相应操作
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # 更新文件中的versionName和versionCode
    sed -i '' -E "s/\"versionName\": *\"[^\"]+\"/\"versionName\": \"$new_versionName\"/" "$json_file"
    sed -i '' -E "s/\"versionCode\": *[0-9]+/\"versionCode\": $new_versionCode/" "$json_file"
    echo "${GREEN}更新成功 并写入 $json_file${NC}"

    # 询问是否提交代码并推送tag
    echo "是否提交代码并推送tag？${GRAY}(y/n)${NC}: "
    read push_confirm

    if [[ "$push_confirm" == "y" || "$push_confirm" == "Y" ]]; then
       git add .
       git commit -m "release: 更新version至$new_versionName"
       git push
       git tag "v$new_versionName"
       git push origin "v$new_versionName"
       echo "${GREEN}代码已提交并推送标签v$new_versionName${NC}"
    else
       echo "${RED}操作已取消，未提交代码或推送标签。${NC}"
    fi
else
    echo "${RED}操作已取消，版本号和版本代码未更新。${NC}"
fi


echo "开始打包吗？${GRAY}(y/n)${NC}: "
read confirm2

# 根据用户输入执行相应操作
if [[ "$confirm2" == "y" || "$confirm2" == "Y" ]]; then

  # 清理项目
  hvigorw -p product=default clean --analyze=normal --parallel --incremental --daemon

  # 生成APP
  hvigorw --mode project -p product=release -p buildMode=release assembleApp --analyze=normal --parallel --incremental --daemon

  # 打印签名后的app路径
  echo "${GREEN}APP打包成功！所在位置$EXECUTION_DIR/build/outputs/release/qmsd-harmonyos-app-release-signed.app${NC}"

else
  echo "${RED}操作已取消，未进行打包。${NC}"
fi