#!/bin/sh
set -ex

case $1 in
    amd64)
        ARCH="64"
        FNAME="amd64"
        ;;
    i386)
        ARCH="32"
        FNAME="i386"
        ;;
    armv8 | arm64 | aarch64)
        ARCH="arm64-v8a"
        FNAME="arm64"
        ;;
    armv7 | arm | arm32)
        ARCH="arm32-v7a"
        FNAME="arm32"
        ;;
    armv6)
        ARCH="arm32-v6"
        FNAME="armv6"
        ;;
    *)
        ARCH="64"
        FNAME="amd64"
        ;;
esac

MTG_MULTI_VER=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/mhsanaei/mtg-multi/releases/latest" | sed -n 's#.*/releases/tag/##p')
if [ -z "$MTG_MULTI_VER" ]; then
    MTG_MULTI_VER=$(curl -fsSL "https://api.github.com/repos/mhsanaei/mtg-multi/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1)
fi
if [ -z "$MTG_MULTI_VER" ]; then
    echo "DockerInit: could not resolve the latest mtg-multi release tag" >&2
    exit 1
fi

mkdir -p build/bin
cd build/bin

# Download latest Xray-core instead of hardcoded v26.10.10
curl -fSLRO "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${ARCH}.zip"
unzip "Xray-linux-${ARCH}.zip"
rm -f "Xray-linux-${ARCH}.zip" geoip.dat geosite.dat
mv xray "xray-linux-${FNAME}"
chmod +x "xray-linux-${FNAME}"

case $FNAME in
    i386) MTGARCH="386" ;;
    arm32) MTGARCH="armv7" ;;
    *) MTGARCH="$FNAME" ;;
esac

MTG_PKG="mtg-multi-${MTG_MULTI_VER#v}-linux-${MTGARCH}"
curl -fSLRO "https://github.com/mhsanaei/mtg-multi/releases/download/${MTG_MULTI_VER}/${MTG_PKG}.tar.gz"
tar -xzf "${MTG_PKG}.tar.gz"
mv "${MTG_PKG}/mtg-multi" "mtg-linux-${FNAME}"
rm -rf "${MTG_PKG}" "${MTG_PKG}.tar.gz"
chmod +x "mtg-linux-${FNAME}"

curl -fSLRO https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
curl -fSLRO https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
curl -fSLRo geoip_IR.dat https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geoip.dat
curl -fSLRo geosite_IR.dat https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geosite.dat
curl -fSLRo geoip_RU.dat https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat
curl -fSLRo geosite_RU.dat https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat

cd ../../
