# Grant figures — codebase state (reproducibility)

Snapshot of the code used to generate the figures in this directory. Check out
each repo at the listed commit, then run the main file.

Generated: 2026-06-24

## Repos

| Repo | URL | Branch | Commit |
|---|---|---|---|
| vsmCenSur (this) | https://github.com/Proulx-S/vsmCenSur.git | dev | `28bde5c96c96ddaf6a3662aa565fc6401ddc4e55` |
| vfMRItools | https://github.com/Proulx-S/vfMRItools.git | main | `f79ab5fa6476ad7381229d815508b2253f27f27d` |
| vasomoTools | https://github.com/Proulx-S/vasomoTools.git | dev | `27b3d2b4566b95738204c73a46dbc521ab722073` |
| util | https://github.com/Proulx-S/util.git | dev | `891bfe100fabd8e4d0f9b0d6aa10fdaf1d4fdfaf` |

External deps (fieldtrip `external/freesurfer`, multigradient, shplot) are
auto-cloned by the path-setup block at the top of the main file; not pinned here.

## Main file to run

`doIt_vsmCenSur.m` (repo root). The path-setup block sets all dependencies
internally — no manual `addpath`.

## Where figure generation begins (after processing)

The script halts at the `return` on **line 730** (end of processing / data load).
The figure sections are the cells after it; a section exports to this directory
when its `printIt = 1` (panel A/C/D defaults to 1, panel B to 0).

| Section | Starts at line | Output files (basenames) |
|---|---|---|
| Panels A, C, D | **734** (`%% Figure for grant, panel A, C and D`) | `vsmCenSur_fullFOV`, `vsmCenSur_smallFOV`, `vsmCenSur_exampleAretry`, `vsmCenSur_exampleAretryResponse`, `vsmCenSur_exampleArteryAreaVel`, `vsmCenSur_exampleVein`, `vsmCenSur_exampleVeinResponse` |
| Panel B | **1069** (`%% Figure for grant, panel B`) | `vsmCenSur_panelB_csArteries` |

Each output is written as `.fig`, `.svg`, `.eps`, `.png`. These files are not
version-controlled (regenerable outputs); only this README is tracked here.
