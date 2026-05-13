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
| `throw_strength_multiplier` | — | `0.05` | ~~Converts swipe distance to impulse~~ Replaced by dynamic multiplier |
| `min_swipe_dist` | ClutchSpot | `30.0` | Minimum swipe distance to register a throw |
| `max_swipe_dist` | — | `300.0` | Swipe distance mapped to max strength |
| `min_bag_strength` | — | `1.0` | Minimum impulse strength |
| `max_bag_strength` | PowerShot | `20.0` | Maximum impulse strength (cap) |

> ℹ️ All parameters can be **overridden per player** via `BagConfig` resource.
> `NetworkManager.get_bag_config_for_player(player_id)` is checked first —
> exported values are used only as fallback.

---

## BagConfig Override System

SwipeInputController._get_active_bag_config()
↓
reads throw_player from bag metadata
↓
NetworkManager.get_bag_config_for_player(throw_player)
↓
if BagConfig exists → use its values
if null             → use exported defaults

Affected by BagConfig:
- `min_swipe_dist`
- `max_swipe_dist`
- `min_bag_strength`
- `max_bag_strength`

---

## Input Events

| Event | Platform | Action |
|---|---|---|
| `InputEventScreenTouch` | Mobile | Captures start/end position |
| `InputEventScreenDrag` | Mobile | Emits swipe preview |
| `InputEventMouseButton` | Desktop | Captures start/end position |
| `InputEventMouseMotion` | Desktop | Emits swipe preview |

---

## Multiplayer Turn Guard

```gdscript
func is_network_game() -> bool:
    return GameSession.selected_mode == "Local"

func get_my_player_id() -> int:
    return 1 if multiplayer.is_server() else 2
```

Throw is **blocked** if:
is_network_game() == true
AND
GameSession.current_turn != get_my_player_id()

> ℹ️ Preview (`swipe_updated`) guard is currently commented out —
> only the final throw (`swipe_completed`) is blocked on wrong turn.

---

## Swipe Vector

$$\vec{swipe} = \vec{pos}_{start} - \vec{pos}_{end}$$

| Swipe Direction | Sign |
|---|---|
| Swipe Up | $swipe_y > 0$ |
| Swipe Right | $swipe_x > 0$ |

---

## Strength Formula

### Updated — Dynamic Multiplier

Old formula (removed):
$$S_{old} = \text{clamp}(d \times 0.05, \ 1.0, \ 20.0)$$

New formula:
$$multiplier = \frac{max\_bag\_strength}{max\_swipe\_dist}$$

$$S = \text{clamp}\left(d \times multiplier, \ \underbrace{min\_bag\_strength}_{\texttt{1.0}}, \ \underbrace{max\_bag\_strength}_{\texttt{PowerShot: 20.0}}\right)$$

With defaults:
$$multiplier = \frac{20.0}{300.0} \approx 0.0\overline{6}$$

| Swipe Distance | Raw Strength | Clamped Strength |
|---|---|---|
| 30px (min) | 2.0 | 2.0 |
| 100px | 6.67 | 6.67 |
| 200px | 13.33 | 13.33 |
| 300px | 20.0 | 20.0 ← capped |
| 400px | 26.67 | 20.0 ← capped |

### Throw valid only if:
$$d \geq \underbrace{min\_swipe\_dist}_{\texttt{ClutchSpot: 30.0}}$$

> ⚠️ Swipe **speed** is measured but not used.
> A slow 100px swipe and a fast 100px swipe produce identical strength.

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

$$\boxed{\vec{impulse} = \hat{d}\left(\theta_{yaw}, \ \theta_{pitch}\right) \times \text{clamp}\left(d \times \frac{20}{300}, \ 1, \ 20\right)}$$

---

## Tuning Guide

| Goal | Change |
|---|---|
| Wider left/right aim | Increase `horizontal_sensitivity` |
| Steeper throws | Increase `vertical_sensitivity` |
| Allow downward throws | Lower `min_pitch_angle` below `0°` |
| Reach max power sooner | Decrease `max_swipe_dist` |
| Require bigger swipes | Increase `min_swipe_dist` |
| Cap max power higher | Increase `max_bag_strength` |
| Per-player throw feel | Configure `BagConfig` resource per player |
| Make speed matter | Add `swipe_time` to strength formula |

---

## Gameplay Consequences

| Condition | Result | Reason |
|---|---|---|
| Swipe downward | Always throws upward | $\theta_{pitch} \geq 10°$ always |
| Fast short swipe | Same as slow short swipe | Speed not in formula |
| Swipe ≥ 300px | Strength capped at 20 | $S = \text{clamp}(...,1,20)$ |
| Swipe < 30px | Throw ignored | $d < \texttt{ClutchSpot}$ |
| Wrong turn (LAN) | Throw blocked | Turn guard in `process_swipe()` |

---

## File Reference

| File | Line | Description |
|---|---|---|
| `swipe_input_controller.gd` | 32 | Input event handling |
| `swipe_input_controller.gd` | 40 | Distance + time calculation |
| `swipe_input_controller.gd` | 59 | Mouse button end capture |
| `swipe_input_controller.gd` | 68 | Preview emit (`swipe_updated`) |
| `swipe_input_controller.gd` | 74 | Multiplayer turn guard |
| `swipe_input_controller.gd` | 80 | `get_strength()` dynamic multiplier |
| `swipe_input_controller.gd` | 89 | Swipe vector calculation |
| `swipe_input_controller.gd` | 92 | Yaw calculation |
| `swipe_input_controller.gd` | 98 | Pitch calculation |
| `corn_bag.gd` | 76 | Impulse application |
| `projectile_path.gd` | 80 | Preview simulation start |
| `projectile_path.gd` | 86 | Velocity from impulse |
| `projectile_path.gd` | 109 | Euler velocity step |
| `projectile_path.gd` | 113 | Euler position step |
