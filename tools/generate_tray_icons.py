#!/usr/bin/env python3
"""
Generate macOS-standard menu bar (tray) icons for Recogniz.ing.

Follows macOS Human Interface Guidelines:
- Template images: black + alpha only, macOS auto-tints for light/dark mode
- Canvas: 22x22 @1x, 44x44 @2x (Retina)
- Content area: ~18x18pt centered within canvas
- Stroke weight: ~1.5-2pt (matching system icons like Wi-Fi, Bluetooth)
- Recording variant: colored (non-template) with red accent

Icon design: Stylized microphone — universally recognized for voice/audio apps.
"""

from PIL import Image, ImageDraw
import math
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, '..', 'assets', 'icons', 'tray')


def draw_microphone(draw, size, color=(0, 0, 0, 255), stroke_width=None):
    """Draw a clean microphone icon matching macOS system icon style.

    Design: Capsule mic head + curved holder arc + small stand base.
    Optimized for 36x36 and 44x44 pixel grids.
    """
    w = size
    h = size

    # Scale stroke to size (2px at 44, 1.5px at 36, 1px at 22)
    sw = stroke_width or max(1, round(size / 22))

    cx = w / 2  # center x

    # === Mic head (capsule/rounded rectangle) ===
    # Proportions tuned for 18pt visual weight
    head_w = round(w * 0.30)   # ~13px at 44
    head_h = round(h * 0.43)   # ~19px at 44
    head_r = head_w / 2        # fully rounded top/bottom

    head_left = cx - head_w / 2
    head_right = cx + head_w / 2
    head_top = round(h * 0.09)  # ~4px from top at 44
    head_bottom = head_top + head_h

    # Draw capsule (rounded rect with radius = half width)
    draw.rounded_rectangle(
        [head_left, head_top, head_right, head_bottom],
        radius=head_r,
        outline=color,
        width=sw,
    )

    # === Holder arc (U-shape below the mic head) ===
    arc_gap = round(w * 0.045)  # small gap between head bottom and arc top
    arc_top = head_bottom + arc_gap
    arc_w = round(w * 0.48)     # wider than mic head
    arc_h = round(h * 0.22)     # height of the arc

    arc_left = cx - arc_w / 2
    arc_right = cx + arc_w / 2
    arc_bottom = arc_top + arc_h

    # Draw the U-shaped arc (bottom half of ellipse)
    draw.arc(
        [arc_left, arc_top - arc_h, arc_right, arc_bottom],
        start=0, end=180,
        fill=color,
        width=sw,
    )

    # === Stand (vertical line from arc bottom to base) ===
    stand_top = arc_bottom - 1
    stand_bottom = round(h * 0.86)  # near bottom of canvas

    draw.line(
        [(cx, stand_top), (cx, stand_bottom)],
        fill=color,
        width=sw,
    )

    # === Base (small horizontal line) ===
    base_w = round(w * 0.22)
    base_y = stand_bottom

    draw.line(
        [(cx - base_w / 2, base_y), (cx + base_w / 2, base_y)],
        fill=color,
        width=sw,
    )


def draw_recording_dot(draw, size, dot_color=(239, 68, 68, 255)):
    """Draw a small filled recording indicator dot at top-right."""
    dot_r = max(3, round(size * 0.11))
    # Position at top-right of the canvas
    dot_cx = size - dot_r - round(size * 0.07)
    dot_cy = dot_r + round(size * 0.07)

    draw.ellipse(
        [dot_cx - dot_r, dot_cy - dot_r, dot_cx + dot_r, dot_cy + dot_r],
        fill=dot_color,
    )


def generate_template_icon(size, filename):
    """Generate a monochrome template icon (black on transparent).

    macOS will use only the alpha channel, ignoring RGB values.
    Setting NSImage.isTemplate = true enables automatic tinting.
    """
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_microphone(draw, size, color=(0, 0, 0, 255))

    path = os.path.join(OUTPUT_DIR, filename)
    img.save(path, 'PNG')
    print(f"  Generated: {path} ({size}x{size})")
    return img


def generate_recording_icon(size, filename):
    """Generate a recording state icon with red accent (non-template).

    This icon uses color, so it must NOT be set as template.
    Uses a slightly lighter mic color to work in both light/dark modes.
    """
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw mic in a neutral color that works on both light and dark bars
    # Using a medium gray that's visible on both
    draw_microphone(draw, size, color=(100, 100, 100, 255))

    # Red recording dot
    draw_recording_dot(draw, size, dot_color=(239, 68, 68, 255))

    path = os.path.join(OUTPUT_DIR, filename)
    img.save(path, 'PNG')
    print(f"  Generated: {path} ({size}x{size})")
    return img


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("Generating macOS menu bar icons...")
    print()

    # Template icons (normal state) — black + alpha only
    # macOS auto-tints these for light/dark mode
    print("Template icons (normal state):")
    generate_template_icon(22, 'tray_icon_22.png')
    generate_template_icon(44, 'tray_icon_44.png')

    # Recording state icons — colored, non-template
    print("\nRecording icons (colored state):")
    generate_recording_icon(22, 'tray_icon_recording_22.png')
    generate_recording_icon(44, 'tray_icon_recording_44.png')

    print("\nAll tray icons generated successfully!")
    print("\nDesign specs:")
    print("  - Normal: Template image (isTemplate=true), auto light/dark")
    print("  - Recording: Colored image (isTemplate=false), red dot indicator")
    print("  - Canvas: 22x22 @1x, 44x44 @2x")
    print("  - Content: ~18pt microphone glyph, centered")


if __name__ == '__main__':
    main()
