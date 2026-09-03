#!/bin/bash
# release.sh - Everything-CJ 发布脚本
#
# 用法:
#   ./release.sh [version] [target]
#
# 示例:
#   ./release.sh 1.0.0 x86_64-pc-windows-msvc
#   ./release.sh 1.0.0
#

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认版本
VERSION="${1:-1.0.0}"
TARGET="${2:-x86_64-pc-windows-msvc}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${PROJECT_DIR}/dist"
RELEASE_DIR="${DIST_DIR}/everything_cli-${VERSION}"

echo -e "${GREEN}=== Everything-CJ 发布脚本 ===${NC}"
echo ""
echo "版本: ${VERSION}"
echo "目标: ${TARGET}"
echo ""

# 清理
if [ -d "${DIST_DIR}" ]; then
    echo -e "${YELLOW}清理旧的发布目录...${NC}"
    rm -rf "${DIST_DIR}"
fi

mkdir -p "${DIST_DIR}"

# 构建
echo -e "${GREEN}构建项目...${NC}"
cd "${PROJECT_DIR}"

if command -v cjpm &> /dev/null; then
    echo "使用 cjpm 构建..."
    cjpm build --release --target "${TARGET}"
else
    echo -e "${RED}错误: cjpm 未安装${NC}"
    echo "请安装 Cangjie SDK 和 cjpm 工具链"
    exit 1
fi

# 创建发布目录
mkdir -p "${RELEASE_DIR}"

# 复制二进制文件
if [ -f "target/${TARGET}/release/Everything-CJ.exe" ]; then
    cp "target/${TARGET}/release/Everything-CJ.exe" "${RELEASE_DIR}/"
    cp "target/${TARGET}/release/ES.exe" "${RELEASE_DIR}/"
    echo -e "${GREEN}✓ 复制二进制文件${NC}"
else
    echo -e "${RED}错误: 未找到构建的二进制文件${NC}"
    exit 1
fi

# 复制配置文件
cp config.toml "${RELEASE_DIR}/" 2>/dev/null || true

# 复制文档
cp README.md "${RELEASE_DIR}/"
cp CHANGELOG.md "${RELEASE_DIR}/"
cp LICENSE "${RELEASE_DIR}/"

# 创建压缩包
echo ""
echo -e "${GREEN}创建压缩包...${NC}"
cd "${DIST_DIR}"

ZIP_FILE="everything_cli-${VERSION}-${TARGET}.zip"
tar -czf "everything_cli-${VERSION}-${TARGET}.tar.gz" "everything_cli-${VERSION}"
zip -r "${ZIP_FILE}" "everything_cli-${VERSION}" 2>/dev/null || true

echo ""
echo -e "${GREEN}=== 发布完成 ===${NC}"
echo ""
echo "发布目录: ${RELEASE_DIR}"
echo "压缩包: ${DIST_DIR}/${ZIP_FILE}"
echo "压缩包: ${DIST_DIR}/everything_cli-${VERSION}-${TARGET}.tar.gz"
echo ""
echo "发布文件列表:"
ls -la "${RELEASE_DIR}"
echo ""
echo "压缩包大小:"
ls -lh "${DIST_DIR}/"*.tar.gz "${DIST_DIR}/"*.zip 2>/dev/null || true
