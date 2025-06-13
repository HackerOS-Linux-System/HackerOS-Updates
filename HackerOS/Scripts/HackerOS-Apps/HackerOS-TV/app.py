from flask import Flask, render_template, request, jsonify
import webbrowser
import os
import json

app = Flask(__name__)

# Domyślne przyciski i ich linki oraz ikony
buttons = [
    {"name": "Disney", "url": "https://www.disneyplus.com", "icon": "disney.png"},
    {"name": "Eleven Sports", "url": "https://www.elevensports.com", "icon": "eleven.png"},
    {"name": "HBO", "url": "https://www.hbomax.com", "icon": "hbo.png"},
    {"name": "Prime Video", "url": "https://www.amazon.com/Prime-Video", "icon": "prime.png"},
    {"name": "YouTube", "url": "https://www.youtube.com", "icon": "youtube.png"},
    {"name": "Spotify", "url": "https://www.spotify.com", "icon": "spotify.png"}
]

# Ustawienia domyślne
settings = {
    "theme": "dark",
    "volume": 50,
    "brightness": 50,
    "fullscreen": False
}

# Ścieżki do plików
BUTTONS_FILE = "buttons.json"
SETTINGS_FILE = "settings.json"

# Zapisz przyciski do pliku
def save_buttons():
    with open(BUTTONS_FILE, "w") as f:
        json.dump(buttons, f)

# Wczytaj przyciski z pliku
def load_buttons():
    global buttons
    if os.path.exists(BUTTONS_FILE):
        with open(BUTTONS_FILE, "r") as f:
            buttons = json.load(f)

# Zapisz ustawienia do pliku
def save_settings():
    with open(SETTINGS_FILE, "w") as f:
        json.dump(settings, f)

# Wczytaj ustawienia z pliku
def load_settings():
    global settings
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, "r") as f:
            settings.update(json.load(f))

@app.route("/")
def index():
    load_buttons()
    load_settings()
    return render_template("index.html", buttons=buttons, settings=settings)

@app.route("/open/<name>")
def open_url(name):
    for button in buttons:
        if button["name"] == name:
            webbrowser.register("brave", None, webbrowser.GenericBrowser("brave"))
            webbrowser.get("brave").open_new_tab(button["url"])
            return jsonify({"status": "success"})
    return jsonify({"status": "error", "message": "Button not found"})

@app.route("/add_button", methods=["POST"])
def add_button():
    data = request.json
    name = data.get("name")
    url = data.get("url")
    icon = data.get("icon", "default.png")  # Domyślna ikona, jeśli nie podano
    if name and url:
        buttons.append({"name": name, "url": url, "icon": icon})
        save_buttons()
        return jsonify({"status": "success"})
    return jsonify({"status": "error", "message": "Invalid data"})

@app.route("/remove_button/<name>", methods=["POST"])
def remove_button(name):
    global buttons
    buttons = [b for b in buttons if b["name"] != name]
    save_buttons()
    return jsonify({"status": "success"})

@app.route("/set_volume/<int:value>", methods=["POST"])
def set_volume(value):
    settings["volume"] = value
    save_settings()
    os.system(f"pactl set-sink-volume @DEFAULT_SINK@ {value}%")
    return jsonify({"status": "success"})

@app.route("/set_brightness/<int:value>", methods=["POST"])
def set_brightness(value):
    settings["brightness"] = value
    save_settings()
    os.system(f"brightnessctl set {value}%")
    return jsonify({"status": "success"})

@app.route("/set_theme/<theme>", methods=["POST"])
def set_theme(theme):
    if theme in ["dark", "light"]:
        settings["theme"] = theme
        save_settings()
        return jsonify({"status": "success"})
    return jsonify({"status": "error", "message": "Invalid theme"})

@app.route("/set_fullscreen/<value>", methods=["POST"])
def set_fullscreen(value):
    settings["fullscreen"] = value.lower() == "true"
    save_settings()
    return jsonify({"status": "success"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3939, debug=True)
