# ts-based dX/X & dQ/Q on the faa time grid (the "from-ts" pipeline)

Companion to [`dQoQ_derivation.md`](dQoQ_derivation.md). Documents how the
fractional-change (`dX/X`) and volumetric-flow (`dQ/Q`) proxies are recomputed
from the **raw timeseries**, onto the **same stimulus-onset time grid as faa**, so
they can be overlaid on — and compared against — the deconvolution-based proxies.

## Motivation

Two different time grids were in play:

| quantity | source | grid |
|---|---|---|
| `respDoD`, `respVoV`, `respQoQ*` (solid lines) | `resp` = AFNI `3dDeconvolve` IRF | deconvolution **response grid** |
| `faa` timecourse | `ts` raw timeseries, sliding window | onset-aligned **faa grid** |

`dX/X` and `dQ/Q` lived on the response grid; `faa` on the faa grid. To compare them
in time, recompute `dX/X` / `dQ/Q` **the way faa is computed — by indexing the raw
timeseries into onset-relative windows.**

## Functions (all in `tools/vfMRItools/`)

```
getAreaDiamVelFlowProxy   ts -> tsArea/tsVel/tsDiam + dA/A,dV/V,dD/D,dQ/Q  (per-run [vox x time], baseline = .vecBase)
        |
indexTs2Trial             design + dN -> onset-aligned grid + per-window pooled [run x time] column indices
        |
getAreaDiamVelFlowFaaProxyFromTs   window the ts proxies -> per-window mean (+ SEM) on the faa grid
        |
getFaa2                   faa per window from the pooled dV/V-vs-dD/D slope (same windows)
```

- **`indexTs2Trial(vessel, rCond, dN)`** — the indexing core extracted from `getFaa`
  (`getAlign` + `getIdx`), made reusable and proxy-agnostic. Builds/reuses the
  onset-aligned grid and returns, per window, the pooled `[run × time]` column
  indices (`winCols`) and their onset-relative times. Stored in `vessel.trial`
  (`.align`, `.res(k).{dN,winCols,winTT,t,tStart,tEnd}`). `getFaa.m` is left
  untouched, so the two copies of the indexing logic must be kept in sync by hand.

- **`getAreaDiamVelFlowFaaProxyFromTs(vessel, rCond, dN)`** — windows the raw-ts
  proxies. Each window value is the **mean over its pooled `(run × column)` points**;
  the **SEM over that same pool** is stored alongside as the per-window error. Output
  in `vessel.fromTs`: `.t` (the faa grid) and `.<name>.mean / .sem` for `<name>` in
  `Area,Vel,Diam` (raw) and `AoA,VoV,DoD,QoQe,QoQa` (dX/X & dQ/Q). Also calls
  `getFaa2`.

- **`getFaa2(vessel)`** — faa per window from the `poly1` slope of pooled `dV/V` vs
  `dD/D` over the `indexTs2Trial` windows. Output `vessel.faa2`, mirroring
  `vessel.faa`. **Reproduces `getFaa` exactly** (validated: `max|faa2 − faa| = 0`
  across all vessels, `faa2.all == faa.all`).

## Baseline & pooling (why this matches faa)

Averaging pools the **already per-run-baseline-normalized** `dX/X` points
(`tsDoD` etc., baseline `= .vecBase`), not the raw proxies — so each run stays on its
own baseline, exactly as `faa` pools per-run `dD/D` & `dV/V` points before fitting.
(`dQ/Q` at the window level is the mean of the point-wise
`(1+dV/V)(1+dA/A)−1`, not the exact form of the window-mean `dV/V`/`dA/A` — consistent
with treating each pooled point equally.)

## doIt usage (`doIt_vsmCenSur.m`, dV/dD section)

- Flag **`showTs`** (default `true`) in the flags block before `%% dV/dD`.
- `getAreaDiamVelFlowFaaProxyFromTs(...)` is called in the proxy loop, right after
  `getAreaDiamVelFlowProxy` / `getFaa`.
- When `showTs`, the ts-based `dD/D`, `dV/V` (tile-1) and `dQ/Q` (green panel) are
  overlaid as **dotted lines of the matching color**, on both per-vessel and summary
  figures. The faa panels are unchanged (faa is already ts-based). The per-window SEM
  is computed and stored but not plotted.

## Notes

- Per-vessel dotted overlays are visibly **noisier** than the smooth resp/IRF curves
  (raw windowed `ts` vs deconvolution); the summary (vessel-averaged) is smoother.
- For `intType = 'X'/'Y'`, the green dotted overlay is the `faa2` fit intercept
  (`xint`/`yint`), which *is* a windowed quantity; for `intType = 'Q*'` it is the
  windowed `dQ/Q`.
