# SwipeInputController — Throw System Documentation

## Overview

The throw system converts a 2D screen swipe into a 3D physics impulse.
It lives across three files:

| File | Responsibility |
|---|---|
| `swipe_input_controller.gd` | Input conversion → direction + strength |
| `corn_bag.gd` | Applies impulse to RigidBody3D |
| `projectile_path.gd` | Simulates flight path for preview |

---

## Exported Parameters

| Variable | Nickname | Default | Role |
|---|---|---|---|
| `horizontal_sensitivity` | AirControl | `0.15` | Controls left/right yaw per swipe pixel |
| `vertical_sensitivity` | MissClock | `0.40` | Controls upward pitch per swipe pixel |
| `throw_strength_multiplier` | — | `0.05` | Converts swipe distance to impulse strength |
| `min_swipe_dist` | ClutchSpot | `30.0` | Minimum swipe distance to register a throw |
| `min_pitch_angle` | — | `10.0°` | Minimum upward throw angle |
| `max_pitch_angle` | — | `45.0°` | Maximum upward throw angle |
| `min_bag_strength` | — | `1.0` | Minimum impulse strength |
| `max_bag_strength` | PowerShot | `20.0` | Maximum impulse strength (cap) |

---

## Swipe Vector

$$\vec{swipe} = \vec{pos}_{start} - \vec{pos}_{end}$$

| Swipe Direction | Sign |
|---|---|
| Swipe Up | $swipe_y > 0$ |
| Swipe Right | $swipe_x > 0$ |

---

## Strength Formula

### Swipe Distance
$$d = \sqrt{(x_{end} - x_{start})^2 + (y_{end} - y_{start})^2}$$

### Throw valid only if:
$$d \geq \underbrace{30.0}_{\texttt{ClutchSpot}}$$

### Strength
$$S = \text{clamp}\left(d \times 0.05, \ \underbrace{1.0}_{\texttt{min}}, \ \underbrace{20.0}_{\texttt{PowerShot}}\right)$$

| Swipe Distance | Raw Strength | Clamped Strength |
|---|---|---|
| 100px | 5.0 | 5.0 |
| 200px | 10.0 | 10.0 |
| 400px | 20.0 | 20.0 ← capped |
| 500px | 25.0 | 20.0 ← capped |

> ⚠️ Swipe **speed** is measured but not used.
> A slow 100px swipe and a fast 100px swipe throw with identical strength.

---

## Direction Formula

### Yaw (Left / Right)
$$\theta_{yaw} = swipe_x \times \underbrace{0.15°}_{\texttt{AirControl}}$$

### Pitch (Up angle)
$$\theta_{pitch} = \text{clamp}\left(swipe_y \times \underbrace{0.4°}_{\texttt{MissClock}}, \ 10°, \ 45°\right)$$

> ⚠️ Pitch is always **≥ 10°** upward — downward throws are not possible.

### Camera-Relative Forward
$$\vec{forward} = \frac{-\vec{cam}_z \ | \ y=0}{\left|-\vec{cam}_z \ | \ y=0\right|}$$

### Final Direction
$$\hat{d} = \text{normalize}\left(R_{pitch} \times \left(R_{yaw} \times \vec{forward}\right)\right)$$

Where:
$$R_{yaw} = \text{Basis}(\vec{UP}, \ \theta_{yaw})$$
$$R_{pitch} = \text{Basis}(\vec{cam}_x, \ \theta_{pitch})$$

---

## Impulse Application

Applied in `corn_bag.gd`:

$$\vec{J} = \hat{d} \times S$$

Since:

$$\vec{J} = m \times \Delta\vec{v}$$

Initial velocity used in preview:

$$\vec{v_0} = \frac{\hat{d} \times S}{m}$$

---

## Preview Simulation

Euler integration in `projectile_path.gd` each step $dt$:

$$\vec{v}_{n+1} = \left(\vec{v}_n + \vec{g} \times dt\right) \times damping$$

$$\vec{p}_{n+1} = \vec{p}_n + \vec{v}_{n+1} \times dt$$

Where:

$$\vec{g} = \left(0, \ -9.8 \times gravity\_scale, \ 0\right)$$

---

## Complete Throw Formula

$$\boxed{\vec{impulse} = \hat{d}\left(\theta_{yaw}, \ \theta_{pitch}\right) \times \text{clamp}\left(d \times 0.05, \ 1, \ 20\right)}$$

---

## Tuning Guide

| Goal | Change |
|---|---|
| Wider left/right aim | Increase `horizontal_sensitivity` |
| Steeper throws | Increase `vertical_sensitivity` |
| Allow downward throws | Lower `min_pitch_angle` below `0` |
| Stronger throws overall | Increase `throw_strength_multiplier` |
| Require bigger swipes | Increase `min_swipe_dist` |
| Cap max power higher | Increase `max_bag_strength` |
| Make speed matter | Add `swipe_time` to strength formula |

---

## Gameplay Consequences

| Condition | Result | Reason |
|---|---|---|
| Swipe downward | Always throws upward | $\theta_{pitch} \geq 10°$ always |
| Fast short swipe | Same as slow short swipe | Speed not in formula |
| Swipe ≥ 400px | Strength capped at 20 | $S = \text{clamp}(...,1,20)$ |
| Swipe < 30px | Throw ignored | $d < \texttt{ClutchSpot}$ |

---

## File Reference

| File | Key Lines |
|---|---|
| `swipe_input_controller.gd` | Line 32 — input conversion |
| `swipe_input_controller.gd` | Line 40 — distance calculation |
| `swipe_input_controller.gd` | Line 74 — strength clamp |
| `swipe_input_controller.gd` | Line 89 — swipe vector |
| `swipe_input_controller.gd` | Line 92 — yaw calculation |
| `swipe_input_controller.gd` | Line 98 — pitch calculation |
| `corn_bag.gd` | Line 76 — impulse application |
| `projectile_path.gd` | Line 80 — preview simulation start |
| `projectile_path.gd` | Line 86 — velocity from impulse |
| `projectile_path.gd` | Line 109 — Euler velocity step |
| `projectile_path.gd` | Line 113 — Euler position step |
