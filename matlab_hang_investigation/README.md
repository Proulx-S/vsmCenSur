# MATLAB Hanging Issue Investigation

This directory contains all tools and logs for investigating the MATLAB hanging issue in VS Code/Cursor Remote-SSH environment.

## Directory Structure

```
matlab_hang_investigation/
├── README.md                           # This file
├── MATLAB_HANG_ANALYSIS.md            # Main analysis and report document
├── vscode_monitor.sh                   # Continuous monitoring script
├── simple_log_collector.sh             # Incident log collector
├── monitor_logs/                       # Continuous monitoring logs (created automatically)
│   └── monitor_YYYYMMDD_HHMMSS.log    # Individual monitoring session logs
├── debug_YYYYMMDD_HHMMSS.txt          # Incident-specific debug logs
└── [other analysis files...]
```

## Quick Start

### 1. Start Continuous Monitoring
```bash
cd matlab_hang_investigation
./vscode_monitor.sh start
```

### 2. When a Hang Occurs
```bash
./simple_log_collector.sh
```

### 3. Check Monitoring Status
```bash
./vscode_monitor.sh status
```

### 4. Stop Monitoring
```bash
./vscode_monitor.sh stop
```

## Scripts

### vscode_monitor.sh
**Purpose**: Continuous monitoring of system resources and processes
**Usage**:
- `./vscode_monitor.sh start` - Start monitoring
- `./vscode_monitor.sh status` - Check status
- `./vscode_monitor.sh stop` - Stop monitoring
- `./vscode_monitor.sh logs` - List log files
- `./vscode_monitor.sh analyze` - Search for issues

**What it monitors**:
- System memory, CPU, disk usage
- VS Code/Cursor server processes
- MATLAB processes
- Network connections
- Hanging process detection

### simple_log_collector.sh
**Purpose**: Collect system state when hanging occurs
**Usage**: `./simple_log_collector.sh`

**What it collects**:
- Current system state
- Active processes
- Network connections
- VS Code server logs
- Extension logs

## Log Files

### Continuous Monitoring Logs
- **Location**: `monitor_logs/monitor_YYYYMMDD_HHMMSS.log`
- **Content**: Regular system snapshots every 5 seconds
- **Use**: Track resource usage patterns over time

### Incident Debug Logs
- **Location**: `debug_YYYYMMDD_HHMMSS.txt`
- **Content**: System state at time of hang
- **Use**: Analyze specific hang incidents

## Analysis Workflow

1. **Start monitoring** before coding session
2. **Document each hang** immediately with log collector
3. **Update analysis** in `MATLAB_HANG_ANALYSIS.md`
4. **Track patterns** across multiple incidents
5. **Generate report** for development team

## File Naming Convention

- **Monitoring logs**: `monitor_YYYYMMDD_HHMMSS.log`
- **Debug logs**: `debug_YYYYMMDD_HHMMSS.txt`
- **Analysis documents**: `*_ANALYSIS.md`

## Notes

- All logs are now stored in this directory for easy organization
- Scripts automatically detect their location and create subdirectories as needed
- Old logs from `$HOME/vscode_*_logs` have been moved here
- New logs will be created in this directory structure 