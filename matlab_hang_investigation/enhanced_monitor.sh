#!/bin/bash

# Enhanced MATLAB Hang Monitor (Diagnostic Only)
# Monitors and logs MATLAB process behavior without taking automatic actions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/monitor_logs"
LOG_FILE="$LOG_DIR/enhanced_monitor_$(date +%Y%m%d_%H%M%S).log"
INTERVAL=10  # Monitor every 10 seconds
CPU_THRESHOLD=80    # CPU threshold for hang detection (percentage)
MEMORY_THRESHOLD=8  # Memory threshold in GB

# Create log directory
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if MATLAB process is hanging
check_matlab_hang() {
    local pid=$1
    local cpu_usage=$(ps -p $pid -o pcpu= 2>/dev/null | tr -d ' ')
    local memory_gb=$(ps -p $pid -o pmem= 2>/dev/null | tr -d ' ')
    local runtime=$(ps -p $pid -o etime= 2>/dev/null)
    
    if [[ -n "$cpu_usage" && -n "$memory_gb" ]]; then
        # Convert memory percentage to GB (assuming 376GB total)
        local memory_gb_calc=$(echo "scale=1; $memory_gb * 376 / 100" | bc 2>/dev/null)
        
        log_message "MATLAB PID $pid: CPU=${cpu_usage}%, Memory=${memory_gb_calc}GB, Runtime=$runtime"
        
        # Check if process is hanging
        if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )) && (( $(echo "$memory_gb_calc > $MEMORY_THRESHOLD" | bc -l) )); then
            log_message "WARNING: MATLAB PID $pid appears to be hanging (CPU: ${cpu_usage}%, Memory: ${memory_gb_calc}GB)"
            return 0  # Hanging
        fi
    fi
    return 1  # Not hanging
}

# Function to monitor system resources
monitor_system() {
    echo "=== ENHANCED SYSTEM MONITOR ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # Memory usage
    echo "--- Memory Usage ---" >> "$LOG_FILE"
    free -h >> "$LOG_FILE"
    
    # CPU usage
    echo "--- CPU Usage ---" >> "$LOG_FILE"
    top -bn1 | head -5 >> "$LOG_FILE"
    
    # MATLAB processes
    echo "--- MATLAB Processes ---" >> "$LOG_FILE"
    ps aux | grep -i matlab | grep -v grep >> "$LOG_FILE"
    
    # Check for hanging MATLAB processes (diagnostic only)
    local hanging_count=0
    ps aux | grep -i matlab | grep -v grep | awk '{print $2}' | while read pid; do
        if check_matlab_hang $pid; then
            hanging_count=$((hanging_count + 1))
        fi
    done
    
    # Log summary
    if [[ $hanging_count -gt 0 ]]; then
        log_message "DIAGNOSTIC: Found $hanging_count potentially hanging MATLAB process(es)"
        log_message "DIAGNOSTIC: Manual intervention may be required"
    fi
    
    echo "" >> "$LOG_FILE"
}

# Function to show status
show_status() {
    echo "Enhanced MATLAB Monitor Status (Diagnostic Only):"
    echo "Log file: $LOG_FILE"
    echo "CPU threshold: ${CPU_THRESHOLD}%"
    echo "Memory threshold: ${MEMORY_THRESHOLD}GB"
    echo "Auto-actions: DISABLED (diagnostic only)"
    echo ""
    echo "MATLAB processes:"
    ps aux | grep -i matlab | grep -v grep
}

# Function to generate diagnostic report
generate_report() {
    local report_file="$LOG_DIR/diagnostic_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "=== MATLAB HANG DIAGNOSTIC REPORT ===" > "$report_file"
    echo "Generated: $(date)" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "--- Current System State ---" >> "$report_file"
    free -h >> "$report_file"
    echo "" >> "$report_file"
    
    echo "--- MATLAB Processes ---" >> "$report_file"
    ps aux | grep -i matlab | grep -v grep >> "$report_file"
    echo "" >> "$report_file"
    
    echo "--- VS Code/Cursor Processes ---" >> "$report_file"
    ps aux | grep -E "(vscode|cursor)" | grep -v grep >> "$report_file"
    echo "" >> "$report_file"
    
    echo "--- Network Connections ---" >> "$report_file"
    netstat -tn | grep -E "(:22|:40000|:50000)" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "Report saved to: $report_file"
    echo "Use this report for manual analysis and intervention decisions"
}

# Main monitoring loop
monitor_loop() {
    log_message "Enhanced MATLAB monitor started (DIAGNOSTIC ONLY)"
    log_message "CPU threshold: ${CPU_THRESHOLD}%"
    log_message "Memory threshold: ${MEMORY_THRESHOLD}GB"
    log_message "Auto-actions: DISABLED - manual intervention required"
    
    while true; do
        monitor_system
        sleep $INTERVAL
    done
}

# Command line interface
case "${1:-}" in
    "start")
        monitor_loop
        ;;
    "status")
        show_status
        ;;
    "report")
        generate_report
        ;;
    *)
        echo "Usage: $0 {start|status|report}"
        echo ""
        echo "Commands:"
        echo "  start   - Start diagnostic monitoring (no auto-actions)"
        echo "  status  - Show current status and MATLAB processes"
        echo "  report  - Generate diagnostic report for manual analysis"
        echo ""
        echo "Configuration:"
        echo "  CPU_THRESHOLD=$CPU_THRESHOLD%"
        echo "  MEMORY_THRESHOLD=${MEMORY_THRESHOLD}GB"
        echo "  Auto-actions: DISABLED (diagnostic only)"
        echo ""
        echo "This monitor will:"
        echo "  - Log system state every $INTERVAL seconds"
        echo "  - Detect potential hangs based on thresholds"
        echo "  - Generate diagnostic reports"
        echo "  - NOT take any automatic actions"
        echo "  - Require manual intervention decisions"
        ;;
esac 