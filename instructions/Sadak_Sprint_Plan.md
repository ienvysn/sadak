# Sadak — सडक
## Complete Sprint Plan
**Engine:** LÖVE2D | **Language:** Lua | **Map Library:** STI | **Platform:** Desktop

---

> **How to read this document**
> Each sprint has a goal, a list of tasks broken into sections, a clear outcome, and an explicit list of what is NOT included. Follow the sprint order strictly — never build Sprint 3 features during Sprint 2. At the end of every sprint there should always be a runnable game, even if incomplete.

---

## Pre-Sprint: Project Setup
**Do this before any sprint begins. Takes 2–3 hours.**

### Tasks
- Install LÖVE2D from love2d.org
- Create project folder structure exactly as defined in the coder guide
- Create `conf.lua` — set window to 1280×720, title "Sadak", disable default cursor
- Create empty `main.lua` with `love.load()`, `love.update(dt)`, `love.draw()` stubs
- Download `sti.lua` from github.com/karai17/Simple-Tiled-Implementation → place in `/src/lib/`
- Download Noto Sans font (.ttf) → place in `/assets/fonts/`
- Create `/maps/` folder — Person A will drop exports here
- Create `/assets/sprites/`, `/assets/audio/`, `/assets/tiles/`, `/assets/ui/` folders
- Set up GitHub repo, all three team members clone it
- Confirm LÖVE2D runs: `love .` in project folder should show a blank window

### Outcome
A blank 1280×720 window with the title "Sadak" that opens without errors. Nothing more.

---

## Sprint 1 — The Car Moves
**Duration: Days 1–5**
**Single goal: Get a car moving on a tile map with collision.**

---

### Section 1.1 — Car Movement (Days 1–2)

#### Tasks
- Create `src/entities/Car.lua`
- Implement WASD movement with real physics feel:
  - `W` = accelerate forward
  - `S` = brake / reverse slowly
  - `A` / `D` = turn left / right (turning rate depends on current speed — slow turns at low speed, wider turns at high speed)
  - Car has momentum — does not stop instantly when W is released, coasts briefly
  - Car has a maximum speed cap (defined in `src/data/vehicles.lua`)
- Car is represented as a **coloured rectangle** — no sprite yet
- Car rotates visually to match direction of travel
- Car stays within a hardcoded boundary (placeholder until real map loads)

#### Decision: Movement model
Use manual velocity (not LÖVE2D Box2D physics). Simpler, more controllable.
```
velocity += acceleration * dt      (when W held)
velocity *= friction_coefficient    (every frame — creates natural deceleration)
x += math.cos(angle) * velocity * dt
y += math.sin(angle) * velocity * dt
```

#### Outcome of 1.1
A coloured rectangle that drives around a blank canvas. Feels like a vehicle, not a sliding box.

---

### Section 1.2 — Camera (Day 2)

#### Tasks
- Camera follows the car smoothly using `love.graphics.translate()`
- Camera is offset so car sits slightly below centre (you see more of where you're going)
- Camera clamps to map bounds — no black edges visible
- Implement as a simple `camera.lua` module in `/src/`

#### Decision: Camera offset
Car sits at 40% from top of screen, 50% horizontal. Gives more visible road ahead.

#### Outcome of 1.2
Driving the car moves the camera with it. World feels larger than the window.

---

### Section 1.3 — Tile Map Loading (Days 3–4)

#### Tasks
- Load `sti.lua` and require it in `GameScene.lua`
- Load `/maps/map_kathmandu_v1.json` from Person A using STI
- Load `/assets/tiles/kathmandu_tiles.png` from Person B as the tileset image
- Render layers in order: Ground → Roads → Buildings → Decorations
- If Person A's map is not ready: use a **placeholder 20×20 test map** (hand-coded JSON with basic road + building tiles) — never block development on this

#### Placeholder map format (use if Person A is late)
A simple JSON with one road strip and building blocks on either side. Coder creates this in 30 minutes using Tiled independently.

#### Outcome of 1.3
The car drives on a real tile map. The world has roads and buildings.

---

### Section 1.4 — Collision (Day 4–5)

#### Tasks
- Add `collides = true` property to all building tiles in the Tiled map (Person A's job — confirm this is done)
- In `GameScene.lua`: `buildingsLayer:setCollisionByProperty({ collides = true })`
- Resolve collision: when car overlaps a building tile, push it back out (AABB resolution)
- Building collision = **hard stop** (velocity set to 0) + **damage applied**
- Implement `src/systems/DamageSystem.lua`:
  - Vehicle condition: 0–100, starts at 100
  - Building hit: fixed -20 condition
  - Condition floor: 0 (cannot go negative)
- Screen shake on building hit: offset camera by random ±4px for 0.2 seconds

#### Decision: Collision resolution
Use tile-based collision checking. Each frame, check the four corners of the car's bounding box against the tile at that position. If any corner is inside a `collides = true` tile, push the car out by the overlap amount and zero the velocity.

#### Outcome of 1.4
Car cannot drive through buildings. Hitting a building stops the car and shakes the screen.

---

### Sprint 1 Full Outcome
> A car drives around a Kathmandu tile map. Camera follows. Buildings block movement. Hitting a building shakes the screen and damages the car. The game does not crash.

### What is NOT in Sprint 1
- No passengers
- No fuel
- No HUD
- No NPC traffic
- No potholes
- No day/night
- No UI of any kind
- No saving

### Handoff required from teammates
| From | File | Needed by |
|------|------|-----------|
| Person A | `maps/map_kathmandu_v1.json` | Day 3 |
| Person B | `assets/tiles/kathmandu_tiles.png` | Day 3 |
| Person B | `assets/sprites/bike_bajaj.png` | Day 5 (nice to have — rectangle works) |

---

## Sprint 2 — The Core Ride Loop
**Duration: Days 6–12**
**Single goal: Complete one full ride from spawn to dropoff with fare calculated.**

---

### Section 2.1 — Passenger System (Days 6–7)

#### Tasks
- Create `src/entities/Passenger.lua`
- Create `src/data/passengers.lua` — define passenger types:

| Type | Base fare multiplier | Tip range | Notes |
|------|---------------------|-----------|-------|
| Tourist | ×1.4 | 5–20% | Spawns near Thamel |
| Office Worker | ×1.0 | 0–15% | Spawns near Ring Road |
| Student | ×0.7 | 0–5% | Any zone |
| VIP | ×2.5 | 10–20% | Ch.3+ only |
| Elderly | ×0.8 | 0–10% | Heritage zones |

- Read spawn Point objects from Tiled `Spawns` layer via STI
- Spawn up to **3 passengers max** on the map at any time
- Passenger spawn logic:
  - Every 30–60 seconds (random), attempt to spawn a new passenger
  - If 3 already on map: skip
  - Pick a random spawn point from the `Spawns` layer
  - Assign random passenger type
  - Start 2-minute despawn timer

- Visual representation: **coloured circle with a floating raised-hand icon above it**
  - Raised-hand icon: placeholder triangle until Person B delivers sprite
  - Shrinking circle drawn around the passenger icon (radius shrinks over 120 seconds)
  - When circle reaches zero: passenger despawns, no penalty to player

#### Outcome of 2.1
Passengers appear on the map, wait 2 minutes, and disappear if ignored.

---

### Section 2.2 — Pickup and Dropoff (Day 7–8)

#### Tasks
- When car is within 40px of a passenger and player presses `E`: pickup triggered
  - Passenger attaches to car (no longer drawn separately)
  - Destination chosen from a different zone than spawn (random)
  - Destination marker drawn on map: teardrop/pin icon at destination tile
  - Ride timer starts (used for fare calculation)
- When car reaches destination tile and player presses `E`: dropoff triggered
  - Ride timer stops
  - Trigger `FareSystem.calculateFare()`
  - Trigger tip reveal animation
  - Passenger removed from game
  - Destination marker removed

- **Ride request popup** (shown when player is near a passenger):
  - Small box appears on screen: destination zone name + estimated fare
  - Estimated fare = actual fare ±15% (slight randomness so it's an estimate)
  - Player presses `E` to accept or drives away to ignore
  - Popup disappears if player drives away or passenger despawns

#### Decision: Destination zones
Destinations are zone centres defined as named Point objects in the Tiled `Zones` layer. Not pixel-perfect — just "get to the Patan zone." Destination tile is the zone's centre point.

#### Outcome of 2.2
Player can pick up a passenger and drive them to a destination.

---

### Section 2.3 — Fare and Tip System (Day 8–9)

#### Tasks
- Create `src/systems/FareSystem.lua`
- Fare calculation:
```
baseFare = distanceTravelled * ratePerUnit
typeMult = passengerType.fareMultiplier
finalFare = baseFare * typeMult
```
- Tip calculation:
  - Roll random: 40% chance of no tip at all
  - If tip: random % between passenger type's tip range
  - Tip multiplied by condition factor: `tipAmount * (vehicleCondition / 100)`
  - Higher condition = higher tip ceiling
- **Tip reveal animation**:
  - After dropoff: fare shown immediately
  - Tip amount hidden for 0.8 seconds — shows "..." 
  - Then tip number ticks up from 0 to final value over 0.5 seconds
  - If no tip: shows "No tip" briefly then fades
- Total added to `wallet` (global state variable)

#### Outcome of 2.3
Completing a ride adds money to the wallet. Tip reveal feels like a small moment.

---

### Section 2.4 — HUD (Day 9–10)

#### Tasks
- Create `src/scenes/HUDScene.lua` — drawn on top of GameScene every frame
- HUD elements:
  - **Top left**: In-game clock (06:00 → 22:00 per day, advances in real time with day timer)
  - **Top left below clock**: Day counter (Day 1 of 30)
  - **Top right**: Current wallet (NPR X,XXX)
  - **Top right below wallet**: Debt remaining (NPR X,X,XXX) + days left
  - **Bottom left**: Fuel bar (coloured bar, green→yellow→red as it drains)
  - **Bottom left below fuel**: Vehicle condition bar (green→yellow→red)
  - **Bottom right**: Minimap (see Section 2.5)
- Debt bar colour logic:
  - Ahead of pace: green
  - On track: yellow
  - Behind: orange
  - Critical (needs >NPR 25k/day): red + slow pulse animation
- All text uses Noto Sans font loaded in `love.load()`

#### Outcome of 2.4
All critical game information is visible on screen at all times.

---

### Section 2.5 — Minimap (Day 10–11)

#### Tasks
- Render entire map to a LÖVE2D `Canvas` at small scale (1/8th of actual size)
- Draw canvas in bottom-right corner of screen (180×180px box)
- On minimap, draw:
  - White dot = player position
  - **Directional arrow** pointing toward destination (when ride active) — not the exact destination dot, just an arrow on the edge of the minimap pointing the right direction
  - No passenger icons on minimap — too cluttered
- Minimap border: thin rounded rectangle
- Minimap updates every frame

#### Decision: Destination direction
Calculate angle from player to destination. Draw a small arrow at the edge of the minimap circle at that angle. Standard compass-style navigation.

#### Outcome of 2.5
Player can always tell which direction their destination is.

---

### Sprint 2 Full Outcome
> Passengers spawn on the map with a raised-hand icon and a shrinking despawn timer. Player drives to them, sees a popup with destination and estimated fare, picks them up, drives to destination, drops them off. Fare and tip are calculated. Money appears in the HUD wallet. The minimap shows where to go.

### What is NOT in Sprint 2
- No fuel system (fuel bar visible but not draining yet)
- No NPC traffic
- No day/night cycle
- No potholes
- No day end screen
- No shop or mechanic
- No saving

### Handoff required from teammates
| From | File | Needed by |
|------|------|-----------|
| Person A | `maps/map_kathmandu_v2.json` with Spawns + Zones object layers | Day 6 |
| Person B | `assets/sprites/passengers/` — tourist, worker, student sprites | Day 9 |
| Person B | `assets/sprites/ui/hud_fuel_bar.png`, `hud_condition_bar.png` | Day 9 |
| Person B | `assets/sprites/ui/raised_hand_icon.png` | Day 7 |

---

## Sprint 3 — Time, Fuel, and Day Structure
**Duration: Days 13–18**
**Single goal: The day cycle works. Fuel drains. The day ends. The debt counts down.**

---

### Section 3.1 — Time and Day System (Days 13–14)

#### Tasks
- Create `src/systems/TimeSystem.lua`
- In-game clock: 06:00 → 22:00 = one full day = 7 real minutes
- Clock advances in real time. At 22:00: day ends automatically
- `TimeSystem` exposes: `currentHour`, `currentMinute`, `dayNumber`, `isDay()`
- Player can also end the day early: in pause menu, option "End day early" → goes to DayEndScene
- **Mid-ride when day ends**: 
  - If player has a passenger: ride is cancelled, fare not counted, passenger removed
  - Fuel that drained during that incomplete ride is still deducted
  - Day end screen shown immediately after

- Create `src/scenes/DayEndScene.lua`:
  - Shows: fares earned, tips earned, fuel cost, repairs cost, net today, debt remaining, days left
  - Shows vehicle condition bar
  - Three buttons: **Next Day**, **Visit Mechanic**, **Shop**
  - Pressing Next Day increments day counter, resets daily earnings tracker, spawns back in at start position

#### Outcome of 3.1
Days have a beginning and an end. The clock ticks. The day ends at 22:00. The summary screen appears.

---

### Section 3.2 — Fuel System (Days 14–15)

#### Tasks
- Create `src/systems/FuelSystem.lua`
- Fuel: 0–100 (starts full each day)
- Drain logic:
  - Drains ONLY when WASD is held (player is moving)
  - No drain when idle, in menu, or in conversation
  - Drain rate formula: `drainRate = baseRate * speedFactor * conditionFactor`
    - `baseRate`: defined per vehicle in `vehicles.lua` (based on real mileage — Bajaj drains less than Maruti)
    - `speedFactor`: higher speed = more drain (0.8× at low speed, 1.2× at high speed)
    - `conditionFactor`: worse condition = less efficient engine = more drain (1.0 at 100%, 1.3 at 30%)
  - All multiplied by `dt`
- Fuel bar in HUD updates in real time
- **Petrol station refuel** (mid-day):
  - Drive within 50px of petrol station object (from Tiled Spawns layer, `type = 'petrol'`)
  - Prompt appears: "Refuel? NPR [cost] — Press F"
  - Press F: short wait (3 real seconds, show loading bar), fuel restored to 100%, cost deducted from wallet
  - Cost: NPR 200–500 depending on vehicle size (defined in vehicles.lua)
- **Mechanic refuel** (end of day only, from DayEndScene):
  - Full refuel, slightly more expensive than petrol station (NPR 100 premium — convenience fee)
  - Instant, no wait time

- **Fuel empty mid-day**:
  - Bike stops immediately
  - Screen fades to black briefly
  - Day resets: day counter stays same, all money earned today is cancelled, damage to bike remains
  - Player spawns at start position with full fuel (the "you had to push the bike home and borrow fuel" implied result)
  - Brief message on screen: "Out of fuel. Day lost."

#### Outcome of 3.2
Fuel drains while driving. Running out resets the day and cancels all earnings. Fuel management is genuinely high-stakes.

---

### Section 3.3 — Debt and Chapter System (Days 15–16)

#### Tasks
- Create `src/systems/DebtSystem.lua`
- Create `src/data/chapters.lua`:

| Chapter | Target | Days | Starting vehicle | Zones available |
|---------|--------|------|-----------------|-----------------|
| 1 | NPR 1,00,000 | 30 | Bajaj 100cc | Thamel only |
| 2 | NPR 3,00,000 | 45 | Bajaj / Pulsar / Maruti | Thamel + Ring Road |
| 3 | NPR 7,00,000 | 60 | All cars | Full city + Airport |
| 4 | NPR 20,00,000 | 60 | All vehicles | Full city, hardest events |

- Daily pace calculation:
  - `dailyNeeded = debtRemaining / daysLeft`
  - Compare to today's earnings to set pace status
  - Status updates HUD colour (green / yellow / orange / red pulse)
- **Chapter fail**: Day 30 with debt unmet → `GameOverScene.lua`
  - Shows: amount short, day reached, what you keep (vehicle + upgrades)
  - Single button: "Try Again" — restarts chapter, resets cash and day counter only
- **Chapter clear**: Debt paid → `ChapterClearScene.lua`
  - Shows: "Debt cleared" + total earned + days taken
  - Short jingle plays
  - Button: "Continue" → loads next chapter config, keeps vehicle and upgrades

- Create `src/systems/SaveSystem.lua`:
  - Saves on every day end and on chapter clear/fail
  - `love.filesystem.write('save.json', jsonString)`
  - Saves: `{ chapter, cash, vehicle, upgrades, currentDay, debtRemaining }`
  - Loads on game start: if save exists, offer "Continue" on menu screen
  - Use a simple JSON encoder (include `json.lua` library in `/src/lib/`)

#### Outcome of 3.3
The debt clock is real. Days count down. Clearing a chapter moves to the next. Failing restarts it. Progress saves between sessions.

---

### Section 3.4 — Vehicle Condition and Damage (Day 17)

#### Tasks
- Expand `src/systems/DamageSystem.lua` (created in Sprint 1 for buildings)
- Add all damage sources:

| Event | Damage | Notes |
|-------|--------|-------|
| Building hit | -20 fixed | Hard stop, screen shake + crack |
| Pothole hit | 0 to -15 random | Roll each hit — some go unpunished |
| NPC traffic crash | -15 fixed | Screen shake + crack |
| Completing a ride | -2 fixed | Normal wear per trip |
| Refuel stop (rough road) | -1 | Minor — just from driving around |

- Condition affects:
  - Tip ceiling (linear: 100% condition = full tip range, 50% = half tip ceiling, 0% = no tips possible)
  - Fuel drain rate (worse condition = higher drain)
  - Speed cap (below 30% condition: max speed reduced by 20%)

- **Visual crack effect**:
  - On damage hit: draw crack overlay sprite on screen edges for 0.3 seconds
  - Crack overlay: transparent PNG with crack lines at screen corners — Person B to create
  - Severity of overlay scales with damage amount (small crack for -2, full corner cracks for -20)

- **Mechanic repair options** (from DayEndScene → MechanicScene):

| Option | Cost | Effect |
|--------|------|--------|
| Quick wash | NPR 500 | +5% tip chance tomorrow only |
| Oil change | NPR 2,000 | +15 condition, slower wear for 3 days |
| Tyre replacement | NPR 4,500 | Restores condition fully for tyre component |
| Full service | NPR 12,000 | Condition → 100% |
| Refuel only | NPR 300–600 | Fuel → 100% |

#### Outcome of 3.4
Vehicle degrades meaningfully. Damage has consequence. Mechanic is the solution.

---

### Section 3.5 — Day/Night Cycle (Day 18)

#### Tasks
- Link `TimeSystem.currentHour` to a screen overlay
- Overlay: dark blue-black rectangle drawn over entire game at partial alpha
- Alpha curve:

| Time | Alpha | Colour |
|------|-------|--------|
| 06:00–07:00 | 0.3→0 | Warm orange (dawn) |
| 07:00–17:00 | 0 | None (full day) |
| 17:00–19:00 | 0→0.2 | Orange tint (dusk) |
| 19:00–22:00 | 0.2→0.45 | Dark blue (night) |

- At night (hour > 19):
  - Draw headlight cone sprite in front of car (Person B delivers: soft white cone PNG)
  - Draw streetlamp glow sprites at lamp tile positions (Person B delivers: soft yellow circle PNG)
  - Lamp positions: read from a `Lamps` object layer in the Tiled map (Person A adds these)
- Passenger spawn rate halves at night (fewer people out late)
- NPC traffic halves at night

#### Outcome of 3.5
The world gets dark at night. Headlights appear. Morning comes again.

---

### Sprint 3 Full Outcome
> The full game loop is playable. Days start at 06:00 and end at 22:00 or when the player ends early. Fuel drains while driving and running out resets the day and cancels all money. The debt clock counts down. Completing 30 days either clears the chapter or fails it. Progress saves between sessions. The world goes dark at night.

### What is NOT in Sprint 3
- No NPC traffic
- No potholes on map (DamageSystem exists but pothole tile detection not yet wired)
- No shop
- No vehicle upgrades
- No events (bandh, festival)
- No police/cop tiles
- No tutorial

### Handoff required from teammates
| From | File | Needed by |
|------|------|-----------|
| Person A | `maps/map_kathmandu_v3.json` with Lamps object layer added | Day 18 |
| Person B | `assets/sprites/fx/crack_overlay.png` | Day 17 |
| Person B | `assets/sprites/fx/headlight_cone.png` | Day 18 |
| Person B | `assets/sprites/fx/lamp_glow.png` | Day 18 |

---

## Sprint 4 — The Living City
**Duration: Days 19–24**
**Single goal: The city feels alive — traffic, potholes, events, police, shop.**

---

### Section 4.1 — NPC Traffic (Days 19–20)

#### Tasks
- Create `src/entities/NPCVehicle.lua`
- NPC vehicles follow pre-defined paths from the Tiled map:
  - Person A adds a `Traffic` object layer with Polyline objects — these are the paths
  - NPCs loop along their path indefinitely
  - NPC speed: slower than max player speed (creates natural weaving challenge)
- Spawn logic:
  - 5–10 NPCs active on current visible map area
  - Sometimes zero (random quiet periods)
  - More NPCs during festival event (see Section 4.3)
  - Fewer NPCs at night
- NPC collision with player:
  - If car overlaps NPC bounding box: player velocity zeroed, -15 condition, screen shake + crack
  - NPC continues on path unaffected (simple, no NPC reaction needed)
- NPC sprite: use placeholder coloured rectangle, swap with Person B's NPC sprite when ready

#### Decision: NPC paths
Paths defined in Tiled as Polyline objects in a `Traffic` layer. Named by zone: `npc_path_thamel_1`, `npc_path_ringroad_1` etc. Coder reads all Polyline objects from Traffic layer and spawns NPCs on them.

#### Outcome of 4.1
The city has moving vehicles. Dodging them is a real skill. Crashing hurts.

---

### Section 4.2 — Potholes (Day 20)

#### Tasks
- Pothole tiles placed by Person A on the `Potholes` layer in Tiled
- In `GameScene.lua`: check each frame if any car corner overlaps a pothole tile
- On pothole hit:
  - Roll damage: `math.random(0, 15)` — zero is valid (lucky miss)
  - If damage > 0: apply to condition, trigger screen shake (smaller than building hit), trigger crack overlay (smaller severity)
  - Speed reduced to 50% for 0.5 seconds (jolt effect)
  - No repeated damage from same pothole tile — implement a 2-second cooldown per tile position
- Pothole repair option (costs NPR, from a prompt when nearby):
  - Drive slowly over an unrepaired pothole → optional prompt: "Repair pothole? NPR 500 — Press R"
  - Repair: pothole tile visually replaced with normal road tile, stays repaired for rest of that in-game day
  - Next day: potholes reset (they come back — this is Kathmandu)

#### Outcome of 4.2
Potholes are real hazards. Most are survivable. Accumulated damage from ignoring them adds up.

---

### Section 4.3 — City Events (Days 20–22)

#### Tasks
- Create `src/systems/EventSystem.lua`
- Create `src/data/events.lua` — define all events:

**Bandh (general strike)**
- Trigger: random, ~15% chance each day, announced at start of previous day
- Effect: certain road tiles in one zone become blocked (speed = 0, visual barrier drawn)
- Player notified day before: "Bandh expected tomorrow in [zone]"
- If player drives through: triple fare multiplier for any ride completed that day
- Bandh ends at day end

**Festival surge (Dashain / Tihar)**
- Trigger: scheduled — Day 14 and Day 24 of any chapter
- Effect: passenger spawn rate ×3, fare multiplier ×1.8, NPC traffic ×2
- Duration: 3 in-game days
- Visual: festival decoration tiles activated on map (Person A marks these as toggleable in Tiled)
- FOMO mechanic: notification shown 1 day before: "Festival tomorrow — expect high demand"

**VIP convoy**
- Trigger: random, ~10% chance on any given day, occurs once per day if triggered
- Effect: one major road locked for 2 real minutes — NPC convoy sprites move slowly along it
- Player must reroute around it
- Passengers in transit get impatient: tip ceiling reduced by 30% during convoy delay

**Cow on road**
- Trigger: random, any time, any zone (except airport highway)
- Effect: single cow sprite spawned on a road tile — player must stop or navigate around it
- Cow despawns after 60 seconds
- No damage from hitting cow (it moves just in time — classic Kathmandu experience)
- No mechanic effect — pure atmosphere and minor obstacle

- All active events stored in `EventSystem.activeEvents[]`
- Events check against this list to apply their effects each frame

#### Outcome of 4.3
The city is unpredictable. Days are never identical. Bandhs create risk/reward decisions.

---

### Section 4.4 — Police / Speed Fine (Day 22)

#### Tasks
- Person A places cop tile objects in Tiled `Spawns` layer: `type = 'cop_zone'`
- Person A places a road sign tile just before each cop zone (visual warning — no code needed)
- In `GameScene.lua`: check if player is on a cop zone tile AND speed > speedLimit threshold
  - Speed limit threshold: 60% of vehicle's max speed
  - If over threshold: fine triggered immediately
  - Fine amount: NPR 1,000 (fixed)
  - Visual feedback: bright yellow flash on screen for 0.5 seconds + "FINE: NPR 1,000" text displayed for 2 seconds
  - Audio: short whistle SFX
  - Fine deducted from wallet immediately
  - 5-second cooldown before another fine can be triggered from same cop zone (no repeated fining)

#### Decision: How player learns the speed limit
Road sign tile placed by Person A just before the cop zone. Player gets fined once, sees the sign, slows down next time. No UI explanation needed. Learn by experience.

#### Outcome of 4.4
Speeding through police zones has a real cost. Players learn to read the road signs.

---

### Section 4.5 — Shop System (Days 22–24)

#### Tasks
- Create `src/systems/ShopSystem.lua`
- Create `src/scenes/ShopScene.lua`
- Accessed from DayEndScene → "Shop" button
- Four tabs in the shop UI:

**Vehicles tab**

| Vehicle | Cost | Passengers | Notes |
|---------|------|-----------|-------|
| Bajaj 100cc | Starting vehicle | 1 | Galli access |
| Pulsar 150 | NPR 40,000 | 1 | Faster, better highway |
| Maruti 800 | NPR 1,20,000 | 2 | Unlocks Ring Road zone |
| Hyundai i10 | NPR 2,80,000 | 3 | VIP passengers, airport |
| Microbus | NPR 5,00,000 | 6 | Festival events, slow in gallis |
| Electric SUV | NPR 8,00,000 | 4 | No fuel cost, Ch.4 only |

**Zone unlocks tab**

| Zone | Cost | Notes |
|------|------|-------|
| Ring Road | Free on Ch.2 | Auto-unlocked |
| Airport corridor | NPR 80,000 | Highest single fares |
| Patan heritage zone | NPR 50,000 | Elderly + tourist spawns |
| Nagarkot highway | NPR 1,50,000 | Long-distance, high fuel |

**Upgrades tab**

| Upgrade | Cost | Effect |
|---------|------|--------|
| Fuel efficiency kit | NPR 15,000 | -20% fuel drain permanently |
| Reinforced suspension | NPR 20,000 | Pothole damage -40% |
| AC unit | NPR 25,000 | +15% tip ceiling in daytime |
| GPS | NPR 30,000 | Shows exact tip % before accepting ride |

**Insurance tab**

| Option | Cost | Effect |
|--------|------|--------|
| Weekly insurance | NPR 5,000/week | Covers one breakdown/crash per week — condition not deducted |

- Anchoring Effect implementation:
  - Each vehicle shows original market price (struck through) then game price
  - Example: ~~NPR 1,80,000~~ → NPR 1,20,000
- Purchase confirmation dialog before deducting money
- Save state updated immediately on purchase

#### Outcome of 4.5
Players can buy better vehicles, unlock zones, and upgrade their vehicle. Every purchase competes with the debt for the same NPR.

---

### Sprint 4 Full Outcome
> The city breathes. NPC traffic fills the roads and must be dodged. Potholes punish reckless driving. Bandhs and festivals change the city daily. Police zones fine speeders. The shop lets players invest in growth at the cost of debt progress.

### What is NOT in Sprint 4
- No tutorial
- No pause menu (pause key exists but menu not built)
- No local leaderboard
- No audio (systems are in place, audio files just not wired yet)
- No final polish

### Handoff required from teammates
| From | File | Needed by |
|------|------|-----------|
| Person A | `maps/map_kathmandu_final.json` — Potholes layer, Traffic paths, cop zones, festival tile toggles | Day 19 |
| Person B | `assets/sprites/npc_vehicle.png` | Day 19 |
| Person B | `assets/sprites/cow.png` | Day 22 |
| Person B | `assets/sprites/fx/bandh_barrier.png` | Day 20 |
| Person B | ALL audio files | Day 23 |

---

## Sprint 5 — Polish and Integration
**Duration: Days 25–30**
**Single goal: A complete, shippable demo that feels like a real game.**

---

### Section 5.1 — Full Asset Integration (Day 25)

#### Tasks
- Replace every coloured rectangle and placeholder with real sprites from Person B
- Replace placeholder font references with Noto Sans
- Verify every sprite renders at correct size and rotation
- Fix any sprite offset issues (pivot points, rotation centres)
- Verify Tiled final map renders correctly with all layers
- Test every zone, spawn point, petrol station, workshop, cop zone

---

### Section 5.2 — Audio Integration (Day 25–26)

#### Tasks
- Wire all audio using `love.audio.newSource()`
- Audio list:

| Sound | File | Trigger |
|-------|------|---------|
| Engine loop (Bajaj) | `sfx_engine_bajaj.ogg` | Playing while moving, pitch shifts with speed |
| Engine loop (car) | `sfx_engine_car.ogg` | Same as above for car tier |
| Horn | `sfx_horn.ogg` | H key |
| Coin collect | `sfx_coin.ogg` | On fare received |
| Pothole hit | `sfx_pothole.ogg` | On pothole damage |
| Crash | `sfx_crash.ogg` | On building/NPC collision |
| Cop whistle | `sfx_cop.ogg` | On fine triggered |
| Tip reveal tick | `sfx_tip_tick.ogg` | During tip number animation |
| Fuel low warning | `sfx_fuel_low.ogg` | When fuel < 20% |
| Day end jingle | `sfx_day_end.ogg` | On DayEndScene open |
| Chapter clear jingle | `sfx_chapter_clear.ogg` | On ChapterClearScene |
| Radio track | `music_radio.ogg` | Background loop while driving |
| Menu music | `music_menu.ogg` | On menu screen |

- Engine sound: loops continuously while moving, pitch modified by `source:setPitch(speedRatio)` — higher speed = higher pitch
- Radio track: plays at low volume in background, fades slightly during events

---

### Section 5.3 — Tutorial (Day 26)

#### Tasks
- First time the game is launched (check save file — if no save exists): tutorial mode
- Tutorial is a series of **3 text prompt overlays**, shown sequentially during the first ride:
  1. When game starts: *"A passenger is waiting. Drive to the raised hand icon."*
  2. When near first passenger: *"Press E to pick up the passenger."*
  3. After pickup: *"Follow the arrow on the minimap to the destination. Press E to drop off."*
- After these 3 prompts: tutorial done, flag saved in save file, never shown again
- No skip option needed — prompts disappear after 5 seconds anyway

---

### Section 5.4 — Pause Menu (Day 26–27)

#### Tasks
- `Escape` key toggles pause
- Pause freezes: game time, fuel drain, passenger despawn timers, NPC movement
- Pause menu options:
  - **Resume** — unpause
  - **End day early** — goes to DayEndScene (only available when not mid-ride)
  - **Quit to menu** — confirm dialog, then title screen (save state preserved)
- Pause screen: dark overlay + centred menu box
- Mid-ride pause: "End day early" button is greyed out and shows "Finish current ride first"

---

### Section 5.5 — Local Leaderboard (Day 27)

#### Tasks
- Stored in save file: `leaderboard: { fastestChapter1Clear, bestSingleDayEarnings, highestSingleTip }`
- Updated automatically when records are broken
- Displayed on the title/menu screen in a small panel
- No UI complexity needed — just three lines of text with labels

---

### Section 5.6 — Screen Effects and Juice (Day 27–28)

#### Tasks
- **Screen shake**: already in for building hits — verify it works for all damage types
- **Crack overlay**: verify scaling by damage severity
- **Cop fine flash**: yellow screen flash 0.5 seconds
- **Fuel low pulse**: when fuel < 20%, fuel bar pulses slowly (alpha oscillates)
- **Debt critical pulse**: when pace is critical, debt display pulses red
- **Tip reveal**: tick-up animation verified working
- **Day/night transition**: verify smooth alpha fade, no sudden jumps
- **Bandh barrier animation**: barriers should have a slight visual flicker to feel active

---

### Section 5.7 — Bug Fix Day (Day 29)

#### Rules
- No new features. Zero. Not one.
- Fix only: crashes, progression blockers, incorrect money calculations, HUD display errors, audio loops not stopping
- Priority order:
  1. Game-breaking crashes
  2. Money/debt calculation errors
  3. Passenger not spawning or despawning correctly
  4. Save/load failures
  5. Audio issues

---

### Section 5.8 — Final Build (Day 30)

#### Tasks
- Package as `.love` file: `zip -9 -r sadak.love .`
- Test on a clean machine (not the development machine)
- Verify: title screen loads, new game works, save/load works, all 4 chapters accessible
- Record a 3-minute gameplay video as backup for presentation
- Prepare a one-paragraph spoken description of what each psychological mechanic does in the game (for Q&A)

---

### Sprint 5 Full Outcome
> A complete, playable demo. Real art, real audio, real map. Tutorial guides new players. Pause menu works. Progress saves. Local leaderboard tracks records. The game is packaged as a .love file ready to run on any desktop.

### What is NOT in Sprint 5 (scope cuts confirmed)
- No second city map (Pokhara)
- No online leaderboard
- No multiplayer or co-op
- No fleet management endgame
- No infinite mode
- No driver syndicate
- No story dialogue or NPC personalities

---

## Full Sprint Summary

| Sprint | Days | Focus | Playable result |
|--------|------|-------|-----------------|
| Pre-Sprint | Day 0 | Setup | Blank window opens |
| Sprint 1 | 1–5 | Car + map + collision | Car drives on map, buildings block |
| Sprint 2 | 6–12 | Passenger loop + HUD | Full ride: pickup → dropoff → fare |
| Sprint 3 | 13–18 | Time + fuel + debt | Full day cycle, saving, chapter system |
| Sprint 4 | 19–24 | Traffic + events + shop | Living city, investments, consequences |
| Sprint 5 | 25–30 | Polish + audio + build | Shippable demo |

---

## Master Handoff Schedule

| Sprint end | Person A delivers | Person B delivers |
|------------|-------------------|-------------------|
| Sprint 1 (Day 5) | `map_kathmandu_v1.json` — basic roads + buildings | `kathmandu_tiles.png` tileset + `bike_bajaj.png` |
| Sprint 2 (Day 12) | `map_kathmandu_v2.json` — Spawns + Zones layers | Passenger sprites + HUD bar sprites + raised hand icon |
| Sprint 3 (Day 18) | `map_kathmandu_v3.json` — Lamps layer added | Crack overlay + headlight cone + lamp glow sprites |
| Sprint 4 (Day 24) | `map_kathmandu_final.json` — Potholes + Traffic + Cops + Festival tiles | All remaining sprites + ALL audio files |
| Sprint 5 (Day 25) | No further changes to map | All UI screen backgrounds |

---

## Golden Rule

> **The coder is never blocked.** If Person A's map is late, use the placeholder. If Person B's sprites are late, use coloured rectangles. The game must always run. Features are integrated when assets arrive — not when they are demanded.

---

*Sadak — सडक | Sprint Plan v1.0*
