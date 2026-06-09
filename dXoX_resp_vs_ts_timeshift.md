# Time shift between dX/X (and dQ/Q) from `resp` vs from `ts` — root cause & fix

## Symptom

In the dV/dD figures, the `ts`-based dotted dX/X / dQ/Q timecourses (from
`getAreaDiamVelFlowFaaProxyFromTs`, on the faa grid) were shifted **~3.4 s earlier**
in time than the solid `resp`-based curves (from the AFNI deconvolution). The two are
independent estimates of the *same* response and must agree in time.

## Measurement

Probing vessel 1 (subject vsmDiamCenSurP1), dD/D trough and cross-correlation:

| grid | dD/D trough | xcorr lag (ts vs resp) |
|---|---|---|
| `resp` (AFNI IRF, `t=linspace(0,(N-1)·trDecon,N)`) | 19.32 s | — |
| `ts` (faa grid, `getAlign`) | 15.12 s | **−4 samples = −3.36 s** |

The lag is **exactly −4 samples (−3.36 s)**, i.e. `ts` leads `resp` by a constant.

## Root cause: an uncorrected dummy-scan offset on the ts/faa side

- The raw timeseries `vessel.im.ts` has **`nDummy` initial frames removed**:
  `nFrameOrig = 354`, `nFrame = 350` ⇒ `nDummyRemoved = 4`; `nDummyIgnore = 0` ⇒
  `nDummy = 4`. With `tr = 0.84 s`, that is `nDummy·tr = 3.36 s` — exactly the shift.
- **`dsgn.onsetList` is in *original* (pre-removal) time** (`[10.08, 57.96, …] s`). This
  is proven by the deconvolution code itself: `getRespAndAct2.m:44-49` *drops* any onset
  that falls within the removed-dummy window, and `getRespAndAct2.m:656` issues
  `-local_times -stim_times_subtract nDummy·tr` to 3dDeconvolve. So the AFNI **`resp`
  IRF is correctly referenced to the true stimulus onset.**
- **`getFaa`'s `getAlign` applies no such correction.** It matches the original-time
  `onsetList` directly onto the dummy-removed `ts` grid
  (`idx = find(ismembertol(tts, onsetList(i)))`), placing the onset marker `nDummy`
  frames **late**. Every ts/faa quantity (faa timecourse, `fromTs` dX/X & dQ/Q, the
  during/post windows) is therefore shifted **`nDummy·tr = 3.36 s` early**.

In short: **`resp` is correctly aligned; the ts/faa side is early by `nDummy·tr`
because `getAlign` ignores the dummy scans that the AFNI deconvolution accounts for.**

## Fix — track the proper ts time grid (`tsStartTime`)

`getFaa.m` and `getAreaDiamVelFlowProxy.m` are kept intact. Rather than adapt
`dsgn.onsetList`, the dummy offset is tracked as a property of the ts grid and carried
through the pipeline:

1. **`runCond` class** (`tools/vasomoTools/runCond.m`) — new property `tsStartTime`:
   the time of the first preprocessed (dummy-removed) ts frame relative to the full
   (with-dummy) acquisition 0s start = `(nFrameOrig-nFrame)*tr`.
2. **`%% Load preprocessed data`** — populates `rCond{S}.(acq).(task).tsStartTime` for
   every run condition (so a regenerated checkpoint carries it).
3. **`%% Get ROI data`** — copies it to `roi{S}.(acq).(task).tsStartTime`.
4. **`indexTs2Trial.m`** (`tools/vfMRItools`) — builds its onset-aligned grid in *full-ts
   time*: `tts = tsStartTime + (0:nT-1)*dt` (was `linspace(0,…)`), reading `tsStartTime`
   from `rCond` (**required — errors informatively if missing/empty**, no fallback). So
   onsets land on the true frame and **its outputs (`winCols`, `t`, `tStart`, `tEnd`) are
   true-onset-relative at the source** — no downstream relabel, and the sliding-window
   forward bound is correct (no next-trial tail contamination). Its consumers
   (`getFaa2`, `getAreaDiamVelFlowFaaProxyFromTs` → `faa2`, `fromTs`) inherit this
   automatically.
5. **`%% dV/dD`** — reads `roi…tsStartTime` (required, no fallback). The `fromTs`/`faa2`
   timecourses are already correct (from `indexTs2Trial`) and are **not** touched. Only
   the legacy **`getFaa`** path (the white faa panel + during/post markers/scatters) still
   needs correction, because `getFaa`'s own `getAlign` (in `vasomoTools`, to be sunset) is
   still on the 0-based grid: its `winStim/winPost/winPre` are shifted by `-nDS` and its
   `faa.res` `.t/.tStart/.tEnd` are shifted by `+tsStartTime`.

`resp` is untouched. Onsets/`dsgn` are never modified; the offset lives with the ts grid.
(Once `vasomoTools`/`getFaa` is sunset and the faa path moves to `getFaa2`/`indexTs2Trial`,
the doIt-side `getFaa` correction can be dropped entirely.)

## Verification (after fix)

- Cross-correlation lag `ts` vs `resp`: **0 samples** (was −4 / −3.36 s).
- `faa during vs. post`: `p ≈ 0.062` (was the mis-timed `p ≈ 0.009`); `dQ/Q during vs.
  post`: `p ≈ 0.024`. Figures: dotted ts dX/X & dQ/Q now overlay the solid resp curves.

## Consequences worth noting

- The **faa during-vs-post** statistic changed (`p` ~0.009 → ~0.062): the during/post
  windows now pool *correctly onset-aligned* ts data (the old "during stim" window
  actually sampled ~3.4–8.4 s post-onset). The **dQ/Q** during-vs-post is essentially
  unchanged (its averages come from the already-correct `resp` timecourse).
- The ts (faa-grid) timecourses extend ~`nDS` frames (3.36 s) further forward than the
  ideal inter-onset bound, because `getFaa`/`indexTs2Trial` cap the sliding window
  relative to the (late) 0-based marker; the last ~3 points of the ts timecourse / the
  tail of the post-stim window therefore reach slightly into the next trial. This is the
  pre-existing `getAlign` behaviour (unchanged), not introduced by the fix.
- **Broader implication:** `getAlign` (in `getFaa.m`, duplicated in `indexTs2Trial.m`)
  has this dummy offset for *every* analysis that uses it. The clean long-term fix is to
  build its grid as `tsStartTime + (0:nT-1)*dt` at the source; here it's accounted for in
  the doIt only, per request to keep those files intact.

## Files

- `runCond.m` property `tsStartTime` (in **both** `tools/util/` and `tools/vasomoTools/` —
  identical copies; `util` shadows `vasomoTools` on the path, so both must carry it until
  `vasomoTools` is sunset).
- `tools/vfMRItools/indexTs2Trial.m` — builds its grid at `tsStartTime`.
- `doIt_vsmCenSur.m` — `%% Load preprocessed data` + `%% Get ROI data` (populate/carry the
  field) and `%% dV/dD` (read it; correct the legacy `getFaa` path only).
- Pipeline context: [`dXoX_fromTs_pipeline.md`](dXoX_fromTs_pipeline.md).
