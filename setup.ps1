#!/usr/sbin/env -S pwsh.exe

$IMG_NAME = "ubuntu-24.04-server-cloudimg-amd64.img"
$VHDX_NAME = "ubuntu-24.04-server-cloudimg-amd64.vhdx"

if (-Not (Test-Path ".\data\$VHDX_NAME")) {
    if (-Not (Test-Path ".\data\$IMG_NAME")) {
        curl -sLo ".\data\$IMG_NAME" "https://ftp.udx.icscoe.jp/Linux/ubuntu-cloud-images/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img" 
    }
    echo "qemu-img convert -p -f qcow2 -O vhdx ./data/$IMG_NAME ./data/$VHDX_NAME" | wsl .
}

echo "cloud-localds ./data/seed.iso ./data/user-data.yml ./data/meta-data.yml" | wsl .
