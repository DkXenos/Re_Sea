#!/usr/bin/env python3
"""Generates every placeholder sound in assets/audio/ as a raw 16-bit mono WAV
using only the stdlib `wave` module. Short blips and clicks, plain sine or
square with a quick fade. No AI audio generation is used in this project.

    python3 tools/gen_sounds.py
"""
import math
import os
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "audio")

# name -> (segments, wave shape)
# segment = (frequency Hz, duration s, peak amplitude 0..1)
SOUNDS = {
    "claw_move":      ([(220, 0.05, 0.18)], "square"),
    "claw_drop":      ([(400, 0.06, 0.30), (180, 0.16, 0.26)], "sine"),
    "grab_success":   ([(523, 0.07, 0.32), (784, 0.12, 0.30)], "sine"),
    "grab_fail":      ([(320, 0.09, 0.28), (170, 0.18, 0.26)], "square"),
    "tool_use":       ([(660, 0.05, 0.24), (880, 0.06, 0.22)], "sine"),
    "reveal_success": ([(660, 0.06, 0.30), (880, 0.06, 0.30), (1175, 0.14, 0.28)], "sine"),
    "reveal_nothing": ([(300, 0.10, 0.24), (240, 0.14, 0.20)], "sine"),
    "bin_accept":     ([(587, 0.07, 0.30), (880, 0.13, 0.28)], "sine"),
    "bin_reject":     ([(196, 0.16, 0.30), (147, 0.18, 0.26)], "square"),
    "day_end":        ([(392, 0.14, 0.28), (523, 0.14, 0.28), (659, 0.26, 0.26)], "sine"),
    "ui_click":       ([(880, 0.035, 0.22)], "square"),
}


def render(segments, shape):
    samples = []
    for freq, dur, amp in segments:
        n = int(RATE * dur)
        for i in range(n):
            t = i / RATE
            phase = 2.0 * math.pi * freq * t
            v = math.sin(phase) if shape == "sine" else (1.0 if math.sin(phase) >= 0 else -1.0)
            # quick attack, linear fade to zero so segments never click
            env = min(1.0, i / max(1.0, RATE * 0.004)) * (1.0 - i / n)
            samples.append(int(max(-1.0, min(1.0, v * amp * env)) * 32000))
    return samples


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, (segments, shape) in SOUNDS.items():
        data = render(segments, shape)
        with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(struct.pack("<%dh" % len(data), *data))
    print("generated %d WAVs in assets/audio/" % len(SOUNDS))


if __name__ == "__main__":
    main()
