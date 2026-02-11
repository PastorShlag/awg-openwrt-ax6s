#!/bin/sh

set -e

echo "=== AmneziaWG auto installer ==="

# --- Определяем параметры системы ---
BOARD_JSON="$(ubus call system board)"

VERSION="$(echo "$BOARD_JSON" | jsonfilter -e '@.release.version')"
TARGET_FULL="$(echo "$BOARD_JSON" | jsonfilter -e '@.release.target')"

TARGET="$(echo "$TARGET_FULL" | cut -d '/' -f 1)"
SUBTARGET="$(echo "$TARGET_FULL" | cut -d '/' -f 2)"

echo "OpenWrt version : $VERSION"
echo "Target          : $TARGET/$SUBTARGET"

# --- GitHub ---
BASE_URL="https://github.com/PastorShlag/awg-openwrt-ax6s/releases/download/v${VERSION}"
POSTFIX="_v${VERSION}__${TARGET}_${SUBTARGET}.apk"

TMP_DIR="/tmp/amneziawg"
mkdir -p "$TMP_DIR"

download_and_install() {
    PKG_NAME="$1"

    if apk list --installed | grep -q "^$PKG_NAME"; then
        echo "[OK] $PKG_NAME already installed"
        return
    fi

    FILE_NAME="${PKG_NAME}${POSTFIX}"
    URL="${BASE_URL}/${FILE_NAME}"
    OUT="${TMP_DIR}/${FILE_NAME}"

    echo "-> Installing $PKG_NAME"
    echo "   Download: $URL"

    if curl -fL -o "$OUT" "$URL"; then
        apk add --allow-untrusted "$OUT"
        echo "[OK] $PKG_NAME installed"
    else
        echo "[WARN] $PKG_NAME not found for this release, skipping"
    fi
}

# --- Установка пакетов ---
download_and_install kmod-amneziawg
download_and_install amneziawg-tools
download_and_install luci-proto-amneziawg
download_and_install luci-i18n-amneziawg-ru

# --- Очистка ---
rm -rf "$TMP_DIR"

echo "=== Installation finished ==="
