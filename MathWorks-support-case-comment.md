# MathWorks support case — follow-up comment (VS Code extension launch path)

Paste this as a comment on the existing case:

```
Additional detail on how the companion is launched in my setup:

MATLAB is started through the MATLAB extension for Visual Studio Code
(MathWorks.language-matlab) over Remote-SSH on a headless server. The crash-looping
ServiceHost companion daemon is launched by the extension's language-server MATLAB
process — I confirmed that the ServiceHost "client-v1" process is a direct child of the
language-server MATLAB (matlabls), e.g.:

  client-v1 PID 3107433  <-  parent PID 1965932  (.../R2025a/bin/glnxa64/MATLAB ... initmatlabls ...)

To be clear, this is just the launch path that requests the companion — the actual defect
is still the ServiceHost library-loading failure described in the original report (bundled
libxslt.so.1 binding the system libxml2.so.2.9.14, which lacks xmlCtxtParseDocument, instead
of the bundled libxml2.so.2.13.8). The extension is the trigger, not the cause; the same
defect would affect any launch path that starts the companion on a system with libxml2 < 2.13.
```
