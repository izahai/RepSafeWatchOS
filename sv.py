import socket
import tkinter as tk
import threading

# ===== CONFIG =====
BROADCAST_PORT = 8888
TCP_PORT = 9999
PASSWORD1 = "HELLO123"
PASSWORD2 = "SECRET456"

ANDROID_IP = None

# ===== DISCOVERY =====
def discover_device():
    global ANDROID_IP

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(5)

    # Enable broadcast
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

    message = f"DISCOVER:{PASSWORD1}".encode()

    try:
        s.sendto(message, ('255.255.255.255', BROADCAST_PORT))
        print("📡 Broadcasting...")

        data, addr = s.recvfrom(1024)
        response = data.decode()

        print("📥 Received:", response, "from", addr)

        if response == f"OK:{PASSWORD2}":
            ANDROID_IP = addr[0]
            print("✅ Connected to:", ANDROID_IP)
        else:
            print("❌ Invalid handshake")

    except Exception as e:
        print("❌ Discovery failed:", e)

    finally:
        s.close()


# ===== TCP COMMAND =====
def send_command(cmd):
    if not ANDROID_IP:
        print("⚠️ Not connected")
        return

    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(3)
        s.connect((ANDROID_IP, TCP_PORT))
        s.sendall(cmd.encode())
        s.close()

        print(f"➡️ Sent: {cmd}")

    except Exception as e:
        print("❌ Send error:", e)


def send_command_thread(cmd):
    threading.Thread(target=send_command, args=(cmd,), daemon=True).start()


def connect_thread():
    threading.Thread(target=discover_device, daemon=True).start()


# ===== UI =====
root = tk.Tk()
root.title("Laptop Controller")

tk.Button(root, text="Device Discovery", command=connect_thread, width=20, height=2).pack(pady=5)

tk.Button(root, text="Count", command=lambda: send_command_thread("ON"), width=20, height=5).pack(pady=5)
tk.Button(root, text="Alert", command=lambda: send_command_thread("OFF"), width=20, height=5).pack(pady=5)

root.mainloop()