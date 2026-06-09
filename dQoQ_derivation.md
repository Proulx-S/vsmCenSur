# Volumetric flow change $\Delta Q/Q$

Derivation of the formula computed in `tools/vfMRItools/getAreaDiamVelFlowProxy.m`
(stored as `vessel.im.<src>QoQe`/`QoQa`) and plotted by `doIt_vsmCenSur.m` (dV/dD section):

```matlab
QoQe = (1+VoV).*(1+AoA) - 1;     % volumetric flow change dQ/Q, exact (Q = V*A)
QoQa = VoV + AoA;                % volumetric flow change dQ/Q, first-order approximation
```

## 1. Volumetric flow

Volumetric flow through a vessel cross-section is the cross-sectional area times the
mean velocity across that section:

$$Q = A \cdot V$$

where

- $A$ — vessel cross-sectional area (area proxy, `respArea`),
- $V$ — mean intravascular velocity (velocity proxy, `respVel`).

## 2. Fractional change relative to baseline

### Why fractional change?

The proxies $A$ and $V$ are in arbitrary units and differ in scale from vessel to vessel,
so their absolute values are not directly comparable. Normalising each signal to its own
pre-stim baseline removes the units and the per-vessel scale, leaving a dimensionless
**fractional change** that can be pooled and averaged across vessels. This is the same
normalisation already applied to $\Delta V/V_0$ and $\Delta D/D_0$ elsewhere in the script.

Let subscript $0$ denote the pre-stim **baseline**. In the code this is the first frame of
the trial-averaged response,

$$A_0 = A(1), \qquad V_0 = V(1), \qquad Q_0 = A_0 V_0 ,$$

and the fractional change of any quantity $X$ is

$$\frac{\Delta X}{X_0} \;=\; \frac{X - X_0}{X_0}
\qquad\Longleftrightarrow\qquad
\frac{X}{X_0} \;=\; 1 + \frac{\Delta X}{X_0}. \tag{2.1}$$

The right-hand form — "ratio to baseline = one plus the fractional change" — is what lets
the product $Q = AV$ factor cleanly below.

### Applying it to the flow

Start from the definition of the fractional change in flow and substitute $Q = AV$,
$Q_0 = A_0 V_0$:

$$\frac{\Delta Q}{Q_0}
\;=\; \frac{Q - Q_0}{Q_0}
\;=\; \frac{Q}{Q_0} - 1
\;=\; \frac{A\,V}{A_0\,V_0} - 1 .$$

Because the flow is a **product**, the ratio to baseline separates into a product of the
individual ratios (numerator and denominator regroup by signal):

$$\frac{A\,V}{A_0\,V_0}
\;=\; \frac{A}{A_0}\cdot\frac{V}{V_0}
\qquad\Longrightarrow\qquad
\frac{\Delta Q}{Q_0} \;=\; \frac{A}{A_0}\cdot\frac{V}{V_0} - 1 .$$

Now rewrite each ratio with the identity (2.1), $\frac{V}{V_0} = 1 + \frac{\Delta V}{V_0}$
and $\frac{A}{A_0} = 1 + \frac{\Delta A}{A_0}$:

$$\boxed{\;\frac{\Delta Q}{Q_0} \;=\; \left(1 + \frac{\Delta V}{V_0}\right)\left(1 + \frac{\Delta A}{A_0}\right) - 1\;}$$

This is the **exact** expression for finite changes: it follows directly from $Q = AV$ with
no approximation. It also stays well-behaved at large changes — e.g. if velocity doubles
($\Delta V/V_0 = 1$) and area is unchanged, it correctly gives $\Delta Q/Q_0 = 1$ (flow
doubles) — which is why it is preferred over the linear form in §3.

## 3. Expansion and first-order approximation

Multiplying out:

$$\frac{\Delta Q}{Q_0} \;=\; \frac{\Delta V}{V_0} + \frac{\Delta A}{A_0} + \frac{\Delta V}{V_0}\,\frac{\Delta A}{A_0} .$$

For small changes the cross term is second-order and can be dropped:

$$\frac{\Delta Q}{Q_0} \;\approx\; \frac{\Delta V}{V_0} + \frac{\Delta A}{A_0} .$$

`getAreaDiamVelFlowProxy` computes **both** forms for every vessel and stores them
(`vessel.im.<src>QoQe` exact, `vessel.im.<src>QoQa` first-order). In `doIt_vsmCenSur.m`
the `intType` flag chooses which one is plotted on the right axis of the faa panels
(alongside the `'X'`/`'Y'` fit-intercept choices):

- `intType = 'Qexact'` → exact product form (the cross term
  $\frac{\Delta V}{V_0}\frac{\Delta A}{A_0}$ is retained),
- `intType = 'Qaprx'` → first-order approximation.

## 4. Relation to diameter change

The diameter proxy is derived from the area proxy assuming a circular cross-section,
$D = 2\sqrt{A/\pi}$, i.e. $A = \pi (D/2)^2 \propto D^2$. Hence

$$\frac{A}{A_0} = \left(\frac{D}{D_0}\right)^2
\;\;\Longrightarrow\;\;
\frac{\Delta A}{A_0} = \left(1 + \frac{\Delta D}{D_0}\right)^2 - 1
= 2\,\frac{\Delta D}{D_0} + \left(\frac{\Delta D}{D_0}\right)^2
\;\approx\; 2\,\frac{\Delta D}{D_0}.$$

So area change is (to first order) twice the diameter change. The code computes
$\Delta A/A_0$ directly from the area proxy, which is equivalent to the exact form above.

## 5. Code mapping

These are all computed in `getAreaDiamVelFlowProxy.m` from the area/velocity/diameter
proxies and stored on the vessel, one set per source field `<src>` (`resp`, `ts`):

| Math | Stored field (`.vec`) | Definition |
|------|-----------------------|------------|
| $\Delta A/A_0$ | `vessel.im.<src>AoA`  | `(A - A0)./A0` |
| $\Delta V/V_0$ | `vessel.im.<src>VoV`  | `(V - V0)./V0` |
| $\Delta D/D_0$ | `vessel.im.<src>DoD`  | `(D - D0)./D0` |
| $\Delta Q/Q_0$ (exact)     | `vessel.im.<src>QoQe` | `(1+VoV).*(1+AoA) - 1` |
| $\Delta Q/Q_0$ (1st-order) | `vessel.im.<src>QoQa` | `VoV + AoA` |

The baseline $X_0$ depends on the source: the **first time frame** for deconvolved
responses (`resp*`, whose first frame is the pre-stim baseline) and the **per-run
temporal mean** for the raw timeseries (`ts`). `doIt_vsmCenSur.m` reads these fields
(e.g. `dDoD = vessel.im.respDoD.vec`) instead of recomputing them.

## Assumptions

- $Q = A V$ assumes $V$ is the **mean** velocity over the cross-section (a plug-flow /
  cross-sectionally-averaged interpretation of the velocity proxy).
- Area and velocity proxies share the same baseline frame and time grid.
- The circular-cross-section relation $A \propto D^2$ only matters if $\Delta A/A_0$ is
  obtained from $\Delta D/D_0$; here it is taken from the area proxy directly.
