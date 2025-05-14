#!/bin/bash

# ---------------------------------------------------------------
# macOS Cleanup Tool
# Author: [maozaizi] 
# Version: 0.5
# Date: [2025-05-13]
#
# Description:
# A lightweight and efficient macOS cleanup tool powered by a simple shell script.
# Now includes optional safe disk permission repair, human-readable logging, dry-run preview mode,
# and more application cache cleaning (Chrome, WeChat, etc).
#
# Features:
# - Clears user and system caches
# - Deletes temporary files and application logs
# - Cleans Xcode derived data (if installed)
# - Empties Trash and Safari/Chrome/WeChat cache
# - Flushes DNS cache
# - Optionally repairs user and application permissions
# - Logs each step with timestamp to Desktop/maccleanCLI-<timestamp>.log
# - Dry-run mode: preview what will be deleted/repaired before执行
#
# Usage:
# chmod +x macos_cleanup.sh
# sudo ./macos_cleanup.sh [--dry-run]
# ---------------------------------------------------------------

# Create log file with timestamp
LOG_FILE=~/Desktop/maccleanCLI-$(date +%Y%m%d-%H%M%S).log
log() {
  echo -e "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

# Dry-run mode detection
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  log "📝 Dry-run模式：仅预览将要删除/修复的内容，不做实际操作。"
fi

echo ""
echo "==============================="
echo " maccleanCLI - macOS Cleanup "
echo "==============================="
echo ""
if $DRY_RUN; then
  echo "[DRY-RUN] 仅预览将要清理/修复的内容，不做实际删除。"
fi

# Helper for dry-run
run_or_echo() {
  if $DRY_RUN; then
    echo "[DRY-RUN] $1"
  else
    eval "$1"
  fi
}

log "🧹 Starting macOS cleanup process..."

# Step 1: Clear user caches
log "🗑️ Clearing user caches..."
run_or_echo "rm -rf ~/Library/Caches/*"

# Step 2: Clear system caches
log "🗑️ Clearing system caches..."
run_or_echo "sudo rm -rf /Library/Caches/*"

# Step 3: Remove user log files
log "🧾 Removing user log files..."
run_or_echo "rm -rf ~/Library/Logs/*"

# Step 4: Clear temporary files safely
log "🧼 Clearing temporary files (excluding mihomo-party sock files)..."
run_or_echo "sudo find /private/tmp -mindepth 1 ! -name 'mihomo-party.sock' ! -name 'mihomo-party-helper.sock' -exec rm -rf {} +"
run_or_echo "sudo find /var/tmp -mindepth 1 -exec rm -rf {} +"

# Step 5: Empty the Trash
log "🗑️ Emptying the Trash..."
run_or_echo "rm -rf ~/.Trash/*"

# Step 6: Clean Xcode derived data
if [ -d ~/Library/Developer/Xcode ]; then
  log "🧹 Cleaning Xcode derived data and archives..."
  run_or_echo "rm -rf ~/Library/Developer/Xcode/DerivedData/*"
  run_or_echo "rm -rf ~/Library/Developer/Xcode/Archives/*"
else
  log "✅ Xcode not installed, skipping Xcode cleanup."
fi

# Step 7: Clear Safari browser cache
log "🧽 Clearing Safari browser cache..."
run_or_echo "rm -rf ~/Library/Caches/com.apple.Safari/*"
run_or_echo "rm -rf ~/Library/Safari/LocalStorage/*"

# Step 8: Clear Chrome browser cache
log "🧽 Clearing Chrome browser cache..."
run_or_echo "rm -rf ~/Library/Caches/Google/Chrome/*"
run_or_echo "rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Cache/*"

# Step 9: Clear WeChat cache (main and mini-programs)
log "🧽 Clearing WeChat cache..."
run_or_echo "rm -rf ~/Library/Containers/com.tencent.xinWeChat/Data/Library/Application\ Support/com.tencent.xinWeChat/*"
run_or_echo "rm -rf ~/Library/Group\ Containers/5A4RE8SF68.com.tencent.xinWeChat/Library/Caches/xinWeChat/*"

# Step 10: Flush DNS cache
log "🔄 Flushing DNS cache..."
run_or_echo "sudo dscacheutil -flushcache"
run_or_echo "sudo killall -HUP mDNSResponder"

# Step 11: Optional disk permission repair
log "🔧 Prompting for disk permission repair..."
echo -e "\n🔧 是否修复磁盘权限（~/Library 与 /Applications）？"
echo -e "   ⚠️  谨慎操作，仅修复用户目录和第三方 App 权限"
echo -e "   推荐在：应用程序异常 / 无法删除文件 / 安装后报错 时使用"
read -p "👉 是否修复磁盘权限？(y/N 默认否): " FIX_PERM

FIX_PERM=${FIX_PERM,,}  # 转小写
if [[ "$FIX_PERM" == "y" ]]; then
  log "🛠️ 修复中：用户目录权限..."
  run_or_echo "diskutil resetUserPermissions / $(id -u)"

  log "🛠️ 修复中：/Applications 目录权限..."
  run_or_echo "sudo find /Applications -type d -maxdepth 1 -not -path '/Applications' -not -path '/Applications/Utilities' -exec sudo chown -R root:wheel {} \; -exec sudo chmod -R 755 {} \;"

  log "✅ 磁盘权限修复完成"
else
  log "🚫 用户选择跳过磁盘权限修复。"
fi

log "✅ macOS cleanup completed successfully!"
echo -e "\n📝 日志已保存到: $LOG_FILE"
