#!/bin/bash

# VS Code/Cursor Remote Monitoring Script
# Monitors system resources, processes, and logs when MATLAB shell hangs

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/monitor_logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y%m%d_%H%M%S).log"
INTERVAL=5  # Monitor every 5 seconds

# Create log directory
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to monitor system resources
monitor_resources() {
    echo "=== SYSTEM RESOURCES ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # Memory usage
    echo "--- Memory Usage ---" >> "$LOG_FILE"
    free -h >> "$LOG_FILE"
    
    # CPU usage
    echo "--- CPU Usage ---" >> "$LOG_FILE"
    top -bn1 | head -5 >> "$LOG_FILE"
    
    # Disk usage
    echo "--- Disk Usage ---" >> "$LOG_FILE"
    df -h >> "$LOG_FILE"
    
    # Load average
    echo "--- Load Average ---" >> "$LOG_FILE"
    uptime >> "$LOG_FILE"
    
    echo "" >> "$LOG_FILE"
}

# Function to monitor VS Code processes
monitor_vscode_processes() {
    echo "=== VS CODE PROCESSES ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # All VS Code related processes
    echo "--- VS Code Server Processes ---" >> "$LOG_FILE"
    ps aux | grep -E "(vscode-server|code-server|cursor-server)" | grep -v grep >> "$LOG_FILE"
    
    # Node.js processes (VS Code server uses Node)
    echo "--- Node.js Processes ---" >> "$LOG_FILE"
    ps aux | grep node | grep -v grep >> "$LOG_FILE"
    
    # Extension host processes
    echo "--- Extension Host Processes ---" >> "$LOG_FILE"
    ps aux | grep -E "(extensionHost|extension-host)" | grep -v grep >> "$LOG_FILE"
    
    echo "" >> "$LOG_FILE"
}

# Function to monitor MATLAB processes
monitor_matlab_processes() {
    echo "=== MATLAB PROCESSES ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # MATLAB processes
    ps aux | grep -i matlab | grep -v grep >> "$LOG_FILE"
    
    # Check if MATLAB is responding
    if pgrep -f "matlab" > /dev/null; then
        echo "--- MATLAB Process Status ---" >> "$LOG_FILE"
        # Try to get MATLAB process details
        pgrep -f "matlab" | xargs -I {} sh -c 'echo "PID: {}"; ps -p {} -o pid,ppid,pcpu,pmem,etime,cmd' >> "$LOG_FILE" 2>/dev/null
    fi
    
    echo "" >> "$LOG_FILE"
}

# Function to monitor network connections
monitor_network() {
    echo "=== NETWORK CONNECTIONS ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # SSH connections
    echo "--- SSH Connections ---" >> "$LOG_FILE"
    netstat -tn | grep :22 >> "$LOG_FILE"
    
    # VS Code server connections (common ports)
    echo "--- VS Code Server Connections ---" >> "$LOG_FILE"
    netstat -tln | grep -E ":(40000|50000|60000|8080|3000)" >> "$LOG_FILE"
    
    # All listening ports
    echo "--- Listening Ports ---" >> "$LOG_FILE"
    netstat -tln | head -20 >> "$LOG_FILE"
    
    echo "" >> "$LOG_FILE"
}

# Function to check for hanging processes
check_hanging_processes() {
    echo "=== HANGING PROCESS CHECK ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # Check for processes in D state (uninterruptible sleep)
    echo "--- Processes in D State ---" >> "$LOG_FILE"
    ps aux | awk '$8 ~ /D/ {print}' >> "$LOG_FILE"
    
    # Check for high CPU processes
    echo "--- High CPU Processes (>50%) ---" >> "$LOG_FILE"
    ps aux --sort=-%cpu | awk 'NR==1 || $3>50' >> "$LOG_FILE"
    
    # Check for high memory processes
    echo "--- High Memory Processes (>10%) ---" >> "$LOG_FILE"
    ps aux --sort=-%mem | awk 'NR==1 || $4>10' >> "$LOG_FILE"
    
    echo "" >> "$LOG_FILE"
}

# Function to monitor VS Code logs
monitor_vscode_logs() {
    echo "=== VS CODE LOGS ===" >> "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    
    # Find recent VS Code server logs
    VSCODE_LOG_DIR="$HOME/.vscode-server"
    if [ -d "$VSCODE_LOG_DIR" ]; then
        echo "--- Recent VS Code Server Logs ---" >> "$LOG_FILE"
        find "$VSCODE_LOG_DIR" -name "*.log" -newer "$LOG_FILE" -exec echo "File: {}" \; -exec tail -5 {} \; >> "$LOG_FILE" 2>/dev/null
    fi
    
    echo "" >> "$LOG_FILE"
}

# Function to detect MATLAB hanging
detect_matlab_hang() {
    # Create a temp file to track MATLAB command execution time
    MATLAB_TEST_FILE="/tmp/matlab_test_$$"
    
    if command -v matlab >/dev/null 2>&1; then
        # Test if MATLAB responds to a simple command
        timeout 10s matlab -nodisplay -nosplash -r "disp('test'); exit" > "$MATLAB_TEST_FILE" 2>&1 &
        MATLAB_PID=$!
        
        # Wait and check if command completed
        sleep 10
        if kill -0 $MATLAB_PID 2>/dev/null; then
            log_message "WARNING: MATLAB appears to be hanging - simple command timed out"
            kill -9 $MATLAB_PID 2>/dev/null
            echo "=== MATLAB HANG DETECTED ===" >> "$LOG_FILE"
            echo "MATLAB command timeout detected at $(date)" >> "$LOG_FILE"
            
            # Detailed process analysis when hang detected
            monitor_resources
            monitor_vscode_processes
            monitor_matlab_processes
            monitor_network
            check_hanging_processes
            
            return 1
        fi
    fi
    
    rm -f "$MATLAB_TEST_FILE"
    return 0
}

# Cleanup function
cleanup() {
    log_message "Monitoring stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main monitoring loop
main() {
    log_message "Starting VS Code/MATLAB monitoring..."
    log_message "Log file: $LOG_FILE"
    log_message "Monitoring interval: ${INTERVAL} seconds"
    
    # Initial system snapshot
    echo "=== INITIAL SYSTEM SNAPSHOT ===" >> "$LOG_FILE"
    monitor_resources
    monitor_vscode_processes
    monitor_matlab_processes
    monitor_network
    
    # Main monitoring loop
    while true; do
        sleep $INTERVAL
        
        # Regular monitoring (every interval)
        monitor_resources
        monitor_vscode_processes
        monitor_matlab_processes
        
        # Network monitoring every 3rd iteration (reduce noise)
        if [ $(($(date +%s) % (INTERVAL * 3))) -eq 0 ]; then
            monitor_network
        fi
        
        # Check for hanging processes every 6th iteration
        if [ $(($(date +%s) % (INTERVAL * 6))) -eq 0 ]; then
            check_hanging_processes
        fi
        
        # Try MATLAB hang detection every 30 seconds
        if [ $(($(date +%s) % 30)) -eq 0 ]; then
            detect_matlab_hang
        fi
        
        # Monitor VS Code logs every minute
        if [ $(($(date +%s) % 60)) -eq 0 ]; then
            monitor_vscode_logs
        fi
        
        # Add separator for readability
        echo "----------------------------------------" >> "$LOG_FILE"
    done
}

# Check if script is run with arguments
case "$1" in
    "start")
        main
        ;;
    "status")
        echo "Active monitoring processes:"
        ps aux | grep vscode_monitor.sh | grep -v grep
        echo "Log files in $LOG_DIR:"
        ls -la "$LOG_DIR"
        ;;
    "stop")
        echo "Stopping monitoring..."
        pkill -f vscode_monitor.sh
        ;;
    "logs")
        echo "Recent log files:"
        ls -t "$LOG_DIR"/*.log | head -5
        ;;
    "analyze")
        echo "Analyzing logs for patterns..."
        if [ -n "$2" ]; then
            grep -i "hang\|timeout\|error\|warning" "$LOG_DIR/$2"
        else
            grep -i "hang\|timeout\|error\|warning" "$LOG_DIR"/*.log | tail -20
        fi
        ;;
    *)
        echo "Usage: $0 {start|status|stop|logs|analyze [logfile]}"
        echo ""
        echo "Commands:"
        echo "  start   - Start monitoring (runs continuously)"
        echo "  status  - Show monitoring status and log files"
        echo "  stop    - Stop all monitoring processes"
        echo "  logs    - List recent log files"
        echo "  analyze - Search logs for issues"
        echo ""
        echo "To start monitoring in background:"
        echo "  nohup $0 start > /dev/null 2>&1 &"
        exit 1
        ;;
esac 