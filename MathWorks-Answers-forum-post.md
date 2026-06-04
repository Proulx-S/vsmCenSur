# MATLAB Answers / forum post

## Title
```
MathWorks Service Host pegs CPU in a crash-loop on Ubuntu 24.04 (R2025a): libxslt undefined symbol xmlCtxtParseDocument
```

## Tags
`matlab` `linux` `ubuntu` `mathworks-service-host` `r2025a` `installation`

## Body
```
On Ubuntu 24.04.2 LTS (kernel 6.17, x86_64) running MATLAB R2025a, the MathWorks Service Host
"companion" daemon sits in a continuous crash/respawn loop: it pegs 150-240% CPU and writes a
~5 MB log file to ~/.MathWorks/ServiceHost/<host>/logs/ roughly once per second. The MATLAB
compute engine itself works fine — it's only the companion connector that's broken.

Setup: MATLAB is launched through the MATLAB extension for Visual Studio Code
(MathWorks.language-matlab) over Remote-SSH on a headless server. The crash-looping companion
is launched by the extension's language-server MATLAB (its ServiceHost client-v1 is the parent).
To be clear, the defect is in the ServiceHost library loading (below), not the extension — the
extension is just what triggers the companion launch.

Quick check:
  ps -eo pid,pcpu,args | grep 'MathWorksServiceHost service' | grep -v grep
  ls -t ~/.MathWorks/ServiceHost/*/logs/*.log | head    # new ~5MB log every second

ROOT CAUSE
The service log shows:
  Error loading .../glnxa64/foundation/secrets_store/.../libmwflsecretsstorexmlsec.so.
  .../glnxa64/libxslt.so.1: undefined symbol: xmlCtxtParseDocument

The Service Host's bundled libxslt.so.1.1.43 needs xmlCtxtParseDocument, a symbol that only
exists in libxml2 >= 2.13. MathWorks ships libxml2.so.2.13.8 in the same glnxa64 folder, but
the daemon launches with an EMPTY LD_LIBRARY_PATH, so the dynamic loader binds the SYSTEM
libxml2 instead — Ubuntu 24.04 ships 2.9.14, which lacks the symbol. So secrets_store fails
to load, the framework aborts, and it respawns forever.

Confirmed via /proc/<pid>/maps — the broken pairing is actually mapped into the daemon:
  .../glnxa64/libxslt.so.1.1.43        (bundled)
  /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.14   (system, wrong)

WORKAROUND (forces the daemon to use the bundled libxml2 2.13.8)
Wrap the launcher so it sets LD_LIBRARY_PATH to its own glnxa64 dir before exec:

  cd ~/.MathWorks/ServiceHost/-mw_shared_installs/<version>/bin/glnxa64
  mv MathWorksServiceHost MathWorksServiceHost.real
  cat > MathWorksServiceHost <<'EOF'
  #!/bin/sh
  DIR="$(dirname "$0")"
  export LD_LIBRARY_PATH="$DIR:$LD_LIBRARY_PATH"
  exec "$DIR/MathWorksServiceHost.real" "$@"
  EOF
  chmod +x MathWorksServiceHost

(Reversible: delete the wrapper and rename .real back. Note a Service Host auto-update may
overwrite the wrapper — and may also ship a real fix.)

Note: deleting ~/.config/autostart/mathworks-service-host.desktop does NOT help — the service
still launches when MATLAB starts.

Has anyone else hit this on Ubuntu 24.04 / other distros with system libxml2 < 2.13? I've also
filed it via Technical Support as a bug. Posting here for visibility and in case others need the
workaround.
```

---

NOTES (not for posting)
- Replace <version> with the actual install version (current: v2025.11.0.2).
- The workaround above is the same wrapper-shim fix discussed earlier; it has NOT been applied
  on takoyaki (you chose "leave it / report only"). It's included here only because a public
  post is far more useful with a workaround others can copy.
- If you'd rather not publish a workaround that edits the install, delete the WORKAROUND block
  and keep just the root cause + "has anyone else seen this / reported as a bug" framing.
