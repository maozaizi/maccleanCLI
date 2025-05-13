#!/bin/bash

# ---------------------------------------------------------------
# macOS Cleanup Tool
# Author: [maozaizi] 
# Version: 0.2
# Date: [2025-05-08]
#
# A lightweight and efficient macOS cleanup tool powered by 
# a simple shell script. Run it via the command line to keep 
# your system tidy and optimized effortlessly.
#
# Features:
# - Clears user and system caches
# - Deletes temporary files and application logs
# - Cleans Xcode derived data (if installed)
# - Empties Trash and Safari cache
# - Flushes DNS cache for network optimization
#
# CHANGELOG v0.2:
# - Replaced dangerous `rm -rf /private/tmp/*` with safer `find`-based deletion
# - Explicitly excludes mihomo-party.sock and mihomo-party-helper.sock
#
# Usage:
# Run this script with administrative privileges to perform 
# a complete system cleanup. Example:
#   chmod +x macos_cleanup.sh
#   sudo ./macos_cleanup.sh
#
# ---------------------------------------------------------------

echo "Starting macOS cleanup process..."

# --- Step 1: Clear user caches ---
echo "Clearing user caches..."
rm -rf ~/Library/Caches/*

# --- Step 2: Clear system caches (requires sudo) ---
echo "Clearing system caches..."
sudo rm -rf /Library/Caches/*

# --- Step 3: Remove user log files ---
echo "Removing user log files..."
rm -rf ~/Library/Logs/*

# --- Step 4: Clear temporary files safely ---
echo "Clearing temporary files (excluding mihomo-party sock files)..."
sudo find /private/tmp -mindepth 1 \
  ! -name 'mihomo-party.sock' \
  ! -name 'mihomo-party-helper.sock' \
  -exec rm -rf {} +
sudo find /var/tmp -mindepth 1 -exec rm -rf {} +

# --- Step 5: Empty the Trash ---
echo "Emptying the Trash..."
rm -rf ~/.Trash/*

# --- Step 6: Clean Xcode derived data (if Xcode exists) ---
if [ -d ~/Library/Developer/Xcode ]; then
    echo "Cleaning Xcode derived data and archives..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
    rm -rf ~/Library/Developer/Xcode/Archives/*
fi

# --- Step 7: Clear Safari browser cache ---
echo "Clearing Safari browser cache..."
rm -rf ~/Library/Caches/com.apple.Safari/*
rm -rf ~/Library/Safari/LocalStorage/*

# --- Step 8: Flush DNS cache ---
echo "Flushing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# --- Final message ---
echo "macOS cleanup completed successfully!"