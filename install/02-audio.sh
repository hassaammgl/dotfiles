# shellcheck shell=bash

# JACK / PulseAudio fight PipeWire. Drop the old stack first so
# pipewire-jack and pipewire-pulse can install cleanly.
log "Resolving audio stack (PipeWire replaces JACK + Pulse)..."
remove_conflicting \
  jack2 jack lib32-jack2 jack2-dbus \
  pulseaudio pulseaudio-bluetooth pulseaudio-alsa pulseaudio-jack pulseaudio-equalizer
