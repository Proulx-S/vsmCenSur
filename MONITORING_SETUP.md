# VS Code/MATLAB Hanging Issue Monitoring Setup

Based on research of similar issues reported online, this monitoring setup will help identify what causes your intermittent MATLAB shell hanging problem with Remote-SSH connections.

## Quick Start

1. **Copy scripts to your remote server:**
   ```bash
   # Upload these files to your remote server
   scp vscode_monitor.sh simple_log_collector.sh user@your-server:~/
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x vscode_monitor.sh simple_log_collector.sh
   ```

3. **Start monitoring before your coding session:**
   ```bash
   # Start continuous monitoring in background
   nohup ./vscode_monitor.sh start > /dev/null 2>&1 &
   ```

4. **When hanging occurs, collect logs:**
   ```bash
   ./simple_log_collector.sh
   ```

## What the Research Found

### Similar Issues Reported:
- **Jupyter Extension Hanging**: Users report 20-80 minute intervals before hanging
- **High Latency Correlation**: Issues more common with 100ms+ latency connections  
- **Resource Exhaustion**: Extensions consuming excessive memory on remote servers
- **Extension-Specific**: MATLAB, Python, and Jupyter extensions frequently involved

### Common Root Causes:
1. **Memory pressure** on remote server (VS Code server needs 1GB+ RAM)
2. **Extension resource usage** (especially language servers)
3. **Network latency** affecting communication between client and server
4. **SSH connection multiplexing** issues

## Monitoring Scripts

### 1. `vscode_monitor.sh` - Continuous Monitoring
Tracks system resources, processes, and network connections every 5 seconds.

**Usage:**
```bash
./vscode_monitor.sh start    # Start monitoring
./vscode_monitor.sh status   # Check status
./vscode_monitor.sh stop     # Stop monitoring
./vscode_monitor.sh analyze  # Analyze logs for issues
```

**What it monitors:**
- System memory, CPU, disk usage
- VS Code server processes
- MATLAB processes
- Network connections
- Hanging process detection
- MATLAB responsiveness testing

### 2. `simple_log_collector.sh` - Incident Collection
Collects logs and system state when hanging occurs.

**Usage:**
```bash
./simple_log_collector.sh
```

**What it collects:**
- Current system state
- VS Code server logs
- Extension logs
- Process information
- Network connections

## Recommended Troubleshooting Steps

### Immediate Actions When Hanging Occurs:

1. **Don't restart VS Code yet** - collect data first:
   ```bash
   ./simple_log_collector.sh
   ```

2. **Check MATLAB directly on server:**
   ```bash
   matlab -nodisplay -nosplash -r "disp('test'); exit"
   ```

3. **Check system resources:**
   ```bash
   free -h
   top -bn1 | head -10
   ```

4. **Check VS Code processes:**
   ```bash
   ps aux | grep -E "(vscode|node)" | grep -v grep
   ```

### Potential Solutions to Try:

#### 1. Extension Management
```bash
# Temporarily disable MATLAB extension in VS Code
# Go to Extensions → MATLAB → Disable
```

#### 2. VS Code Settings
Add to your VS Code `settings.json`:
```json
{
  "remote.SSH.useLocalServer": false,
  "remote.SSH.showLoginTerminal": true,
  "remote.SSH.useExecServer": false,
  "remote.SSH.serverInstallPath": {
    "your-server": "~/.vscode-server-custom"
  }
}
```

#### 3. SSH Configuration
Add to your `~/.ssh/config`:
```
Host your-server
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

#### 4. Resource Monitoring
```bash
# Monitor memory usage continuously
watch -n 2 'free -h; echo ""; ps aux | grep vscode | head -5'
```

## Log Analysis

### Key Patterns to Look For:

1. **Memory exhaustion:**
   ```bash
   grep -i "out of memory\|oom\|killed" ~/vscode_monitor_logs/*.log
   ```

2. **Connection timeouts:**
   ```bash
   grep -i "timeout\|connection\|lost" ~/vscode_monitor_logs/*.log
   ```

3. **Extension errors:**
   ```bash
   grep -i "extension\|matlab\|error" ~/vscode_monitor_logs/*.log
   ```

4. **Process hanging:**
   ```bash
   grep -i "hang\|unresponsive\|D state" ~/vscode_monitor_logs/*.log
   ```

### Timeline Correlation:
Compare timestamps between:
- When you notice MATLAB hanging
- System resource spikes
- VS Code server log entries
- Network connection changes

## Advanced Debugging

### Enable VS Code Debug Logging:
1. In VS Code, open Command Palette (Ctrl+Shift+P)
2. Run "Developer: Set Log Level"
3. Select "Debug"
4. Check "Remote-SSH" output panel during hangs

### Network Monitoring:
```bash
# Monitor latency during sessions
ping -i 1 your-server | ts '[%Y-%m-%d %H:%M:%S]' >> ping_log.txt &

# Monitor bandwidth usage
iftop -i eth0 -t -s 10 >> network_usage.log &
```

### MATLAB-Specific Debugging:
```bash
# Test MATLAB responsiveness
timeout 30s matlab -nodisplay -nosplash -r "disp(datetime); exit"

# Monitor MATLAB processes
watch -n 5 'ps aux | grep matlab'
```

## Data Collection for Support

When reporting the issue, include:

1. **System Information:**
   - Remote server specs (RAM, CPU, OS)
   - Network latency to server
   - VS Code and extension versions

2. **Monitoring Data:**
   - Logs from before, during, and after hanging
   - Resource usage patterns
   - Timeline of events

3. **Reproduction Steps:**
   - What you were doing when hanging occurred
   - How long into the session it happened
   - Any patterns you've noticed

## Cleanup

To clean up monitoring:
```bash
# Stop monitoring
./vscode_monitor.sh stop

# Clean old logs (keeps last 7 days)
find ~/vscode_monitor_logs -name "*.log" -mtime +7 -delete
find ~/vscode_debug_logs -name "*.txt" -mtime +7 -delete
```

## Next Steps

1. **Start monitoring** before your next coding session
2. **Collect data** when hanging occurs (don't restart immediately)
3. **Analyze patterns** in the logs
4. **Try suggested solutions** one at a time
5. **Document results** to identify what works

The goal is to correlate the hanging with specific system events, resource usage, or network conditions to identify the root cause. 