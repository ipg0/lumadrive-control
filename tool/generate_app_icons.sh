#!/usr/bin/env bash
set -euo pipefail

# Render the supplied SVG once, then produce native launcher sizes from it.
# Requires librsvg (rsvg-convert) and ImageMagick 7 (magick).
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd -- "$root"
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
background='#101720'
rsvg-convert --width 2048 --output "$tmp/logo.png" lib/assets/lumadrive_monogram.svg
magick "$tmp/logo.png" -trim +repage -resize 780x780 \
  -gravity center -background "$background" -alpha remove -alpha off \
  -extent 1024x1024 "$tmp/icon.png"
magick "$tmp/logo.png" -trim +repage -resize 620x620 \
  -gravity center -background none -extent 1024x1024 "$tmp/foreground.png"
magick "$tmp/logo.png" -trim +repage -resize 620x620 \
  -gravity center -background "$background" -alpha remove -alpha off \
  -extent 1024x1024 "$tmp/maskable.png"

for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  case "$density" in
    mdpi) size=48; foreground=108 ;;
    hdpi) size=72; foreground=162 ;;
    xhdpi) size=96; foreground=216 ;;
    xxhdpi) size=144; foreground=324 ;;
    xxxhdpi) size=192; foreground=432 ;;
  esac
  dir="android/app/src/main/res/mipmap-$density"
  magick "$tmp/icon.png" -resize "${size}x${size}!" "PNG24:$dir/ic_launcher.png"
  magick "$tmp/foreground.png" -resize "${foreground}x${foreground}!" "$dir/ic_launcher_foreground.png"
done

for file in ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png; do
  size=$(magick identify -format '%w' "$file")
  magick "$tmp/icon.png" -resize "${size}x${size}!" "PNG24:$file"
done
for size in 192 512; do
  magick "$tmp/icon.png" -resize "${size}x${size}!" "PNG24:web/icons/Icon-$size.png"
  magick "$tmp/maskable.png" -resize "${size}x${size}!" "PNG24:web/icons/Icon-maskable-$size.png"
done
magick "$tmp/icon.png" -resize 32x32! "PNG24:web/favicon.png"
magick "$tmp/icon.png" -resize 256x256! "PNG24:linux/runner/lumadrive_icon.png"
magick "$tmp/icon.png" -define icon:auto-resize=256,128,64,48,32,16 windows/runner/resources/app_icon.ico
