#!/bin/bash
# Simple VS Code Log Collector for MATLAB Hanging Issues

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR"
mkdir -p "$LOG_DIR"
REPORT="$LOG_DIR/debug_$(date +%Y%m%d_%H%M%S).txt"

echo "=== VS Code Debug Report $(date) ===" > "$REPORT"

echo "=== System State ===" >> "$REPORT"
echo "Memory Usage:" >> "$REPORT"
free -h >> "$REPORT"
echo "" >> "$REPORT"

echo "Active Processes:" >> "$REPORT"
ps aux | grep -E "(vscode|matlab|node)" | grep -v grep >> "$REPORT"
echo "" >> "$REPORT"

echo "Network Connections:" >> "$REPORT"
netstat -tn | grep -E "(:22|:40000|:50000)" >> "$REPORT"
echo "" >> "$REPORT"

echo "=== VS Code Server Logs ===" >> "$REPORT"
find ~/.vscode-server -name "*.log" 2>/dev/null | head -5 | while read log; do
  echo "--- $log ---" >> "$REPORT"
  tail -20 "$log" >> "$REPORT"
  echo "" >> "$REPORT"
done

echo "=== Extension Logs ===" >> "$REPORT"
find ~/.vscode-server/extensions -name "*.log" 2>/dev/null | head -3 | while read log; do
  echo "--- $log ---" >> "$REPORT"
  tail -10 "$log" >> "$REPORT"
  echo "" >> "$REPORT"
done

echo "Report saved to: $REPORT"
ls -la "$REPORT" 