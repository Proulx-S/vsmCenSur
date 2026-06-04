# MathWorks "Report a bug" form — field-by-field fill guide

Companion file: `MathWorks-ServiceHost-bugreport.md` (full report)
Attach file:    `MathWorksServiceHost_crashloop_sample.log` (3.5 MB, one full crash-cycle log)

---

## Subject *(required)*
```
MathWorks Service Host companion daemon crash-loops at 150%+ CPU on Ubuntu 24.04 — bundled libxslt binds system libxml2 (missing xmlCtxtParseDocument)
```

## Product
`MATLAB`

## Release
`R2025a`

## How frequently do you encounter this issue?
`Always` (continuous respawn loop — never not happening once MATLAB starts)

## Description
```
ENVIRONMENT
- Ubuntu 24.04.2 LTS, kernel 6.17.0-29-generic, x86_64
- MATLAB R2025a; MathWorks Service Host v2025.11.0.2
- System libxml2: 2.9.14+dfsg-1.3ubuntu3.7
- Headless server via VS Code Remote-SSH; MATLAB launched through the MATLAB extension for Visual
  Studio Code (MathWorks.language-matlab). The crash-looping companion daemon is launched by the
  extension's language-server MATLAB (its ServiceHost client-v1 is the parent). NOTE: defect is in
  ServiceHost library loading (below), not the extension — the extension is just the launcher.

STEPS TO REPRODUCE
1. Run MATLAB R2025a on a Linux host whose system libxml2 is < 2.13 (e.g. Ubuntu 24.04, which ships 2.9.14).
2. Observe the companion service:
   ps -eo pid,pcpu,args | grep 'MathWorksServiceHost service'

EXPECTED
ServiceHost companion starts once and idles.

ACTUAL
'MathWorksServiceHost service --realm-id companion@prod@production --detached' crash-loops:
150-240% CPU, new PID ~every second, writing a ~5 MB log to ~/.MathWorks/ServiceHost/<host>/logs/ roughly once per second.

ROOT CAUSE (confirmed)
The secrets_store component's bundled libxslt.so.1.1.43 needs symbol xmlCtxtParseDocument
(libxml2 >= 2.13). MathWorks ships libxml2.so.2.13.8 in the same glnxa64 dir, but the daemon
launches with an empty LD_LIBRARY_PATH, so the loader binds the SYSTEM libxml2.so.2.9.14, which
lacks the symbol. libmwflsecretsstorexmlsec.so fails to load -> framework aborts -> respawn loop.

Log error:
  Error loading .../glnxa64/foundation/secrets_store/.../libmwflsecretsstorexmlsec.so.
  .../glnxa64/libxslt.so.1: undefined symbol: xmlCtxtParseDocument

Evidence (/proc/<pid>/maps shows the broken pairing actually mapped):
  .../glnxa64/libxslt.so.1.1.43   (bundled)
  /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.14   (system — wrong)
With LD_LIBRARY_PATH pointed at the bundled glnxa64 dir, libxslt correctly resolves the bundled
libxml2.so.2.13.8 and the component loads.

SUGGESTED FIX
Ensure the Service Host launches with its bundled glnxa64 ahead of system paths (LD_LIBRARY_PATH/
RUNPATH), or privately-version the bundled libxml2 SONAME, so libxslt cannot bind the system libxml2
when the bundled one is required.
```

## Attach
`/scratch/users/Proulx-S/vsmCenSur/MathWorksServiceHost_crashloop_sample.log`
(one full crash-cycle log containing the `undefined symbol` error; filename sequence number ~5175620,
written ~1/sec — evidence the loop is continuous, not intermittent)

## Email address
`proulxs@stanford.edu`
