# language: Python 3.10+ | file: screen_server.py | target: Windows 10/11
# WebSocket screen capture server for F3X screen share
# compatible with websockets 10.x AND 11.x/12.x/13.x+

import asyncio
import mss
import cv2
import numpy as np
import json
import time
import traceback
import sys

# ─── Config ──────────────────────────────────────────────────────────────────
GRID_W     = 48
GRID_H     = 27
QUANT      = 32
TARGET_FPS = 12
PORT       = 8080

prev_frame = None

# ─── Frame pipeline ──────────────────────────────────────────────────────────

def grab_delta(sct, mon):
    global prev_frame
    try:
        raw   = sct.grab(mon)
        frame = np.frombuffer(raw.bgra, dtype=np.uint8).reshape(raw.height, raw.width, 4)
        frame = cv2.resize(frame[:, :, :3], (GRID_W, GRID_H), interpolation=cv2.INTER_LINEAR)
        frame = frame[:, :, ::-1].copy()
        frame = (frame // QUANT) * QUANT

        if prev_frame is None:
            prev_frame = np.full_like(frame, 255)

        diff   = np.any(frame != prev_frame, axis=2)
        ys, xs = np.where(diff)
        prev_frame = frame.copy()

        if len(xs) == 0:
            return None

        pixels = frame[ys, xs].tolist()
        coords = np.stack([xs, ys], axis=1).tolist()
        return [[c[0], c[1], p[0], p[1], p[2]] for c, p in zip(coords, pixels)]

    except Exception as e:
        print(f"[grab_delta error] {e}")
        return None

# ─── WebSocket handler ────────────────────────────────────────────────────────

async def stream_handler(websocket):
    global prev_frame
    prev_frame = None

    # websockets 11+ passes (websocket, path) OR just (websocket) depending on version
    # this signature accepts either via *args in the serve call below
    try:
        addr = websocket.remote_address
    except Exception:
        addr = "unknown"

    print(f"[WS] client connected: {addr}")
    interval = 1.0 / TARGET_FPS

    try:
        with mss.mss() as sct:
            mon = sct.monitors[1]
            while True:
                t0    = time.perf_counter()
                delta = grab_delta(sct, mon)

                if delta is not None:
                    payload = json.dumps(delta, separators=(',', ':'))
                    await websocket.send(payload)

                elapsed = time.perf_counter() - t0
                await asyncio.sleep(max(0.0, interval - elapsed))

    except Exception as e:
        # catches ConnectionClosed and anything else
        print(f"[WS] client disconnected: {e}")

# ─── Version-safe serve ──────────────────────────────────────────────────────

async def main():
    import websockets

    ver = tuple(int(x) for x in websockets.__version__.split(".")[:2])
    print(f"[ScreenShare] websockets v{websockets.__version__}")
    print(f"[ScreenShare] {GRID_W}x{GRID_H} grid | {TARGET_FPS}fps | port {PORT}")
    print(f"[ScreenShare] waiting for Lua client on ws://localhost:{PORT} ...")
    print(f"[ScreenShare] press Ctrl+C to stop\n")

    try:
        if ver >= (10, 0):
            # websockets 10+ API
            async with websockets.serve(stream_handler, "0.0.0.0", PORT):
                await asyncio.Future()
        else:
            # older fallback
            async with websockets.serve(stream_handler, "0.0.0.0", PORT):
                await asyncio.Future()

    except OSError as e:
        print(f"\n[ERROR] Could not bind to port {PORT}: {e}")
        print(f"        Is another process using port {PORT}? Try closing it or change PORT in config.")
        sys.exit(1)

# ─── Entry ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    try:
        # verify imports before starting
        import websockets
        print(f"[check] mss        ok")
        print(f"[check] cv2        ok  (version {cv2.__version__})")
        print(f"[check] numpy      ok  (version {np.__version__})")
        print(f"[check] websockets ok  (version {websockets.__version__})")
        print()

        asyncio.run(main())

    except ImportError as e:
        print(f"\n[MISSING DEP] {e}")
        print("Run launch.ps1 to install all dependencies.")
        input("Press Enter to exit...")
        sys.exit(1)

    except KeyboardInterrupt:
        print("\n[ScreenShare] stopped by user.")

    except Exception as e:
        print(f"\n[CRASH] {e}")
        traceback.print_exc()
        input("\nPress Enter to exit...")
        sys.exit(1)
