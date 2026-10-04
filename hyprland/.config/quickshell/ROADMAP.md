# Quickshell Redesign Roadmap

## 1) Inventory

### A) Quickshell files (root + modules/ + Components/ + pam/ + config)
| File | Controls what | Visual impact | Uses Colors or Theme or both | Hardcoded values count (approx) | Status [ ] |
|---|---|---|---|---|---|
| `shell.qml` | Entry: instantiates all windows + IPC | Low | neither | 0 | [ ] |
| `Bar.qml` | Bar panel/layout (edge/vertical), sizes 44 vertical/38 horizontal, margins 8, spacing 6 | High | Colors.background + Theme | ~8 | [ ] |
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
| `GifOverlay.qml` | Video→GIF picker/converter (ffprobe, external scripts) | High | Colors/Theme mixed | ~20 | [ ] |
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

### B) modules/
| File | Controls what | Visual impact | Uses Colors/Theme | Hardcoded | Status [ ] |
|---|---|---|---|---|---|
| `Audio.qml` | Bar audio popup | Med | Colors heavy | ~12 | [ ] |
| `BarButton.qml` | Base bar button | Med | Colors | ~10 | [ ] |
| `Battery.qml` | Battery indicator | Med | Colors | ~6 | [ ] |
| `Bluetooth.qml` | Bluetooth popup | Med | Colors | ~15 | [ ] |
| `Brightness.qml` | Brightness popup | Med | Colors | ~8 | [ ] |
| `Capsule.qml` | Empty Item (placeholder) | None | neither | 0 | [ ] |
| `Clock.qml` | Bar clock | Med | Colors | ~8 | [ ] |
| `Cpu.qml` | Bar CPU/dashboard toggle | Med | Colors | 2 | [ ] |
| `Launcher.qml` | Bar launcher (Capsule wrapper) | Med | Colors | ~2 | [ ] |
| `LevelBar.qml` | Expandable level bar | Med | Colors | ~12 | [ ] |
| `Mascot.qml` | Mascot image/anim | Med | neither | ~4 | [ ] |
| `Network.qml` | Network/wifi popup (large) | High | Colors heavy | ~30 | [ ] |
| `PopSlider.qml` | Popup slider | Med | Colors | ~6 | [ ] |
| `Power.qml` | Bar power | Med | Colors | ~2 | [ ] |
| `StatusIcons.qml` | Status icons grid in Capsule | Med | Colors | ~6 | [ ] |
| `Tray.qml` | System tray | Med | neither | ~6 | [ ] |
| `Widgets.qml` | Widgets toggle | Med | Colors | ~2 | [ ] |
| `Workspaces.qml` | Workspace pills | High | Colors | ~10 | [ ] |

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

### Phase 3: Bar and modules/ (reason: core UI shell)
- [ ] Migrate Bar.qml and modules/* to Theme tokens; reduce Colors.* usage. Focus: Bar, Workspaces, Clock, Tray, StatusIcons, Launcher, Power, Audio/Battery/Bluetooth/Brightness/Network/LevelBar/PopSlider/Mascot/Widgets/Cpu.
- [ ] Address Capsule duplication noted (modules/Capsule empty vs Components.Capsule).
- Rationale: bar is always visible, high impact.

### Phase 4: Daily-use overlays (by usage frequency)
Order: LauncherOverlay, ControlCenter, Notifications + NotifSidebar, OsdOverlay, PowerOverlay.
- [ ] Migrate each to Theme tokens, extract repeated values to Theme or Component props.
- Rationale: optimize most-used surfaces first.

### Phase 5: Other overlays
MediaOverlay, DashOverlay, WallpaperOverlay, ClipboardOverlay, EmojiOverlay, GifOverlay, KeybindsOverlay, ScreenshotOverlay, DesktopWidgets (in that order or by impact). Migrate to Theme tokens, centralize hardcoded geometry/animations.

### Phase 6: LockOverlay (visual only; never touch PAM/auth logic)
- [ ] Visual restyle only (spacing/radii/colors via Theme). Do not modify LockState.qml, PAM config, or auth flow.
- [ ] Final cleanup: remove remaining Colors.* where possible, update Colors.qml bridge or deprecate, verify no unintended changes.

## 3) Per-file notes (High/Med impact)

| File | What to redesign | Hardcoded (key) | What could break |
|---|---|---|---|
| `Bar.qml` | Bar thickness, margins/spacing, bg | sizes 44/38, margins 8, spacing 6, bg via Colors.background | edge/vertical logic (BarState), module layout |
| `Notifications.qml` | Card layout, radii/spacing, typography, urgency styling | cardW 340, radii 18, spacing 8/10/12, fonts 11/13/15, margins 14, maxVisible 5 | NotificationServer flow, NotifState.record, drag dismiss/lifecycle |
| `LauncherOverlay.qml` | Grid/cell sizes, tile radii, typography, animations | cell 118, colCount 6, tile 96x96 r22, durations 90/160/180, fonts 10-22/34 | DesktopEntries filtering, navigation (moveSel), launch/close |
| `WallpaperOverlay.qml` | Carousel geometry/tilt, card sizes, radii, animations | cardW/cardH calc, PathView 280/1200ms, tilt 58°, r14/18, fonts 9/12/28/42 | scan/apply via wallpaper.sh, current file tracking, focus grab |
| `GifOverlay.qml` | Carousel + phases UI, panel sizes, info display | panel 520x280, carousel same, durations, fonts 9-42 | ffprobe parsing, external scripts (thumbs/convert/video-to-gif), phases |
| `MediaOverlay.qml` | Visualizer + actions layout, card/art sizing | many sizes 68-120, radii, durations, fonts 11-36 | cava stdout parsing, MediaState integration |
| `DesktopWidgets.qml` | Widget cards, scale math, layout per corner | scale 0.75–1.35, cardW 236*s, radii 12/14/16, fonts scaled 9-42, durations 180/280 | WidgetState (corner/scale/visibility), UPower, IPC widgets |
| `Network.qml` (modules) | Large popup layout/typography | ~30 hardcoded | Networking state, scanning/connect/passphrase |
| `Workspaces.qml` (modules) | Pill sizes/spacing, typography | pill 26x26 r13, spacing 4/6, fonts 9-11 | Hyprland workspaces/dispatch |
| `Notifications/Sidebar` | Consistency | spacing/radii/fonts | history/state coupling |
| `ControlCenter` (if touched later) | Panel width via Theme.panelWidth | mixed Theme/Colors | pages/state, services |
| `OsdOverlay` | Positioning via Theme.osdX/osd | minimal hardcoded | OsdState timing (1400ms) — logic stays |
| `LockOverlay` | Visual only | widths/heights/radii/fonts | LockState/PAM (never modify) |

## 4) Quick wins (biggest visual impact, least effort)
1. Extend `Theme.qml`: add `cardW.notifications` (340), `overlay.panelWidth`/common widths, `radius.xl2` (18), `font.size` mapping for 10/11/12/13/14/15/22/28/34/36/42, `motion.duration` (90/120/140/160/180/240/280), `timing.hideMs` (1400), `timing.screenshotDelayMs` (280), `timing.pollMs` (2000), `osd.volStep/briStep`, `bar.sizes` (44/38/item36/icon18/pill26). (Foundation)
2. Migrate `Notifications.qml` to use Theme tokens (cardW, radii, spacing, fonts, durations). High impact, contained.
3. Migrate `LauncherOverlay.qml` to Theme (cell/tile/radii/fonts/durations).
4. Migrate `Bar.qml` and `Workspaces.qml` + `Clock.qml` to Theme (bar metrics, pill sizes, fonts).
5. Migrate `DesktopWidgets.qml` to Theme (scale/cardW/radii/fonts/durations).
6. Migrate `WallpaperOverlay.qml` and `GifOverlay.qml` carousel values to Theme (durations/tilt/sizes).
7. Components: standardize to Theme only (Capsule/Card/Slider/IconButton/etc.) — enables others.
8. Resolve `modules/Capsule.qml` (empty) vs `Components/Capsule.qml`: merge to single implementation, update modules using Capsule.
9. Tweak `Colors.qml` bridge: remove hardcoded `fontFamily` or source from Theme.
10. Centralize overlay panel widths (use `Theme.panelWidth` consistently) across ControlCenter/NotifSidebar/overlays.

## 5) Edit log (empty)
| Date | File | Change | Why | Reverted? |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |

Summary: Map verified (fixed WallpaperOverlay/GifOverlay/ClipboardOverlay/EmojiOverlay/DesktopWidgets, Components/modules, external deps). Roadmap created with full inventory, phases, per-file notes, quick wins, edit log. All as READ-ONLY except creating these two .md files. Awaiting instruction on which phase/file to start.