# Why the dVdA figures differ from the local `%% dV/dD` figures

**Date:** 2026-06-07 (overnight investigation)
**TL;DR:** It is **not** a time-window indexing bug. The indexing in `getFaa.m`
is *identical* to the inline indexing in `dVdA/doIt.m` — they agree to machine
precision (max diff = 0) at every matched window. **The figures differ because
of the regression fit type:**

- **dVdA reference (`doIt.m`)** fits `dV/V` vs `dD/D` with **`'poly1'`** — a line
  with a **free intercept**.
- **local refactor (`getFaa.m`)** fits with **`fittype({'x'})`** — a line forced
  **through the origin** (intercept = 0).

Because `faa = 1/2 - 1/4 * slope`, and the windowed data clouds (during-stim,
post-stim, sliding window) are **offset from the origin**, the two fits return
different slopes → different faa → different figures.

---

## How this was established

Repo cloned to `/tmp/dvda-investigation/dVdA`. Inputs `vsmCenSur.mat` + `dsgn.mat`
feed both pipelines. Proxies were computed **once** (via `getAreaDiamVelProxy`) and
fed to **both** FAA algorithms, so any difference is purely in the FAA step.
Scripts: `compareFaa.m`, `compareFaa2.m`, `diagFigs.m` in the clone.

### 1. Indexing is identical
Re-implemented the dVdA inline sliding-window / stim / post indexing faithfully
from `doIt.m`, then forced it to use the **same slope-only fit** as `getFaa`:

| window | `max | slopeOnly(dVdA-indexing) − getFaa |` |
|---|---|
| during-stim | **0** |
| sliding-window timecourse (matched centers) | **0** |
| post-stim | 0.0077 (purely the window-range diff below) |

So the onset alignment, `idxTrialOnset`/`idxRunOnset`, and window pooling all
match. **The indexing you suspected is fine.**

### 2. Fit type is the cause
Same indexing, only the fit changes:

| window | `max | poly1(dVdA) − getFaa(slope-only) |` |
|---|---|
| during-stim | **0.121** (vessel 6: 0.635 → 0.756) |
| sliding timecourse | **0.134** |
| post-stim | ~0.02 |
| **all timepoints** | **1.1e-16** (identical) |

The "all timepoints" faa matches *exactly* — and that is the smoking gun.
`dD/D` and `dV/V` are per-run **demeaned** (fractional change about each run's
mean), so over the *full* pooled data the fit intercept is ≈ 0 and poly1 ==
through-origin. But any **sub-window** (stim/post/sliding) is offset from the
origin (the intercept is real), so the two fits diverge there:

```
 v   int_all   int_stim
 1   0.00000   -0.05390
 2   0.00018   -0.20081
 6  -0.00000   -0.12420
 9   0.00000   -0.13661
```

See `/tmp/dvda-investigation/faa_stim_scatter_fits.png` — blue (poly1) vs red
(through-origin) lines visibly diverge once the cloud leaves the origin.

### 3. Reference output reproduced
My poly1 re-implementation reproduces the **committed** `dVdA/FaaStim_FaaPost.csv`
to 3–4 decimals. The only residual is on vessels 2 & 5, and it comes from the
area-proxy method (dVdA `doIt.m` uses `area = (Nw(Sw-St)+Nz(Sz-St))/(Sw-St)`;
`getAreaDiamVelProxy` uses `areaMethod=2`, `area = Nw + Nz*frac` with `frac<0→NaN`).
This is the "area/vel/diam are close enough" difference you already noted — it is
**not** the figure divergence.

---

## Secondary (minor) differences, for completeness

These exist but are small and are *not* the main visual divergence:

1. **Sliding-window timecourse extent.**
   - dVdA: window centers `nn = 0 .. 49` → t ≈ `[0, 41.2] s` (starts at onset;
     upper bound keeps *all* onsets' windows inside the run end).
   - getFaa: centers `idxTrial = -9 .. 53` → t ≈ `[-7.6, 44.4] s` (starts ~7.6 s
     **pre-onset**, ends just before the next onset; the last onset is
     under-represented at the high end since its samples run out).
   - In the **overlapping** range the curves are identical (given matched fit).

2. **Post-stim window bound.** dVdA pools trial-rel `8 .. 52`
   (`idxTrialOnset(end,end)`); getFaa pools `8 .. 56` (`isi-1`, last onset
   contributes fewer samples at 53–56). Effect on faa ≈ 0.008.

---

## What you need to decide

Which fit is the intended model?

- **Through-origin (slope-only, current `getFaa`)** is arguably more principled:
  `faa` is defined from the ratio `(dV/V)/(dD/D)`, which presumes `dV/V = 0` when
  `dD/D = 0` — i.e. the line goes through the origin. This was a **deliberate**
  choice in the refactor (the local tile-3 comment says "slope-only, as in
  getFaa"), but it was **not** propagated to the dVdA repo, which still uses poly1.
- **Free-intercept (poly1, dVdA reference)** is what produced the committed
  figures and `FaaStim_FaaPost.csv`.

Both are self-consistent; they are just different estimators. Pick one and make
`dVdA/doIt.m` and `getFaa.m` agree. If through-origin is intended, the dVdA repo
figures are simply stale and should be regenerated. If poly1 is intended, change
`getFaa.m`'s `fitFaa` (and the local tile-3) back to `'poly1'` with `1/2-1/4*p1`.

Recommendation: settle the modeling question first (origin-constrained vs not),
then unify the window bounds (timecourse start, post-stim upper bound) so the two
codebases are byte-for-byte comparable.

---

## Artifacts
- `/tmp/dvda-investigation/dVdA/compareFaa.m`  — full A-vs-B comparison
- `/tmp/dvda-investigation/dVdA/compareFaa2.m` — decomposition (fit vs indexing)
- `/tmp/dvda-investigation/dVdA/diagFigs.m`    — intercept check + figures
- `/tmp/dvda-investigation/faa_timecourse_poly1_vs_slopeonly.png`
- `/tmp/dvda-investigation/faa_stim_scatter_fits.png`
- `/tmp/dvda-investigation/compareFaa_out.mat`
