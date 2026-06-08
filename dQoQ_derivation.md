# Volumetric flow change $\Delta Q/Q$

Derivation of the formula used in `doIt_vsmCenSur.m` (dV/dD section):

```matlab
dQoQ = (1+dVoV).*(1+dAoA) - 1;     % volumetric flow change, Q = V*A
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

The code implements **both** forms, selected by the `intType` flag:

- `intType = 'Qexact'` → `dQoQe = (1+dVoV).*(1+dAoA) - 1` (exact product form; the cross
  term $\frac{\Delta V}{V_0}\frac{\Delta A}{A_0}$ is retained),
- `intType = 'Qaprx'` → `dQoQa = dVoV + dAoA` (first-order approximation).

Both are computed for every vessel; the flag chooses which one is plotted on the right
axis of the faa panels (alongside the `'X'`/`'Y'` fit-intercept choices).

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

| Math | Code variable | Definition |
|------|---------------|------------|
| $\Delta V/V_0$ | `dVoV` | `(V - V(1))./V(1)` |
| $\Delta A/A_0$ | `dAoA` | `(A - A(1))./A(1)` |
| $\Delta D/D_0$ | `dDoD` | `(D - D(1))./D(1)` |
| $\Delta Q/Q_0$ | `dQoQ` | `(1+dVoV).*(1+dAoA) - 1` |

All are timecourses on the trial-averaged (deconvolved) response grid, with the first
frame as the pre-stim baseline.

## Assumptions

- $Q = A V$ assumes $V$ is the **mean** velocity over the cross-section (a plug-flow /
  cross-sectionally-averaged interpretation of the velocity proxy).
- Area and velocity proxies share the same baseline frame and time grid.
- The circular-cross-section relation $A \propto D^2$ only matters if $\Delta A/A_0$ is
  obtained from $\Delta D/D_0$; here it is taken from the area proxy directly.
