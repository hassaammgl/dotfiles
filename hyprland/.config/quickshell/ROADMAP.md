# Quickshell Redesign Roadmap

## 1) Inventory

### A) Quickshell files (root + modules/ + Components/ + pam/ + config)
| File | Controls what | Visual impact | Uses Colors or Theme or both | Hardcoded values count (approx) | Status [ ] |
|---|---|---|---|---|---|
| `shell.qml` | Entry: instantiates all windows + IPC | Low | neither | 0 | [x] |
| `Bar.qml` | Bar panel/layout (edge/vertical), sizes 44 vertical/38 horizontal, margins 8, spacing 6 | High | Colors.background + Theme | ~8 | [~] ignore for now |
| `BarState.qml` | Bar state + persistence bar.json | None | neither | 0 | [ ] |
| `OverlayState.qml` | Overlay flags + close/toggle/show | None | neither | 0 | [ ] |
| `Theme.qml` | Design system (Wallust palette → colors, font/type/space/r/motion/icons/bar/osd, helpers) | High | source of truth | 0 | [ ] |
| `Colors.qml` | Legacy bridge to Theme; hardcoded `fontFamily: "JetBrainsMono Nerd Font"` | Med | both | 1 | [ ] |
| `Notifications.qml` | Notification popups (server, cardW 340, timeouts/urgency, drag dismiss) | High | Colors heavy; some Theme | ~25 | [ ] |
| `NotifState.qml` | History max 50, persistence notif-history.json | Low | Colors (accentFor) | 1 | [ ] |
| `NotifSidebar.qml` | History sidebar (Theme.panelWidth), empty Mascot | Med | Theme + Colors | ~12 | [ ] |
| `LauncherOverlay.qml` | App launcher grid (cell 118, colCount 6, tile 96x96 r22, 3 rows, max 36) | High | Colors heavy, some Theme | ~20 | [ ] |
| `PowerOverlay.qml` | Session actions overlay | Med | Colors/Theme mixed | ~8 | [ ] |
| `MediaOverlay.qml` | Media + cava visualizer | High | Colors + Theme | ~15 | [ ] |
| `MediaState.qml` | MPRIS + fallback | None | neither | 0 | [ ] |
| `ScreenshotOverlay.qml` | Screenshot UI (pick/preview) | Med | Colors/Theme mixed | ~10 | [ ] |
| `ScreenshotState.qml` | Screenshot flow (script, delay 280ms) | Low | neither | 1 | [ ] |
| `WallpaperOverlay.qml` | Wallpaper carousel (PathView), scans ~/Pictures/Wallpapers, applies via wallpaper.sh | High | Colors/Theme mixed | ~18 | [ ] |
| `GifOverlay.qml` | ~~Removed~~ (video→GIF setup deleted) | — | — | — | [x] |
| `KeybindsOverlay.qml` | Keybinds cheatsheet from keybinds.txt | Med | Colors | ~6 | [ ] |
| `ClipboardOverlay.qml` | clippaste history via cliphist (copy/delete modes) | Med | Colors | ~10 | [ ] |
| `EmojiOverlay.qml` | Emoji picker (grid 10×cell72, max 80, Noto Color Emoji) | Med | Colors | ~12 | [ ] |
| `LockOverlay.qml` | Lockscreen (WlSessionLock), PAM via LockState, wallpaper current | Med | Theme/Colors mixed | ~8 | [ ] |
| `LockState.qml` | Lock state + PAM context | Low | neither (auth logic) | 0 | [ ] |
| `OsdOverlay.qml` | OSD (volume/brightness/mic), uses Theme.osd/osdX | Med | Theme/Colors | 2 | [ ] |
| `OsdState.qml` | OSD state + Pipewire + backlight + brightnessctl (hide 1400ms, steps 0.1/0.05) | Low | neither | 3 | [ ] |
| `DashOverlay.qml` | Dashboard (CPU/mem/disk/net/procs), opens btop | Med | Theme/Colors mixed | ~15 | [ ] |
| `DashState.qml` | Facade over Host | None | neither | 0 | [ ] |
| `DesktopWidgets.qml` | Desktop widgets (clock/calendar/stats/media/mascot), scale 0.75–1.35, cardW 236*s | High | Colors heavy + Theme | ~30 | [ ] |
| `WidgetState.qml` | Widget state persisted widgets.json | None | neither | 0 | [ ] |
| `Host.qml` | Metrics polling 2000ms, parses /proc/*, ps, iface | Low | neither | 1 | [ ] |
| `Time.qml` | SystemClock (Minutes) | None | neither | 0 | [ ] |
| `emojis.json` | Emoji data (854) | None | N/A | N/A | [ ] |
| `cava-media.conf` | Cava config | None | N/A | N/A | [ ] |
| `assets/*` | Visual assets | Med | N/A | N/A | [ ] |

### B) bar/ (was modules/) — IGNORE for now with Bar
| File | Controls what | Visual impact | Uses Colors/Theme | Hardcoded | Status |
|---|---|---|---|---|---|
| `Audio.qml` | Bar audio popup | Med | Colors heavy | ~12 | [~] ignore |
| `BarButton.qml` | Base bar button | Med | Colors | ~10 | [~] ignore |
| `Battery.qml` | Battery indicator | Med | Colors | ~6 | [~] ignore |
| `Bluetooth.qml` | Bluetooth popup | Med | Colors | ~15 | [~] ignore |
| `Brightness.qml` | Brightness popup | Med | Colors | ~8 | [~] ignore |
| `Capsule.qml` | Empty Item (placeholder) | None | neither | 0 | [~] ignore |
| `Clock.qml` | Bar clock | Med | Colors | ~8 | [~] ignore |
| `Cpu.qml` | Bar CPU/dashboard toggle | Med | Colors | 2 | [~] ignore |
| `Launcher.qml` | Bar launcher (Capsule wrapper) | Med | Colors | ~2 | [~] ignore |
| `LevelBar.qml` | Expandable level bar | Med | Colors | ~12 | [~] ignore |
| `Mascot.qml` | Mascot image/anim | Med | neither | ~4 | [~] ignore |
| `Network.qml` | Network/wifi popup (large) | High | Colors heavy | ~30 | [~] ignore |
| `PopSlider.qml` | Popup slider | Med | Colors | ~6 | [~] ignore |
| `Power.qml` | Bar power | Med | Colors | ~2 | [~] ignore |
| `StatusIcons.qml` | Status icons grid in Capsule | Med | Colors | ~6 | [~] ignore |
| `Tray.qml` | System tray | Med | neither | ~6 | [~] ignore |
| `Widgets.qml` | Widgets toggle | Med | Colors | ~2 | [~] ignore |
| `Workspaces.qml` | Workspace pills | High | Colors | ~10 | [~] ignore |

### C) Components/
| File | Controls what | Visual impact | Uses Colors/Theme | Hardcoded | Status [ ] |
|---|---|---|---|---|---|
| `Capsule.qml` | Capsule rect (active) | Med | Theme | ~4 | [ ] |
| `Card.qml` | Card (Surface wrapper) | Med | Theme | 2 | [ ] |
| `Divider.qml` | Divider | Low | Theme | 3 | [ ] |
| `IconButton.qml` | Icon button | Med | Theme | ~4 | [ ] |
| `Popup.qml` | Popup container | Med | Theme | ~6 | [ ] |
| `Scrim.qml` | Scrim | Med | Theme | 2 | [ ] |
| `SectionHeader.qml` | Section header | Low | Theme | 1 | [ ] |
| `Slider.qml` | Slider | Med | Theme | ~6 | [ ] |
| `Surface.qml` | Surface rect | Med | Theme | 2 | [ ] |
| `Toggle.qml` | Toggle switch | Med | Theme | ~4 | [ ] |

### D) External configs (verified)
Hyprland (execs/keybinds/rules), scripts (keybinds.txt, wallpaper.sh, screenshot-capture.sh, video-to-gif*.sh, gif-thumbs.sh, brightness/volume/bar-orient/toggle-bar/wallpaper-picker), `~/.cache/wallust/quickshell.json`, PAM (`pam/password.conf`).

## 2) Phases

### Phase 0: Safety (reason: preserve working state, allow revert)
- [ ] Ensure config is in a git repo (already is at `/home/ratx86/dotfiles/hyprland/.config/quickshell` symlinked; track under dotfiles repo). Create/commit baseline if needed.
- [ ] Note revert strategy (git stash/checkout/reset).
- Rationale: READ-ONLY exploration done; all future edits must be reversible.

### Phase 1: Foundation (reason: make Theme the single source of truth)
- [ ] Audit all files importing `Colors.qml` vs `Theme.qml` (list every file). Currently many legacy use `Colors.*`, newer use `Theme.*`.
- [ ] Migrate usage from `Colors.*` to `Theme.*` where equivalent exists (prefer Theme). Keep `Colors.qml` as bridge temporarily or remove after migration.
- [ ] Extend `Theme.qml` with missing design tokens: radius scale variants if needed, durations (fast/normal/slow etc.), font sizes (map common hardcoded to Theme.type), card/surface sizes, spacing, border/shadow tokens, popup/card dimensions (cardW, panel widths), overlay timing (hide 1400ms, delay 280ms), steps (volStep 0.1, briStep 0.05), polling (2000ms). List each hardcoded value to move.
- [ ] Goal: changing only `Theme.qml` + Wallust palette restyles whole shell.
- Rationale: centralizes design, enables small targeted edits later.

### Phase 2: Components/ (reason: shared primitives)
- [ ] Review `Components/` vs `modules/Capsule.qml` (modules/Capsule.qml is empty Item; Launcher/Power/StatusIcons in modules reference Capsule concept). Decide merge/consolidation: prefer single Capsule implementation (likely `Components/Capsule.qml` as Rectangle). Update usages.
- [ ] Standardize Components: Card/Surface/Slider/Toggle/IconButton/Popup/Scrim/SectionHeader/Divider/Capsule to use Theme tokens exclusively (no Colors.*).
- [ ] Document API of each Component (props).
- Rationale: reduces duplication, ensures consistency.

### Phase 3: Bar and bar/ — DEFERRED (ignore list)
- [~] Skip for now. Revisit after overlays + Theme foundation.
- Includes: `Bar.qml` + all of `bar/*` (Workspaces, Clock, Tray, Network, etc.).

### Phase 4: Daily-use overlays (PRIORITY — do next after Theme/Components)
Order: LauncherOverlay, ControlCenter, Notifications + NotifSidebar, OsdOverlay, PowerOverlay.
- [ ] Migrate each to Theme tokens, extract repeated values to Theme or Component props.
- Rationale: most-used surfaces; bigger win than bar polish right now.

### Phase 5: Other overlays
MediaOverlay, DashOverlay, WallpaperOverlay, ClipboardOverlay, EmojiOverlay, KeybindsOverlay, ScreenshotOverlay, DesktopWidgets (in that order or by impact). Migrate to Theme tokens, centralize hardcoded geometry/animations. (GifOverlay removed.)

### Phase 6: LockOverlay (visual only; never touch PAM/auth logic)
- [ ] Visual restyle only (spacing/radii/colors via Theme). Do not modify LockState.qml, PAM config, or auth flow.
- [ ] Final cleanup: remove remaining Colors.* where possible, update Colors.qml bridge or deprecate, verify no unintended changes.

## 3) Per-file notes (High/Med impact)

| File | What to redesign | Hardcoded (key) | What could break |
|---|---|---|---|
| `Bar.qml` + `bar/*` | **IGNORE for now** | — | — |
| `Notifications.qml` | Card layout, radii/spacing, typography, urgency styling | cardW 340, radii 18, spacing 8/10/12, fonts 11/13/15, margins 14, maxVisible 5 | NotificationServer flow, NotifState.record, drag dismiss/lifecycle |
| `LauncherOverlay.qml` | Grid/cell sizes, tile radii, typography, animations | cell 118, colCount 6, tile 96x96 r22, durations 90/160/180, fonts 10-22/34 | DesktopEntries filtering, navigation (moveSel), launch/close |
| `WallpaperOverlay.qml` | Carousel geometry/tilt, card sizes, radii, animations | cardW/cardH calc, PathView 280/1200ms, tilt 58°, r14/18, fonts 9/12/28/42 | scan/apply via wallpaper.sh, current file tracking, focus grab |
| `MediaOverlay.qml` | Visualizer + actions layout, card/art sizing | many sizes 68-120, radii, durations, fonts 11-36 | cava stdout parsing, MediaState integration |
| `DesktopWidgets.qml` | Widget cards, scale math, layout per corner | scale 0.75–1.35, cardW 236*s, radii 12/14/16, fonts scaled 9-42, durations 180/280 | WidgetState (corner/scale/visibility), UPower, IPC widgets |
| `Notifications/Sidebar` | Consistency | spacing/radii/fonts | history/state coupling |
| `ControlCenter` (if touched later) | Panel width via Theme.panelWidth | mixed Theme/Colors | pages/state, services |
| `OsdOverlay` | Positioning via Theme.osdX/osd | minimal hardcoded | OsdState timing (1400ms) — logic stays |
| `LockOverlay` | Visual only | widths/heights/radii/fonts | LockState/PAM (never modify) |

## 4) Ignore list (later)
- Entire **Bar** stack: `Bar.qml` + `bar/*` (Phase 3 deferred).

## 4b) Priority now (important first)
1. **Theme foundation** — extend `Theme.qml` tokens (cardW, radii, fonts, motion, timing, panelWidth). Goal: one file restyles shell.
2. **Components** — Card/Surface/Slider/Toggle/Scrim/etc. Theme-only (enables overlays).
3. **Notifications** + NotifSidebar — high impact, contained.
4. **LauncherOverlay** — daily use.
5. **ControlCenter** / **OsdOverlay** / **PowerOverlay** — daily use.
6. Then Phase 5 overlays (Wallpaper, Media, DesktopWidgets, …).
7. Bar stack last (when ignore lifts).

## 5) Edit log
| Date | File | Change | Why | Reverted? |
|---|---|---|---|---|
| 2026-10-06 | `shell.qml` | Wired `qs.*` imports; removed GifOverlay + gif IPC; marked done (no UI redesign needed) | Restructure + drop video→GIF | No |
| 2026-10-06 | `GifOverlay.qml` + scripts/keybind | Removed overlay, IPC, ALT+G, video-to-gif scripts | User asked to drop setup | No |
| 2026-10-06 | `Bar.qml` + `bar/*` | Moved to ignore list; Phase 3 deferred | Focus important overlays/Theme first | No |

Summary: `shell.qml` done. Bar ignored for now. **Next:** Phase 1 Theme tokens → Components → Notifications / Launcher / ControlCenter.