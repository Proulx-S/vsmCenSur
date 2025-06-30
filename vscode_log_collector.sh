
# VS Code/Cursor Log Collector for MATLAB Hanging Issue
LOG_COLLECTION_DIR="$HOME/vscode_debug_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$LOG_COLLECTION_DIR/debug_report_$TIMESTAMP.txt"

mkdir -p "$LOG_COLLECTION_DIR"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$REPORT_FILE"
}

collect_vscode_logs() {
    echo "=== VS CODE SERVER LOGS ===" >> "$REPORT_FILE"
    
    for dir in "$HOME/.vscode-server" "$HOME/.cursor-server" "$HOME/.vscode-server-insiders"; do
        if [ -d "$dir" ]; then
            echo "Found: $dir" >> "$REPORT_FILE"
            find "$dir" -name "*.log" -type f -exec cp {} "$LOG_COLLECTION_DIR/" \; 2>/dev/null
            find "$dir" -name "*.log" -type f -exec tail -50 {} \; >> "$REPORT_FILE" 2>/dev/null
        fi
    done
}

collect_system_state() {
    echo "=== CURRENT SYSTEM STATE ===" >> "$REPORT_FILE"
    echo "Memory:" >> "$REPORT_FILE"
    free -h >> "$REPORT_FILE"
    echo "Processes:" >> "$REPORT_FILE"
    ps aux | grep -E "(vscode|matlab|node)" | grep -v grep >> "$REPORT_FILE"
    echo "Network:" >> "$REPORT_FILE"
    netstat -tn | grep -E "(:22|:40000|:50000)" >> "$REPORT_FILE"
}

main() {
    log_message "Starting log collection..."
    echo "VS Code/MATLAB Debug Report - $(date)" > "$REPORT_FILE"
    collect_system_state
    collect_vscode_logs
    log_message "Collection complete: $REPORT_FILE"
}

case "$1" in
    "collect")
        main
        ;;
    *)
        echo "Usage: $0 collect"
        exit 1
        ;;
esac 
#!/bin/bash
 