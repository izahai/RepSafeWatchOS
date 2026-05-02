import threading
import tkinter as tk
from flask import Flask
import requests

# =========================
# SERVER STATE
# =========================
state = "OFF" # ON, ALERT, START, COUNT, QUESTION, DESC

app = Flask(__name__)

@app.route("/status")
def status():
    global state
    current = state

    # AUTO-RESET after sending COUNT
    if state == "COUNT" or state == "DESC":
        state = "ON" 

    return current

@app.route("/on")
def turn_on():
    global state
    state = "ON"
    print("💪 STATE = ON")
    return "OK"

@app.route("/off")
def turn_off():
    global state
    state = "OFF"
    print("⚠️ STATE = OFF")
    return "OK"

@app.route("/alert")
def set_alert():
    global state
    state = "ALERT"
    print("🚨 STATE = ALERT")
    return "OK"

@app.route("/start")
def set_start():
    global state
    state = "START"
    print("🚀 STATE = START")
    return "OK"

@app.route("/count")
def set_count():
    global state
    state = "COUNT"
    print("🔢 STATE = COUNT")
    return "OK"

@app.route("/question")
def set_question():
    global state
    state = "QUESTION"
    print("❓ STATE = QUESTION")
    return "OK"

@app.route("/desc")
def set_desc():
    global state
    state = "DESC"
    print("📝 STATE = DESC")
    return "OK"

# =========================
# START FLASK SERVER
# =========================
def run_server():
    app.run(host="0.0.0.0", port=8000)


# =========================
# TKINTER UI
# =========================
def send_on():
    try:
        requests.get("http://127.0.0.1:8000/on")
    except:
        print("❌ Server not reachable")

def send_off():
    try:
        requests.get("http://127.0.0.1:8000/off")
    except:
        print("❌ Server not reachable")

def send_alert():
    try:
        requests.get("http://127.0.0.1:8000/alert")
    except:
        print("❌ Server not reachable")

def send_start():
    try:
        requests.get("http://127.0.0.1:8000/start")
    except:
        print("❌ Server not reachable")

def send_count():
    try:
        requests.get("http://127.0.0.1:8000/count")
    except:
        print("❌ Server not reachable")

def send_question():
    try:
        requests.get("http://127.0.0.1:8000/question")
    except:
        print("❌ Server not reachable")
        
def send_desc():
    try:
        requests.get("http://127.0.0.1:8000/desc")
    except:
        print("❌ Server not reachable")


def start_ui():
    root = tk.Tk()
    root.title("Laptop Controller")

    # Adjusted button dimensions slightly to fit all buttons well
    tk.Button(root, text="TURN ON", command=send_on, width=20, height=2).pack(pady=5)
    tk.Button(root, text="TURN OFF", command=send_off, width=20, height=2).pack(pady=5)
    
    # New endpoints buttons
    tk.Button(root, text="SET ALERT", command=send_alert, width=20, height=2).pack(pady=5)
    tk.Button(root, text="SET START", command=send_start, width=20, height=2).pack(pady=5)
    tk.Button(root, text="SET COUNT", command=send_count, width=20, height=2).pack(pady=5)
    tk.Button(root, text="SET QUESTION", command=send_question, width=20, height=2).pack(pady=5)
    tk.Button(root, text="SET DESC", command=send_desc, width=20, height=2).pack(pady=5)

    root.mainloop()


# =========================
# MAIN
# =========================
if __name__ == "__main__":
    # Run Flask in background thread
    threading.Thread(target=run_server, daemon=True).start()

    print("🟢 Server running at:")
    print("👉 http://YOUR_IP:8000/status")

    # Start UI (blocking)
    start_ui()