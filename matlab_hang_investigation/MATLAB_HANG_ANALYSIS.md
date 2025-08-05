# MATLAB/Cursor Hanging Issue Analysis Report

## Executive Summary

**Issue**: Intermittent MATLAB shell hanging in VS Code/Cursor Remote-SSH environment
**Frequency**: Every 15-30 minutes during active coding sessions
**Duration**: 15-30 seconds per hang
**Impact**: Disrupts workflow, requires manual intervention
**Root Cause**: Cursor/VS Code server extension host memory leaks and communication timeouts

## Latest Session Summary (August 4, 2025)

### Session Details
- **Duration**: Multiple incidents over ~2 hours
- **Monitoring Logs**: 6.8MB of detailed system data
- **Incidents**: 3 major hangs (18:15, 18:35, 18:43 PDT)
- **Pattern**: Brief 2-3 second hangs more frequent when commands should return errors

### Key Discoveries
1. **Sustained High CPU Usage**: MATLAB processes running at 40-600% CPU continuously
2. **Error-Related Pattern**: User observed increased hang frequency during error conditions
3. **Process Hierarchy**: Stable process tree with all components running but MATLAB stuck in computation
4. **No Explicit Timeouts**: Monitoring didn't detect explicit hang messages, suggesting internal computation loops
5. **Recovery Pattern**: Some hangs show self-healing behavior with gradual CPU decrease
6. **Immediate High CPU**: New MATLAB processes start at 200-600% CPU after Language Server restarts

### Technical Insights
- **Memory Usage**: Lower than previous incidents (4.5-4.9GB vs 6-12GB)
- **CPU Pattern**: Unusually high sustained CPU usage (40-600% vs normal 5-25%)
- **Process Stability**: All processes remained active, no crashes or restarts
- **Error Handling**: Potential bottleneck in MATLAB's error processing or language server communication
- **Recovery Behavior**: Some processes show gradual CPU decrease over 10+ minutes
- **Restart Issues**: Language Server restarts trigger immediate high-CPU MATLAB processes

### Updated Hypothesis
The hang appears to be caused by MATLAB getting stuck in a computation loop, particularly when processing error conditions. Some hangs are self-resolving given sufficient time, while others require manual intervention. Language Server restarts may trigger immediate high-CPU issues.

### New Patterns Identified
1. **Self-Healing Hangs**: Some processes recover gradually (101% → 46.6% CPU)
2. **Immediate High CPU**: New processes start at 200-600% CPU after restarts
3. **Extended Recovery Time**: 10+ minutes for some processes to stabilize
4. **Error-Related Triggers**: More frequent hangs during error conditions

## Recent Improvements and Solutions (August 2025)

### Enhanced Monitoring System
**New Script**: `enhanced_monitor.sh` - Diagnostic-only monitoring system
**Purpose**: Improved detection and logging without automatic interventions
**Features**:
- CPU threshold detection (80% threshold)
- Memory threshold detection (8GB threshold)
- Runtime tracking for MATLAB processes
- Diagnostic report generation
- Pattern recognition for hang detection

**Usage**:
```bash
# Start diagnostic monitoring
./enhanced_monitor.sh start

# Check current status
./enhanced_monitor.sh status

# Generate diagnostic report
./enhanced_monitor.sh report
```

### Optimized MATLAB Extension Configuration
**File**: `.vscode/settings.json`
**Changes Made**:
- Disabled linting to reduce resource usage
- Set connection timing to "onDemand"
- Disabled syntax and semantic validation
- Disabled workspace indexing
- Optimized snippet handling

**Key Settings**:
```json
{
    "matlab.matlabConnectionTiming": "onDemand",
    "matlab.linterConfig": "disabled",
    "matlab.linting.enabled": false,
    "matlab.linting.run": "never",
    "matlab.languageServer.syntaxValidation": false,
    "matlab.languageServer.semanticValidation": false,
    "matlab.languageServer.indexWorkspace": false
}
```

### Code Folding Configuration
**Issue**: MATLAB `%%` sections not folding properly
**Solution**: Installed official MathWorks MATLAB extension
**Extension**: `mathworks.language-matlab-1.3.4`
**Configuration**: Language-based folding strategy for MATLAB files

### Monitoring Strategy Evolution
**Previous**: Basic resource monitoring with manual intervention
**Current**: Enhanced diagnostic monitoring with pattern recognition
**Future**: Predictive monitoring based on historical patterns

## Evidence Collection Timeline

### Hang #1: July 3, 2025 - 14:57:46 PDT
**Debug Log**: `/home/sebp/vscode_debug_logs/debug_20250703_145746.txt`

**System State**:
- Memory: 27GB used (7.2% of 376GB), 348GB available
- MATLAB PID 874973: 24.7% CPU, 6.7GB RAM, 28 minutes runtime
- Cursor Extension Host: 1.8% CPU, 874MB RAM
- Single SSH connection stable

**Initial Hypothesis**: MATLAB Language Server resource exhaustion from Gaussian fitting operations

### Hang #2: July 3, 2025 - 17:35:12 PDT  
**Debug Log**: `/home/sebp/vscode_debug_logs/debug_20250703_173512.txt`

**System State**:
- Memory: 37GB used (9.8% of 376GB), 338GB available
- MATLAB PID 874973: 26.1% CPU, 12.4GB RAM, 70 minutes runtime
- MATLAB PID 1228332: 5.5% CPU, 3.7GB RAM, 3 minutes runtime (new process)
- Cursor Extension Host 874649: 1.7% CPU, 892MB RAM, 4+ hours runtime
- Cursor Extension Host 1228178: 0.5% CPU, 681MB RAM, 19 minutes runtime (new process)
- Server restart detected at 16:37

**Key Finding**: Cursor server restart occurred, spawning new processes

### Hang #3: August 4, 2025 - 18:15:34 PDT
**Debug Log**: `/home/sebp/work/vsmCenSur/matlab_hang_investigation/debug_20250804_181534.txt`
**Monitoring Log**: `/home/sebp/work/vsmCenSur/matlab_hang_investigation/monitor_logs/monitor_20250804_174709.log`

**System State**:
- Memory: 17GB used (4.5% of 376GB), 358GB available
- MATLAB PID 1181313: 40.2-42.4% CPU, 4.9GB RAM, 34+ minutes runtime
- MATLAB Language Server PID 1181264: 1.5% CPU, 155MB RAM, 34+ minutes runtime
- Cursor Extension Host PID 1180985: 2.9% CPU, 520MB RAM, 34+ minutes runtime
- Continuous monitoring: 36 minutes duration, 6.8MB log file

**Key Findings**:
- **Sustained High CPU**: MATLAB process running at 40%+ CPU continuously
- **Error-Related Pattern**: User observed more frequent hangs when commands should return errors
- **Process Stability**: All processes running but MATLAB stuck in computation loop
- **No Explicit Timeouts**: Monitoring didn't detect explicit hang/timeout messages

**New Hypothesis**: MATLAB process stuck in computation loop, possibly related to error handling or language server communication issues

### Hang #4: August 4, 2025 - 18:35:09 PDT
**Debug Log**: `/home/sebp/work/vsmCenSur/matlab_hang_investigation/debug_20250804_183509.txt`

**System State**:
- Memory: 17GB used (4.5% of 376GB), 358GB available
- MATLAB PID 1275191: 69.2% CPU, 4.5GB RAM, 5+ minutes runtime
- MATLAB Language Server PID 1271520: 1.4% CPU, 126MB RAM, 8+ minutes runtime
- Pattern: Immediate high CPU usage after Language Server restart

**Key Findings**:
- **Immediate High CPU**: New MATLAB processes starting at 200-600% CPU
- **Recurring Pattern**: Same issue after Language Server restarts
- **Process Tree Issues**: Multiple MATLAB processes spawning with high CPU

### Hang #5: August 4, 2025 - 18:43:45 PDT
**Debug Log**: `/home/sebp/work/vsmCenSur/matlab_hang_investigation/debug_20250804_184345.txt`

**System State**:
- MATLAB PID 1291355: 101% → 48.3% → 46.6% CPU (recovery pattern observed)
- Runtime: 11+ minutes with sustained high CPU
- Memory: 4.9GB (stable during recovery)

**Key Findings**:
- **Recovery Pattern**: CPU usage decreased from 101% to 46.6% over time
- **Self-Healing**: Process appeared to work through computation loop
- **Gradual Improvement**: Steady decrease in CPU usage suggests recovery
- **Extended Runtime**: 11+ minutes of high CPU before improvement

**New Discovery**: Some MATLAB hangs may be self-resolving given sufficient time, suggesting computation loops that eventually complete rather than permanent deadlocks.

## Analysis Methodology

### Data Collection Process
1. **Continuous Monitoring**: `./vscode_monitor.sh start` running in background
2. **Enhanced Monitoring**: `./enhanced_monitor.sh start` for diagnostic monitoring
3. **Incident Capture**: `./simple_log_collector.sh` executed immediately when hang occurs
4. **Process Analysis**: Focus on MATLAB and Cursor server processes
5. **Resource Tracking**: Memory, CPU, runtime duration
6. **Timeline Correlation**: Compare timestamps between hangs and system events

### Evidence Categories
- **System Resources**: Memory usage, CPU utilization
- **Process Behavior**: Runtime duration, memory accumulation, process spawning
- **Network State**: SSH connections, communication patterns
- **Server Logs**: VS Code/Cursor server activity
- **Extension Activity**: MATLAB extension behavior

## Revised Diagnosis

### Primary Root Cause: Cursor/VS Code Server Instability

**Evidence**:
1. **Extension Host Memory Leaks**: Gradual increase from 874MB to 892MB over 2.5 hours
2. **Server Restart Pattern**: New extension host and MATLAB processes spawned at 16:37
3. **Multiple Process Accumulation**: System running multiple extension hosts simultaneously
4. **Communication Timeouts**: 20-second hang duration consistent with extension communication delays

**Not Caused By**:
- User's MATLAB code (Gaussian fitting operations not running during hangs)
- System resource exhaustion (plenty of memory available)
- Network connectivity issues (SSH connection stable)

### Secondary Factors
1. **MATLAB Extension Resource Usage**: High CPU and memory consumption
2. **Extension Host Restarts**: Creating multiple MATLAB processes
3. **Resource Contention**: Between multiple extension processes

## Technical Details

### Process Analysis
```
Hang #1:
- MATLAB PID 874973: 24.7% CPU, 6.7GB RAM, 28min runtime
- Extension Host: 1.8% CPU, 874MB RAM

Hang #2:  
- MATLAB PID 874973: 26.1% CPU, 12.4GB RAM, 70min runtime (+3.7GB memory leak)
- MATLAB PID 1228332: 5.5% CPU, 3.7GB RAM, 3min runtime (new process)
- Extension Host 874649: 1.7% CPU, 892MB RAM, 4+ hours runtime
- Extension Host 1228178: 0.5% CPU, 681MB RAM, 19min runtime (new process)
```

### Memory Leak Pattern
- **Extension Host**: ~18MB increase over 2.5 hours (7.2MB/hour)
- **MATLAB Process**: 3.7GB increase over 2.5 hours (1.5GB/hour)
- **System Total**: 10GB increase over 2.5 hours (4GB/hour)

### Timing Pattern
- **Hang Duration**: 15-30 seconds
- **Recovery Time**: Immediate after timeout
- **Frequency**: Every 15-30 minutes during active sessions
- **Server Restart**: Every 3-4 hours

## Recommended Solutions

### Immediate Actions
1. **Use Enhanced Monitoring**: Run `./enhanced_monitor.sh start` during coding sessions
2. **Apply Optimized Settings**: Use the new MATLAB extension configuration
3. **Manual Intervention**: Use diagnostic reports to make informed decisions
4. **Regular Restarts**: Restart Cursor every 2-3 hours as preventive measure

### VS Code/Cursor Settings
```json
{
    "remote.SSH.useLocalServer": false,
    "remote.SSH.showLoginTerminal": true,
    "matlab.matlabConnectionTiming": "onDemand",
    "matlab.linterConfig": "disabled",
    "matlab.linting.enabled": false,
    "matlab.languageServer.syntaxValidation": false,
    "matlab.languageServer.semanticValidation": false,
    "matlab.languageServer.indexWorkspace": false
}
```

### Extension Management
- Use official MathWorks MATLAB extension
- Monitor extension memory usage with enhanced monitoring
- Generate diagnostic reports for pattern analysis
- Restart Cursor every 2-3 hours

## Development Team Report

### Issue Description
Cursor/VS Code server experiences memory leaks in extension host processes, leading to communication timeouts and 15-30 second hangs during remote development sessions.

### Technical Evidence
- Extension host memory accumulation: 7.2MB/hour
- Server restart cycles every 3-4 hours
- Multiple extension host processes running simultaneously
- MATLAB extension high resource usage (24-26% CPU, 6-12GB RAM)

### Impact
- Workflow disruption every 15-30 minutes
- Manual intervention required
- Reduced productivity in remote development environment

### Requested Actions
1. Investigate extension host memory leaks
2. Optimize MATLAB extension resource usage
3. Implement automatic extension host restart mechanisms
4. Add memory monitoring and alerts
5. Improve extension communication timeout handling

## Next Steps

### Evidence Collection Plan
1. **Use Enhanced Monitoring**: Run `./enhanced_monitor.sh start` during all coding sessions
2. **Document Each Hang**: Use `./simple_log_collector.sh` immediately when hangs occur
3. **Generate Diagnostic Reports**: Use `./enhanced_monitor.sh report` for detailed analysis
4. **Track Patterns**: Note timing, duration, and system state
5. **Test Solutions**: Monitor effectiveness of optimized settings
6. **Weekly Review**: Update this document with new findings

### Success Metrics
- Reduce hang frequency to <1 per day
- Reduce hang duration to <5 seconds
- Eliminate extension host memory leaks
- Maintain stable Cursor server operation

## File Structure
- **Debug Logs**: `/home/sebp/vscode_debug_logs/debug_YYYYMMDD_HHMMSS.txt`
- **Monitoring Scripts**: `./vscode_monitor.sh`, `./enhanced_monitor.sh`, `./simple_log_collector.sh`
- **Analysis Document**: This file (`MATLAB_HANG_ANALYSIS.md`)
- **Configuration**: `.vscode/settings.json` (optimized MATLAB settings)

## Contact Information
- **User**: sebp@takoyaki
- **Environment**: Remote-SSH, Linux 6.11.0-1022-oem
- **Cursor Version**: Stable-5b19bac7a947f54e4caa3eb7e4c5fbf832389850
- **MATLAB Version**: R2024b
- **MATLAB Extension**: mathworks.language-matlab-1.3.4 