#!/usr/bin/env bash
set -euo pipefail

# Inputs
OUT_DIR="/workspace/out"
MEDIA_DIR="/workspace/media"
TITLE_IMG="$MEDIA_DIR/Haven Basketball.jpg"
OUT_VIDEO="$OUT_DIR/haven_stokes_highlight_30s.mp4"

mkdir -p "$OUT_DIR"

# Build a 30s timeline using still + text overlays and motion
# 0-3s: Title card (zoom-in)
ffmpeg -y -loop 1 -t 3 -i "$TITLE_IMG" \
  -filter_complex "
    scale=1920:1080,zoompan=z='min(1.15,zoom+0.0015)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=90:s=1920x1080,format=yuv420p,
    drawtext=font='DejaVuSans-Bold':text='HAVEN STOKES':fontcolor=white:fontsize=96:x=(w-text_w)/2:y=h/2-120:shadowx=3:shadowy=3:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='Greensboro, NC  |  Shooting Guard':fontcolor=0xff496a:fontsize=46:x=(w-text_w)/2:y=h/2-20:shadowx=2:shadowy=2:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='5\'10\"  •  170 lb':fontcolor=0xff496a:fontsize=40:x=(w-text_w)/2:y=h/2+40:shadowx=2:shadowy=2:shadowcolor=0x000000AA
  " \
  -c:v libx264 -pix_fmt yuv420p -r 30 -preset veryfast -crf 18 /tmp/seg0.mp4

# 3-12s: Handles + slash motif (animated text bars)
ffmpeg -y -loop 1 -t 9 -i "$TITLE_IMG" \
  -filter_complex "
    scale=1920:1080,format=yuv420p,
    drawbox=x=0:y=720:w=1920:h=360:color=black@0.35:t=fill,
    drawtext=font='DejaVuSans-Bold':text='ELITE HANDLES':fontcolor=white:fontsize=80:x='(w-text_w)/2':y=760:shadowx=3:shadowy=3:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='Hesitations  •  Behind-the-back  •  Change of pace':fontcolor=white:fontsize=40:x='(w-text_w)/2':y=860:shadowx=2:shadowy=2:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='Slashes to the basket with control':fontcolor=0xffd166:fontsize=44:x='(w-text_w)/2':y=915:shadowx=2:shadowy=2:shadowcolor=0x000000AA
  " \
  -c:v libx264 -pix_fmt yuv420p -r 30 -preset veryfast -crf 19 /tmp/seg1.mp4

# 12-20s: Finesse finger roll focus
ffmpeg -y -loop 1 -t 8 -i "$TITLE_IMG" \
  -filter_complex "
    scale=1920:1080,format=yuv420p,
    drawbox=x=0:y=720:w=1920:h=360:color=black@0.35:t=fill,
    drawtext=font='DejaVuSans-Bold':text='FINESSE FINISHER':fontcolor=white:fontsize=80:x='(w-text_w)/2':y=760:shadowx=3:shadowy=3:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='Signature finger roll touch at the rim':fontcolor=0x9be564:fontsize=48:x='(w-text_w)/2':y=850:shadowx=2:shadowy=2:shadowcolor=0x000000AA
  " \
  -c:v libx264 -pix_fmt yuv420p -r 30 -preset veryfast -crf 19 /tmp/seg2.mp4

# 20-27s: Shooter tag
ffmpeg -y -loop 1 -t 7 -i "$TITLE_IMG" \
  -filter_complex "
    scale=1920:1080,format=yuv420p,
    drawbox=x=0:y=720:w=1920:h=360:color=black@0.35:t=fill,
    drawtext=font='DejaVuSans-Bold':text='SHOOTING GUARD':fontcolor=white:fontsize=80:x='(w-text_w)/2':y=760:shadowx=3:shadowy=3:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='Catch-and-shoot  •  Pull-ups  •  Spot-ups':fontcolor=0x33d1ff:fontsize=44:x='(w-text_w)/2':y=850:shadowx=2:shadowy=2:shadowcolor=0x000000AA
  " \
  -c:v libx264 -pix_fmt yuv420p -r 30 -preset veryfast -crf 19 /tmp/seg3.mp4

# 27-30s: Outro card
ffmpeg -y -loop 1 -t 3 -i "$TITLE_IMG" \
  -filter_complex "
    scale=1920:1080,format=yuv420p,
    drawtext=font='DejaVuSans-Bold':text='HAVEN STOKES':fontcolor=white:fontsize=88:x=(w-text_w)/2:y=h/2-60:shadowx=3:shadowy=3:shadowcolor=0x000000AA,
    drawtext=font='DejaVuSans':text='Greensboro, NC — SG — 5\'10\" 170 lb':fontcolor=0xff496a:fontsize=44:x=(w-text_w)/2:y=h/2+20:shadowx=2:shadowy=2:shadowcolor=0x000000AA
  " \
  -c:v libx264 -pix_fmt yuv420p -r 30 -preset veryfast -crf 18 /tmp/seg4.mp4

# Concatenate with 0.2s crossfades between each segment
ffmpeg -y -i /tmp/seg0.mp4 -i /tmp/seg1.mp4 -i /tmp/seg2.mp4 -i /tmp/seg3.mp4 -i /tmp/seg4.mp4 \
  -filter_complex "
    [0:v][1:v]xfade=transition=fade:duration=0.2:offset=2.8[v01];
    [v01][2:v]xfade=transition=fade:duration=0.2:offset=11.6[v02];
    [v02][3:v]xfade=transition=fade:duration=0.2:offset=19.4[v03];
    [v03][4:v]xfade=transition=fade:duration=0.2:offset=26.2[vout]
  " -map "[vout]" -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 "$OUT_VIDEO"

echo "Rendered: $OUT_VIDEO"

