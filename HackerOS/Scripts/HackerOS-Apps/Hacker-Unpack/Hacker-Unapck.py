import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import os
import threading
import uuid
import logging
from datetime import datetime

class HackerUnpackApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Hacker Unpack")
        self.root.geometry("1600x1000")
        self.root.configure(bg="#151515")

        # Setup logging
        self.log_file = f"hacker_unpack_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        logging.basicConfig(filename=self.log_file, level=logging.INFO,
                           format='%(asctime)s - %(levelname)s - %(message)s')

        # Style configuration for modern aesthetic
        self.style = ttk.Style()
        self.style.theme_use("clam")
        self.style.configure("TButton", background="#252525", foreground="#ffffff", padding=4,
                            font=("Roboto", 7), borderwidth=0, relief="flat")
        self.style.map("TButton", background=[("active", "#353535")], foreground=[("active", "#ffffff")])
        self.style.configure("Remove.TButton", background="#454545", foreground="#ffffff", padding=2,
                            font=("Roboto", 6), borderwidth=0, relief="flat")
        self.style.map("Remove.TButton", background=[("active", "#555555")])
        self.style.configure("TCheckbutton", background="#151515", foreground="#ffffff",
                            font=("Roboto", 7), selectcolor="#252525")
        self.style.configure("TLabel", background="#151515", foreground="#ffffff",
                            font=("Roboto", 8))
        self.style.configure("TNotebook", background="#252525")
        self.style.configure("TNotebook.Tab", background="#252525", foreground="#ffffff",
                            padding=[6, 2], font=("Roboto", 7))
        self.style.map("TNotebook.Tab", background=[("selected", "#353535")],
                      foreground=[("selected", "#ffffff")])
        self.style.configure("TProgressbar", background="#aaaaaa", troughcolor="#252525",
                            borderwidth=0)
        self.style.configure("TEntry", fieldbackground="#252525", foreground="#ffffff",
                            insertcolor="#ffffff", font=("Roboto", 7))
        self.style.configure("TScrolledText", fieldbackground="#252525", foreground="#ffffff",
                            font=("Roboto", 7))
        self.style.configure("TFrame", background="#151515")
        self.style.configure("Hover.TFrame", background="#1d1d1d")

        # Expanded application categories and packages
        self.categories = {
            "Gaming": {
                "steam": ("apt", "steam", "Gaming platform and store"),
                "heroic": ("flatpak", "com.heroicgameslauncher.hgl", "Epic Games launcher"),
                "hyperplay": ("flatpak", "io.hyperplay.HyperPlay", "Web3 gaming platform"),
                "lutris": ("apt", "lutris", "Game management platform"),
                "wine": ("apt", "wine", "Windows compatibility layer"),
                "playonlinux": ("apt", "playonlinux", "Windows games runner"),
                "retroarch": ("apt", "retroarch", "Retro game emulator"),
                "minetest": ("apt", "minetest", "Open-source Minecraft alternative"),
                "supertuxkart": ("apt", "supertuxkart", "Racing game"),
                "0ad": ("apt", "0ad", "Historical RTS game"),
                "openarena": ("apt", "openarena", "FPS game"),
                "warzone2100": ("apt", "warzone2100", "Strategy game"),
                "hedgewars": ("apt", "hedgewars", "Turn-based strategy"),
                "teeworlds": ("apt", "teeworlds", "Multiplayer platformer"),
                "xonotic": ("apt", "xonotic", "Fast-paced FPS"),
                "openrct2": ("apt", "openrct2", "RollerCoaster Tycoon 2 remake"),
                "armagetronad": ("apt", "armagetronad", "Tron-like multiplayer game"),
                "frozen-bubble": ("apt", "frozen-bubble", "Puzzle game"),
                "spring": ("apt", "spring", "RTS game engine"),
                "megaglest": ("apt", "megaglest", "Open-source strategy game"),
                "tremulous": ("apt", "tremulous", "FPS and RTS hybrid"),
                "wesnoth": ("apt", "wesnoth", "Turn-based strategy"),
                "freeciv": ("apt", "freeciv", "Civilization-like strategy"),
                "openttd": ("apt", "openttd", "Transport simulation"),
                "pingus": ("apt", "pingus", "Lemmings-like puzzle game"),
                "sauerbraten": ("apt", "sauerbraten", "FPS game"),
                "neverball": ("apt", "neverball", "3D puzzle game"),
                "lbreakout2": ("apt", "lbreakout2", "Breakout-style game"),
                "chromium-bsu": ("apt", "chromium-bsu", "Top-down shooter"),
                "assaultcube": ("apt", "assaultcube", "Fast-paced FPS"),
                "bzflag": ("apt", "bzflag", "Tank battle game"),
                "enigma": ("apt", "enigma", "Puzzle game"),
                "gltron": ("apt", "gltron", "Tron-inspired racing"),
            },
            "Biurowe": {
                "libreoffice": ("apt", "libreoffice", "Open-source office suite"),
                "onlyoffice": ("snap", "onlyoffice-desktopeditors", "Modern office suite"),
                "okular": ("apt", "okular", "PDF and document viewer"),
                "calibre": ("apt", "calibre", "E-book management"),
                "scribus": ("apt", "scribus", "Desktop publishing"),
                "foxit": ("snap", "foxit-reader", "PDF reader"),
                "xournalpp": ("apt", "xournalpp", "Note-taking and PDF annotation"),
                "zotero": ("snap", "zotero-snap", "Reference management"),
                "evince": ("apt", "evince", "Document viewer"),
                "abiword": ("apt", "abiword", "Lightweight word processor"),
                "gnumeric": ("apt", "gnumeric", "Spreadsheet editor"),
                "pdfarranger": ("apt", "pdfarranger", "PDF merging and splitting"),
                "qownnotes": ("apt", "qownnotes", "Note-taking with markdown"),
                "masterpdfeditor": ("snap", "master-pdf-editor", "PDF editor"),
                "atril": ("apt", "atril", "Document viewer for MATE"),
                "naps2": ("snap", "naps2", "Document scanning"),
                "gramps": ("apt", "gramps", "Genealogy software"),
                "homebank": ("apt", "homebank", "Personal finance management"),
                "planner": ("apt", "planner", "Project management"),
                "pdfsam": ("snap", "pdfsam-basic", "PDF split and merge"),
                "focuswriter": ("apt", "focuswriter", "Distraction-free writing"),
                "rednotebook": ("apt", "rednotebook", "Journal and note-taking"),
                "tomboy": ("apt", "tomboy", "Note-taking with syncing"),
                "calligra": ("apt", "calligra", "Office and graphics suite"),
                "freeplane": ("apt", "freeplane", "Mind mapping"),
                "vym": ("apt", "vym", "Mind mapping tool"),
            },
            "Narzędzia programistyczne": {
                "vscode": ("snap", "code", "Visual Studio Code IDE"),
                "pycharm": ("snap", "pycharm-community", "Python IDE"),
                "git": ("apt", "git", "Version control system"),
                "docker": ("apt", "docker.io", "Container platform"),
                "intellij": ("snap", "intellij-idea-community", "Java IDE"),
                "eclipse": ("snap", "eclipse", "Multi-language IDE"),
                "android-studio": ("snap", "android-studio", "Android development"),
                "atom": ("snap", "atom", "Hackable text editor"),
                "sublime-text": ("snap", "sublime-text", "Text editor"),
                "geany": ("apt", "geany", "Lightweight IDE"),
                "netbeans": ("snap", "netbeans", "Java IDE"),
                "codeblocks": ("apt", "codeblocks", "C/C++ IDE"),
                "bluefish": ("apt", "bluefish", "Web development editor"),
                "postman": ("snap", "postman", "API testing tool"),
                "dbeaver": ("snap", "dbeaver-ce", "Database management"),
                "gitkraken": ("snap", "gitkraken", "Git client"),
                "insomnia": ("snap", "insomnia", "API testing tool"),
                "clion": ("snap", "clion", "C/C++ IDE"),
                "godot": ("snap", "godot", "Game development engine"),
                "flutter": ("snap", "flutter", "UI toolkit for cross-platform apps"),
                "vscodium": ("snap", "vscodium", "Open-source VS Code alternative"),
                "arduino": ("snap", "arduino", "Arduino IDE for hardware"),
                "platformio": ("snap", "platformio-ide", "IoT development"),
                "mono": ("apt", "mono-devel", "C# development"),
                "qtcreator": ("apt", "qtcreator", "Qt application development"),
                "kdevelop": ("apt", "kdevelop", "C++ IDE"),
                "ninja-build": ("apt", "ninja-build", "Build system"),
                "cmake": ("apt", "cmake", "Build system generator"),
                "vala": ("apt", "valac", "Vala programming language"),
                "golang": ("snap", "go", "Go programming language"),
                "rust": ("snap", "rustup", "Rust programming language"),
                "nodejs": ("snap", "node", "JavaScript runtime"),
                "deno": ("snap", "deno", "Secure JavaScript runtime"),
                "bun": ("snap", "bun", "Fast JavaScript runtime"),
                "gradle": ("snap", "gradle", "Build automation tool"),
                "maven": ("apt", "maven", "Java project management"),
            },
            "Emulatory i wirtualizacja": {
                "virtualbox": ("apt", "virtualbox", "Virtual machine software"),
                "qemu": ("apt", "qemu", "Generic emulator"),
                "dosbox": ("apt", "dosbox", "DOS emulator"),
                "vmware-player": ("apt", "vmware-player", "VMware virtualization"),
                "pcsxr": ("apt", "pcsxr", "PlayStation emulator"),
                "boxes": ("apt", "gnome-boxes", "Simple virtual machine manager"),
                "virt-manager": ("apt", "virt-manager", "Virtual machine management"),
                "mame": ("apt", "mame", "Arcade machine emulator"),
                "fs-uae": ("apt", "fs-uae", "Amiga emulator"),
                "dolphin-emu": ("apt", "dolphin-emu", "GameCube/Wii emulator"),
                "ppsspp": ("apt", "ppsspp", "PSP emulator"),
                "rpcs3": ("flatpak", "net.rpcs3.RPCS3", "PS3 emulator"),
                "cemu": ("flatpak", "info.cemu.Cemu", "Wii U emulator"),
                "yuzu": ("flatpak", "org.yuzu_emu.yuzu", "Nintendo Switch emulator"),
                "mednafen": ("apt", "mednafen", "Multi-system emulator"),
                "scummvm": ("apt", "scummvm", "Classic adventure game emulator"),
                "zsnes": ("apt", "zsnes", "SNES emulator"),
                "vbam": ("apt", "visualboyadvance", "Game Boy Advance emulator"),
                "desmume": ("apt", "desmume", "Nintendo DS emulator"),
                "mgba": ("apt", "mgba", "Game Boy Advance emulator"),
                "snes9x": ("apt", "snes9x", "SNES emulator"),
                "citra": ("flatpak", "org.citra_emu.citra", "Nintendo 3DS emulator"),
            },
            "Sieci i symulacje": {
                "packettracer": ("apt", "packettracer", "Cisco network simulator"),
                "gns3": ("apt", "gns3", "Network simulation platform"),
                "wireshark": ("apt", "wireshark", "Network protocol analyzer"),
                "mininet": ("apt", "mininet", "Network emulator"),
                "ettercap": ("apt", "ettercap-gtk", "Network security tool"),
                "ostinato": ("apt", "ostinato", "Packet crafter"),
                "tcpdump": ("apt", "tcpdump", "Packet analyzer"),
                "mtr": ("apt", "mtr", "Network diagnostic tool"),
                "iperf3": ("apt", "iperf3", "Network bandwidth measurement"),
                "netcat": ("apt", "netcat", "Network utility"),
                "nmap-zenmap": ("apt", "zenmap", "GUI for Nmap"),
                "hping3": ("apt", "hping3", "Packet generator and analyzer"),
                "openvswitch-switch": ("apt", "openvswitch-switch", "Virtual switch"),
                "frr": ("apt", "frr", "Routing protocol suite"),
                "iproute2": ("apt", "iproute2", "Advanced network routing"),
                "iftop": ("apt", "iftop", "Network bandwidth monitor"),
                "nethogs": ("apt", "nethogs", "Per-process bandwidth monitor"),
                "bmon": ("apt", "bmon", "Bandwidth monitor"),
                "ngrep": ("apt", "ngrep", "Network packet grep"),
                "darkstat": ("apt", "darkstat", "Network traffic analyzer"),
                "vnstat": ("apt", "vnstat", "Network traffic monitor"),
                "netperf": ("apt", "netperf", "Network performance testing"),
                "iperf": ("apt", "iperf", "Network performance measurement"),
                "nload": ("apt", "nload", "Network traffic monitor"),
            },
            "Przydatne narzędzia": {
                "htop": ("apt", "htop", "System monitor"),
                "gparted": ("apt", "gparted", "Partition editor"),
                "timeshift": ("apt", "timeshift", "System backup"),
                "bleachbit": ("apt", "bleachbit", "System cleaner"),
                "stacer": ("apt", "stacer", "System optimizer"),
                "guake": ("apt", "guake", "Dropdown terminal"),
                "plasma-discover": ("apt", "plasma-discover", "Software center"),
                "synaptic": ("apt", "synaptic", "Package manager"),
                "caffeine": ("apt", "caffeine", "Screen lock inhibitor"),
                "redshift": ("apt", "redshift", "Screen color temperature adjuster"),
                "tmux": ("apt", "tmux", "Terminal multiplexer"),
                "screen": ("apt", "screen", "Terminal multiplexer"),
                "terminator": ("apt", "terminator", "Advanced terminal"),
                "alacritty": ("snap", "alacritty", "GPU-accelerated terminal"),
                "kitty": ("apt", "kitty", "Fast terminal emulator"),
                "yakuake": ("apt", "yakuake", "KDE dropdown terminal"),
                "filezilla": ("apt", "filezilla", "FTP client"),
                "tilda": ("apt", "tilda", "Lightweight dropdown terminal"),
                "balena-etcher": ("snap", "balena-etcher", "USB image writer"),
                "transmission": ("apt", "transmission-gtk", "BitTorrent client"),
                "qalculate": ("apt", "qalculate-gtk", "Advanced calculator"),
                "veracrypt": ("apt", "veracrypt", "Disk encryption"),
                "unetbootin": ("apt", "unetbootin", "Bootable USB creator"),
                "clamtk": ("apt", "clamtk", "GUI for ClamAV antivirus"),
                "grsync": ("apt", "grsync", "GUI for rsync"),
                "duf": ("apt", "duf", "Disk usage utility"),
                "exa": ("apt", "exa", "Modern ls replacement"),
                "bat": ("apt", "bat", "Cat alternative with syntax highlighting"),
                "fd-find": ("apt", "fd-find", "Find alternative"),
                "ripgrep": ("apt", "ripgrep", "Fast grep alternative"),
                "zoxide": ("snap", "zoxide", "Smart cd command"),
                "fzf": ("apt", "fzf", "Fuzzy finder"),
                "mc": ("apt", "mc", "Midnight Commander file manager"),
                "ranger": ("apt", "ranger", "Console file manager"),
                "nnn": ("apt", "nnn", "Lightweight file manager"),
            },
            "Edycja zdjęć i filmów": {
                "gimp": ("apt", "gimp", "Image editor"),
                "kdenlive": ("apt", "kdenlive", "Video editor"),
                "blender": ("snap", "blender", "3D modeling and animation"),
                "shotcut": ("snap", "shotcut", "Video editor"),
                "krita": ("snap", "krita", "Digital painting"),
                "darktable": ("apt", "darktable", "Photo workflow"),
                "openshot": ("apt", "openshot-qt", "Video editor"),
                "natron": ("snap", "natron", "Compositing software"),
                "flowblade": ("apt", "flowblade", "Non-linear video editor"),
                "lightworks": ("snap", "lightworks", "Professional video editing"),
                "olive": ("snap", "olive", "Video editor"),
                "photofiltre": ("snap", "photofiltre", "Image retouching"),
                "shotwell": ("apt", "shotwell", "Photo manager"),
                "pixelorama": ("snap", "pixelorama", "Pixel art editor"),
                "davinci-resolve": ("snap", "davinci-resolve", "Professional video editing"),
                "synfig": ("apt", "synfigstudio", "2D animation software"),
                "opencolorio": ("apt", "opencolorio-tools", "Color management"),
                "photoflare": ("apt", "photoflare", "Simple image editor"),
                "imagej": ("apt", "imagej", "Image processing"),
                "gmic-gimp": ("apt", "gimp-plugin-registry", "GIMP plugin suite"),
                "tupi": ("apt", "tupi", "2D animation software"),
                "pencil2d": ("snap", "pencil2d", "2D animation software"),
                "enve": ("snap", "enve", "2D animation and graphics"),
                "opentoonz": ("snap", "opentoonz", "Professional 2D animation"),
                "glaxnimate": ("snap", "glaxnimate", "Vector animation tool"),
                "motion": ("apt", "motion", "Motion detection and video processing"),
            },
            "Audio i wideo": {
                "vlc": ("apt", "vlc", "Media player"),
                "audacity": ("apt", "audacity", "Audio editor"),
                "obs-studio": ("apt", "obs-studio", "Streaming and recording"),
                "mpv": ("apt", "mpv", "Lightweight media player"),
                "clementine": ("apt", "clementine", "Music player"),
                "kodi": ("apt", "kodi", "Media center"),
                "ardour": ("apt", "ardour", "Digital audio workstation"),
                "stremio": ("snap", "stremio", "Media streaming platform"),
                "lollypop": ("apt", "lollypop", "Modern music player"),
                "handbrake": ("apt", "handbrake", "Video transcoder"),
                "rhythmbox": ("apt", "rhythmbox", "Music player"),
                "qmmp": ("apt", "qmmp", "Audio player"),
                "sayonara": ("apt", "sayonara", "Lightweight music player"),
                "ffmpeg": ("apt", "ffmpeg", "Multimedia framework"),
                "lmms": ("apt", "lmms", "Music production software"),
                "spotify": ("snap", "spotify", "Music streaming service"),
                "mixxx": ("apt", "mixxx", "DJ mixing software"),
                "youtube-dl": ("apt", "youtube-dl", "Video downloader"),
                "mplayer": ("apt", "mplayer", "Media player"),
                "rosegarden": ("apt", "rosegarden", "MIDI sequencer"),
                "qtractor": ("apt", "qtractor", "Audio/MIDI DAW"),
                "muse": ("apt", "muse", "MIDI sequencer"),
                "hydrogen": ("apt", "hydrogen", "Drum machine"),
                "vokoscreen": ("apt", "vokoscreen", "Screen recording"),
                "kazam": ("apt", "kazam", "Screen recording"),
                "simplescreenrecorder": ("apt", "simplescreenrecorder", "Screen recording"),
            },
            "Edukacja": {
                "anki": ("apt", "anki", "Flashcard learning"),
                "stellarium": ("apt", "stellarium", "Planetarium software"),
                "geogebra": ("snap", "geogebra-classic", "Math visualization"),
                "scratch": ("apt", "scratch", "Programming for kids"),
                "musescore": ("apt", "musescore", "Music notation"),
                "gcompris": ("apt", "gcompris", "Educational games"),
                "tuxpaint": ("apt", "tuxpaint", "Drawing for kids"),
                "klavaro": ("apt", "klavaro", "Typing tutor"),
                "tuxmath": ("apt", "tuxmath", "Math learning game"),
                "ktouch": ("apt", "ktouch", "Touch typing tutor"),
                "minuet": ("apt", "minuet", "Music education"),
                "kig": ("apt", "kig", "Interactive geometry"),
                "kalzium": ("apt", "kalzium", "Periodic table"),
                "kstars": ("apt", "kstars", "Desktop planetarium"),
                "openttd": ("apt", "openttd", "Transport simulation"),
                "celestia": ("apt", "celestia", "3D space simulator"),
                "step": ("apt", "step", "Physics simulator"),
                "kbruch": ("apt", "kbruch", "Fraction learning"),
                "kgeography": ("apt", "kgeography", "Geography learning"),
                "kwordquiz": ("apt", "kwordquiz", "Vocabulary trainer"),
                "tuxtyping": ("apt", "tux-typing", "Typing game"),
                "khangman": ("apt", "khangman", "Hangman word game"),
                "parley": ("apt", "parley", "Vocabulary trainer"),
                "blockly": ("snap", "blockly-games", "Programming games"),
                "logisim": ("apt", "logisim", "Digital logic simulator"),
                "kdeedu": ("apt", "kdeedu", "KDE educational suite"),
                "kturtle": ("apt", "kturtle", "Educational programming"),
                "phet": ("snap", "phet", "Interactive science simulations"),
            },
            "Ułatwiające życie": {
                "keepassxc": ("apt", "keepassxc", "Password manager"),
                "syncthing": ("apt", "syncthing", "File synchronization"),
                "nextcloud": ("snap", "nextcloud", "Cloud storage"),
                "joplin": ("snap", "joplin-desktop", "Note-taking"),
                "todoist": ("snap", "todoist", "Task management"),
                "bitwarden": ("snap", "bitwarden", "Password manager"),
                "trello": ("snap", "trello-desktop", "Project management"),
                "standard-notes": ("snap", "standard-notes", "Secure note-taking"),
                "cherrytree": ("apt", "cherrytree", "Hierarchical note-taking"),
                "notion": ("snap", "notion-snap", "All-in-one workspace"),
                "obsidian": ("snap", "obsidian", "Knowledge base"),
                "logseq": ("snap", "logseq", "Knowledge management"),
                "remmina": ("apt", "remmina", "Remote desktop client"),
                "anydesk": ("snap", "anydesk", "Remote desktop software"),
                "dropbox": ("snap", "dropbox", "Cloud storage and sync"),
                "megasync": ("snap", "megasync", "MEGA cloud storage"),
                "protonvpn": ("snap", "protonvpn", "VPN client"),
                "simplenote": ("snap", "simplenote", "Simple note-taking"),
                "synology-drive": ("snap", "synology-drive", "Synology NAS client"),
                "owncloud-client": ("apt", "owncloud-client", "OwnCloud client"),
                "seafile-client": ("apt", "seafile-gui", "Seafile client"),
                "taskwarrior": ("apt", "taskwarrior", "Task management CLI"),
                "calcurse": ("apt", "calcurse", "Terminal-based calendar"),
                "newsboat": ("apt", "newsboat", "RSS feed reader"),
                "tutanota": ("snap", "tutanota-desktop", "Secure email client"),
                "thunderbird": ("apt", "thunderbird", "Email client"),
                "evolution": ("apt", "evolution", "Email and calendar"),
                "geary": ("apt", "geary", "Lightweight email client"),
            },
            "Przeglądarki internetowe": {
                "firefox": ("snap", "firefox", "Web browser"),
                "chromium": ("snap", "chromium", "Web browser"),
                "tor-browser": ("flatpak", "org.torproject.torbrowser", "Anonymous browsing"),
                "brave": ("snap", "brave", "Privacy-focused browser"),
                "opera": ("snap", "opera", "Web browser"),
                "edge": ("snap", "microsoft-edge", "Microsoft Edge browser"),
                "vivaldi": ("snap", "vivaldi", "Customizable browser"),
                "qutebrowser": ("apt", "qutebrowser", "Keyboard-driven browser"),
                "falkon": ("apt", "falkon", "Lightweight browser"),
                "midori": ("apt", "midori", "Lightweight web browser"),
                "epiphany": ("apt", "epiphany-browser", "GNOME web browser"),
                "otter-browser": ("apt", "otter-browser", "Opera-like browser"),
                "netsurf": ("apt", "netsurf", "Lightweight browser"),
                "lynx": ("apt", "lynx", "Text-based browser"),
                "w3m": ("apt", "w3m", "Text-based web browser"),
                "dillo": ("apt", "dillo", "Minimalist web browser"),
                "surf": ("apt", "surf", "Minimalist browser"),
                "elinks": ("apt", "elinks", "Advanced text-based browser"),
                "browsh": ("snap", "browsh", "Text-based browser with graphics"),
                "min": ("snap", "min", "Minimalist web browser"),
                "badwolf": ("apt", "badwolf", "Privacy-focused minimalist browser"),
            },
            "Testy penetracyjne": {
                "metasploit": ("apt", "metasploit-framework", "Penetration testing"),
                "nmap": ("apt", "nmap", "Network scanner"),
                "sqlmap": ("apt", "sqlmap", "SQL injection testing"),
                "nikto": ("apt", "nikto", "Web server scanner"),
                "openvas": ("apt", "openvas", "Vulnerability scanner"),
                "dirb": ("apt", "dirb", "Web content scanner"),
                "zap": ("snap", "owasp-zap", "Web app security scanner"),
                "wfuzz": ("apt", "wfuzz", "Web application fuzzer"),
                "gobuster": ("apt", "gobuster", "Directory/file brute-forcer"),
                "commix": ("apt", "commix", "Command injection testing"),
                "sslyze": ("apt", "sslyze", "SSL/TLS analysis"),
                "feroxbuster": ("apt", "feroxbuster", "Web content discovery"),
                "arjun": ("apt", "arjun", "HTTP parameter discovery"),
                "dnsrecon": ("apt", "dnsrecon", "DNS enumeration tool"),
                "enum4linux": ("apt", "enum4linux", "SMB enumeration"),
                "patator": ("apt", "patator", "Brute-forcing tool"),
                "whatweb": ("apt", "whatweb", "Web scanner"),
                "wpscan": ("apt", "wpscan", "WordPress vulnerability scanner"),
                "joomscan": ("apt", "joomscan", "Joomla vulnerability scanner"),
                "droopescan": ("apt", "droopescan", "Drupal vulnerability scanner"),
                "cmsmap": ("apt", "cmsmap", "CMS vulnerability scanner"),
                "testssl": ("apt", "testssl.sh", "SSL/TLS security testing"),
                "nmap-vulners": ("apt", "nmap-vulners", "Vulnerability scanning with Nmap"),
                "nuclei": ("apt", "nuclei", "Vulnerability scanner"),
                "amass": ("apt", "amass", "Network mapping and OSINT"),
                "subfinder": ("apt", "subfinder", "Subdomain enumeration"),
            },
            "Cyberbezpieczeństwo": {
                "wireshark": ("apt", "wireshark", "Network protocol analyzer"),
                "clamav": ("apt", "clamav", "Antivirus"),
                "fail2ban": ("apt", "fail2ban", "Intrusion prevention"),
                "ufw": ("apt", "ufw", "Firewall configuration"),
                "snort": ("apt", "snort", "Intrusion detection"),
                "rkhunter": ("apt", "rkhunter", "Rootkit hunter"),
                "lynis": ("apt", "lynis", "Security auditing"),
                "chkrootkit": ("apt", "chkrootkit", "Rootkit detector"),
                "firejail": ("apt", "firejail", "Sandboxing tool"),
                "apparmor": ("apt", "apparmor", "Mandatory access control"),
                "suricata": ("apt", "suricata", "Intrusion detection"),
                "ossec-hids": ("apt", "ossec-hids", "Host-based intrusion detection"),
                "tripwire": ("apt", "tripwire", "File integrity monitoring"),
                "crowdsec": ("apt", "crowdsec", "Crowd-sourced threat detection"),
                "guacamole": ("apt", "guacamole", "Remote desktop gateway"),
                "openvpn": ("apt", "openvpn", "VPN server and client"),
                "aide": ("apt", "aide", "File integrity checker"),
                "logwatch": ("apt", "logwatch", "Log file analyzer"),
                "selinux": ("apt", "selinux-basics", "Security-Enhanced Linux"),
                "grsecurity": ("apt", "grsecurity", "Kernel security patches"),
                "osquery": ("apt", "osquery", "System monitoring and analytics"),
                "wazuh": ("apt", "wazuh-agent", "Security monitoring platform"),
                "iptables": ("apt", "iptables", "Firewall rules management"),
                "nftables": ("apt", "nftables", "Modern firewall framework"),
                "clamav-freshclam": ("apt", "clamav-freshclam", "ClamAV virus database updater"),
                "fail2ban-firewalld": ("apt", "fail2ban-firewalld", "Fail2ban with firewalld"),
            },
            "Etyczne hakowanie": {
                "burpsuite": ("snap", "burpsuite", "Web vulnerability scanner"),
                "aircrack-ng": ("apt", "aircrack-ng", "WiFi security testing"),
                "hydra": ("apt", "hydra", "Password cracking"),
                "john": ("apt", "john", "Password cracker"),
                "hashcat": ("apt", "hashcat", "Password recovery"),
                "cewl": ("apt", "cewl", "Wordlist generator"),
                "responder": ("apt", "responder", "Network poisoning"),
                "theharvester": ("apt", "theharvester", "OSINT gathering"),
                "recon-ng": ("apt", "recon-ng", "Reconnaissance framework"),
                "maltego": ("snap", "maltego", "OSINT and forensics"),
                "crunch": ("apt", "crunch", "Wordlist generator"),
                "spiderfoot": ("apt", "spiderfoot", "OSINT automation"),
                "setoolkit": ("apt", "setoolkit", "Social engineering toolkit"),
                "bettercap": ("apt", "bettercap", "Network attack framework"),
                "kismet": ("apt", "kismet", "Wireless network detector"),
                "yersinia": ("apt", "yersinia", "Network protocol attack"),
                "mitmproxy": ("apt", "mitmproxy", "Man-in-the-middle proxy"),
                "dnsmap": ("apt", "dnsmap", "DNS enumeration"),
                "fierce": ("apt", "fierce", "DNS reconnaissance"),
                "unicornscan": ("apt", "unicornscan", "Network scanner"),
                "smbmap": ("apt", "smbmap", "SMB enumeration tool"),
                "dnsenum": ("apt", "dnsenum", "DNS enumeration tool"),
                "nbtscan": ("apt", "nbtscan", "NetBIOS scanner"),
                "shodan-cli": ("apt", "shodan", "IoT and network scanning"),
                "masscan": ("apt", "masscan", "High-speed port scanner"),
                "zmap": ("apt", "zmap", "Network scanner for Internet-wide scans"),
            },
            "Naukowe": {
                "octave": ("apt", "octave", "Numerical computations"),
                "r-base": ("apt", "r-base", "Statistical computing"),
                "jupyter": ("snap", "jupyter", "Interactive notebooks"),
                "sage": ("apt", "sagemath", "Mathematics software"),
                "maxima": ("apt", "maxima", "Computer algebra"),
                "gnuplot": ("apt", "gnuplot", "Graphing utility"),
                "scilab": ("apt", "scilab", "Scientific computation"),
                "wxmaxima": ("apt", "wxmaxima", "GUI for Maxima"),
                "qtiplot": ("apt", "qtiplot", "Data analysis and plotting"),
                "labplot": ("apt", "labplot", "Data visualization"),
                "paraview": ("apt", "paraview", "Data analysis and visualization"),
                "root-framework": ("apt", "root-framework", "Data analysis framework"),
                "geant4": ("apt", "geant4", "Particle physics simulation"),
                "avogadro": ("apt", "avogadro", "Molecular editor"),
                "pymol": ("apt", "pymol", "Molecular visualization"),
                "gretl": ("apt", "gretl", "Econometrics software"),
                "freecad": ("apt", "freecad", "3D CAD modeling"),
                "openscad": ("apt", "openscad", "Programmatic 3D modeling"),
                "jmol": ("apt", "jmol", "Molecular visualization"),
                "gperiodic": ("apt", "gperiodic", "Periodic table"),
                "kalgebra": ("apt", "kalgebra", "Algebraic calculator"),
                "cantor": ("apt", "cantor", "Mathematical software frontend"),
                "kmplot": ("apt", "kmplot", "Function plotter"),
                "pspp": ("apt", "pspp", "Statistical analysis"),
                "rstudio": ("snap", "rstudio", "R programming IDE"),
                "matlab": ("snap", "matlab", "Numerical computing environment"),
            },
            "Komunikacja": {
                "discord": ("snap", "discord", "Chat platform"),
                "signal": ("snap", "signal-desktop", "Secure messaging"),
                "telegram": ("snap", "telegram-desktop", "Messaging app"),
                "element": ("snap", "element-desktop", "Matrix client"),
                "pidgin": ("apt", "pidgin", "Multi-protocol chat"),
                "hexchat": ("apt", "hexchat", "IRC client"),
                "slack": ("snap", "slack", "Team communication"),
                "zoom": ("snap", "zoom-client", "Video conferencing"),
                "teams": ("snap", "teams", "Microsoft Teams"),
                "mattermost": ("snap", "mattermost-desktop", "Team collaboration"),
                "rocketchat": ("snap", "rocketchat-desktop", "Chat platform"),
                "jitsi": ("snap", "jitsi-meet", "Video conferencing"),
                "skype": ("snap", "skype", "Video and voice calls"),
                "wire": ("snap", "wire", "Secure collaboration platform"),
                "mumble": ("apt", "mumble", "Voice chat for gamers"),
                "linphone": ("apt", "linphone", "VoIP and messaging"),
                "weechat": ("apt", "weechat", "Terminal-based IRC client"),
                "irssi": ("apt", "irssi", "Terminal-based IRC client"),
                "zulip": ("snap", "zulip", "Team chat platform"),
                "riot-desktop": ("snap", "riot-web", "Matrix-based chat"),
                "gajim": ("apt", "gajim", "XMPP chat client"),
                "dino": ("apt", "dino", "Modern XMPP client"),
                "profanity": ("apt", "profanity", "Console-based XMPP client"),
                "tox": ("apt", "qtox", "Secure peer-to-peer messaging"),
                "ring": ("apt", "ring", "Decentralized communication"),
            },
            "Grafika": {
                "inkscape": ("apt", "inkscape", "Vector graphics"),
                "krita": ("snap", "krita", "Digital painting"),
                "darktable": ("apt", "darktable", "Photo workflow"),
                "pinta": ("apt", "pinta", "Simple image editor"),
                "mypaint": ("apt", "mypaint", "Digital painting"),
                "gravit-designer": ("snap", "gravit-designer", "Vector design"),
                "photopea": ("snap", "photopea", "Online photo editor"),
                "digikam": ("apt", "digikam", "Photo management"),
                "rawtherapee": ("apt", "rawtherapee", "RAW image processing"),
                "hugin": ("apt", "hugin", "Panorama stitching"),
                "luminance-hdr": ("apt", "luminance-hdr", "HDR imaging"),
                "gmic": ("apt", "gmic", "Image processing framework"),
                "exiv2": ("apt", "exiv2", "Image metadata management"),
                "aseprite": ("snap", "aseprite", "Pixel art editor"),
                "photocollage": ("apt", "photocollage", "Photo collage maker"),
                "nomacs": ("apt", "nomacs", "Image viewer"),
                "gthumb": ("apt", "gthumb", "Image viewer and organizer"),
                "kolourpaint": ("apt", "kolourpaint", "Simple painting program"),
                "showfoto": ("apt", "showfoto", "Photo viewer and editor"),
                "gwenview": ("apt", "gwenview", "Image viewer"),
                "xviewer": ("apt", "xviewer", "Lightweight image viewer"),
                "fotoxx": ("apt", "fotoxx", "Photo editing and management"),
                "imagine": ("snap", "imagine", "Image optimizer"),
                "pixelitor": ("snap", "pixelitor", "Image editor"),
                "photocritic": ("snap", "photocritic", "Photo critique tool"),
            },
            "Systemowe": {
                "neofetch": ("apt", "neofetch", "System information"),
                "hardinfo": ("apt", "hardinfo", "Hardware information"),
                "glances": ("apt", "glances", "System monitoring"),
                "baobab": ("apt", "baobab", "Disk usage analyzer"),
                "ncdu": ("apt", "ncdu", "Disk usage analyzer"),
                "sysstat": ("apt", "sysstat", "System performance tools"),
                "cockpit": ("apt", "cockpit", "Server management"),
                "lm-sensors": ("apt", "lm-sensors", "Hardware monitoring"),
                "iotop": ("apt", "iotop", "I/O monitoring"),
                "btop": ("apt", "btop", "Modern system monitor"),
                "nmon": ("apt", "nmon", "Performance monitoring"),
                "powertop": ("apt", "powertop", "Power consumption monitor"),
                "htop": ("apt", "htop", "Interactive system monitor"),
                "bashtop": ("apt", "bashtop", "Resource monitor"),
                "stress-ng": ("apt", "stress-ng", "System stress testing"),
                "zram-config": ("apt", "zram-config", "Memory compression"),
                "lscpu": ("apt", "util-linux", "CPU information"),
                "lsblk": ("apt", "util-linux", "Block device information"),
                "fio": ("apt", "fio", "I/O benchmarking"),
                "atop": ("apt", "atop", "Advanced system monitor"),
                "dstat": ("apt", "dstat", "System resource statistics"),
                "lshw": ("apt", "lshw", "Hardware lister"),
                "inxi": ("apt", "inxi", "System information script"),
                "s-tui": ("apt", "s-tui", "Terminal-based system monitor"),
                "monitorix": ("apt", "monitorix", "System and network monitoring"),
                "vnstat": ("apt", "vnstat", "Network traffic monitor"),
            },
            "AI i uczenie maszynowe": {
                "tensorflow": ("snap", "tensorflow", "Machine learning framework"),
                "pytorch": ("snap", "pytorch", "Deep learning framework"),
                "scikit-learn": ("apt", "python3-sklearn", "Machine learning library"),
                "keras": ("apt", "python3-keras", "Deep learning API"),
                "opencv": ("apt", "libopencv-dev", "Computer vision library"),
                "caffe": ("apt", "caffe-cpu", "Deep learning framework"),
                "h2o": ("snap", "h2o", "Machine learning platform"),
                "weka": ("apt", "weka", "Data mining software"),
                "orange": ("snap", "orange3", "Data visualization and analysis"),
                "knime": ("snap", "knime", "Data analytics platform"),
                "rapidminer": ("snap", "rapidminer-studio", "Data science platform"),
                "mahout": ("apt", "mahout", "Scalable machine learning"),
                "dlib": ("apt", "libdlib-dev", "Machine learning library"),
                "mlpack": ("apt", "libmlpack-dev", "Fast machine learning library"),
            },
            "Blockchain i kryptowaluty": {
                "bitcoin-core": ("snap", "bitcoin-core", "Bitcoin client"),
                "electrum": ("snap", "electrum", "Bitcoin wallet"),
                "monero": ("snap", "monero", "Monero cryptocurrency client"),
                "geth": ("apt", "geth", "Ethereum client"),
                "parity": ("snap", "parity", "Ethereum client"),
                "mist": ("snap", "mist", "Ethereum wallet and DApp browser"),
                "truffle": ("snap", "truffle", "Ethereum development framework"),
                "remix-ide": ("snap", "remix-ide", "Solidity IDE"),
                "ganache": ("snap", "ganache", "Ethereum blockchain simulator"),
                "open-ethereum": ("snap", "open-ethereum", "Ethereum client"),
            },
            "Forensyka cyfrowa": {
                "autopsy": ("apt", "autopsy", "Digital forensics platform"),
                "sleuthkit": ("apt", "sleuthkit", "Forensic toolkit"),
                "foremost": ("apt", "foremost", "File recovery tool"),
                "scalpel": ("apt", "scalpel", "File carving tool"),
                "binwalk": ("apt", "binwalk", "Firmware analysis tool"),
                "volatility": ("apt", "volatility", "Memory forensics"),
                "guymager": ("apt", "guymager", "Forensic imaging"),
                "dc3dd": ("apt", "dc3dd", "Enhanced dd for forensics"),
                "rkhunter": ("apt", "rkhunter", "Rootkit detection"),
                "chkrootkit": ("apt", "chkrootkit", "Rootkit detection"),
                "exiftool": ("apt", "libimage-exiftool-perl", "Metadata analysis"),
                "hashdeep": ("apt", "hashdeep", "File integrity checking"),
            },
            "Favorites": {
                # Populated dynamically
            }
        }

        # Initialize critical attributes
        self.favorites = {}
        self.selected_install = {}
        self.selected_remove = {}
        self.status_var = tk.StringVar(value="Ready")
        self.progress_var = tk.DoubleVar(value=0)
        self.lock = threading.Lock()
        self.search_cache = {}
        self.category_frames = {}

        # Main container
        self.main_frame = tk.Frame(self.root, bg="#151515")
        self.main_frame.pack(fill="both", expand=True, padx=6, pady=6)

        # Header
        self.header_label = ttk.Label(
            self.main_frame,
            text="Hacker Unpack",
            font=("Roboto", 18, "bold"),
            background="#151515",
            foreground="#ffffff"
        )
        self.header_label.pack(pady=(0, 6))

        # Category selection
        self.notebook = ttk.Notebook(self.main_frame)
        self.notebook.pack(fill="both", expand=True, pady=4)

        try:
            for category, packages in self.categories.items():
                frame = tk.Frame(self.notebook, bg="#151515")
                self.notebook.add(frame, text=f"{category} ({len(packages)})")
                self.category_frames[category] = self.create_category_frame(frame, category, packages)
        except Exception as e:
            logging.error(f"Error initializing category frames: {str(e)}")
            messagebox.showerror("Error", f"Failed to initialize categories: {str(e)}")
            self.root.destroy()
            return

        # Search bar
        self.search_frame = tk.Frame(self.main_frame, bg="#252525")
        self.search_frame.pack(fill="x", pady=(0, 4))

        self.search_var = tk.StringVar()
        self.search_entry = ttk.Entry(
            self.search_frame,
            textvariable=self.search_var,
            font=("Roboto", 7)
        )
        self.search_entry.insert(0, "Search packages...")
        self.search_entry.bind("<FocusIn>", lambda e: self.search_entry.delete(0, tk.END) if self.search_entry.get() == "Search packages..." else None)
        self.search_entry.bind("<FocusOut>", lambda e: self.search_entry.insert(0, "Search packages...") if not self.search_entry.get() else None)
        self.search_entry.pack(fill="x", padx=4, side="left", expand=True)

        self.clear_search_button = ttk.Button(
            self.search_frame,
            text="Clear",
            command=lambda: self.search_var.set("")
        )
        self.clear_search_button.pack(side="right", padx=4)

        # Bind search after category_frames is initialized
        self.search_var.trace("w", self.filter_packages)

        # Button frame
        self.button_frame = tk.Frame(self.main_frame, bg="#151515")
        self.button_frame.pack(fill="x", pady=4)

        self.select_all_button = ttk.Button(
            self.button_frame,
            text="Select All",
            command=self.select_all
        )
        self.select_all_button.pack(side="left", padx=4)

        self.clear_button = ttk.Button(
            self.button_frame,
            text="Clear All",
            command=self.clear_selection
        )
        self.clear_button.pack(side="left", padx=4)

        self.install_button = ttk.Button(
            self.button_frame,
            text="Install",
            command=self.confirm_install
        )
        self.install_button.pack(side="right", padx=4)

        self.remove_button = ttk.Button(
            self.button_frame,
            text="Remove",
            command=self.confirm_remove
        )
        self.remove_button.pack(side="right", padx=4)

        self.log_button = ttk.Button(
            self.button_frame,
            text="View Log",
            command=self.show_log
        )
        self.log_button.pack(side="right", padx=4)

        # Progress bar
        self.progress_bar = ttk.Progressbar(
            self.main_frame,
            variable=self.progress_var,
            maximum=100
        )
        self.progress_bar.pack(fill="x", pady=(4, 4))

        # Status bar
        self.status_bar = ttk.Label(
            self.main_frame,
            textvariable=self.status_var,
            relief="flat",
            padding=4,
            font=("Roboto", 8),
            background="#252525",
            foreground="#ffffff"
        )
        self.status_bar.pack(fill="x", side="bottom", pady=(4, 0))

    def create_category_frame(self, frame, category, packages):
        canvas = tk.Canvas(frame, bg="#151515", highlightthickness=0)
        scrollbar = ttk.Scrollbar(frame, orient="vertical", command=canvas.yview)
        scrollable_frame = tk.Frame(canvas, bg="#151515")

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True, padx=4, pady=4)
        scrollbar.pack(side="right", fill="y")

        self.selected_install[category] = {}
        self.selected_remove[category] = {}
        package_widgets = {}

        # Grid layout for packages
        row = 0
        col = 0
        max_cols = 5

        for pkg_name, (pkg_type, pkg_id, description) in packages.items():
            var_install = tk.BooleanVar()
            var_remove = tk.BooleanVar()
            self.selected_install[category][pkg_name] = (var_install, pkg_type, pkg_id)
            self.selected_remove[category][pkg_name] = (var_remove, pkg_type, pkg_id)

            # Create frame for each package
            pkg_frame = tk.Frame(scrollable_frame, bg="#252525")
            pkg_frame.grid(row=row, column=col, padx=2, pady=2, sticky="ew")

            chk_install = ttk.Checkbutton(
                pkg_frame,
                text=pkg_name,
                variable=var_install,
            )
            chk_install.pack(side="left", padx=4)

            btn_remove = ttk.Button(
                pkg_frame,
                text="Remove",
                style="Remove.TButton",
                command=lambda p=pkg_name, c=category: self.toggle_remove(c, p)
            )
            btn_remove.pack(side="right", padx=4)

            btn_favorite = ttk.Button(
                pkg_frame,
                text="★",
                command=lambda p=pkg_name, c=category: self.toggle_favorite(c, p, pkg_type, pkg_id, description),
                width=2
            )
            btn_favorite.pack(side="right", padx=2)

            desc_label = ttk.Label(
                pkg_frame,
                text=description,
                font=("Roboto", 6),
                foreground="#aaaaaa"
            )
            desc_label.pack(side="left", padx=5)

            # Tooltip
            desc_label.bind("<Enter>", lambda e, d=description: self.show_tooltip(e, d))
            desc_label.bind("<Leave>", lambda e: self.hide_tooltip())

            # Hover effect
            pkg_frame.bind("<Enter>", lambda e, f=pkg_frame: f.configure(bg="#1d1d1d"))
            pkg_frame.bind("<Leave>", lambda e, f=pkg_frame: f.configure(bg="#252525"))

            package_widgets[pkg_name] = pkg_frame

            col += 1
            if col >= max_cols:
                col = 0
                row += 1

        return {"canvas": canvas, "scrollable_frame": scrollable_frame, "packages": package_widgets}

    def show_tooltip(self, event, description):
        try:
            self.tooltip = tk.Toplevel(self.root)
            self.tooltip.wm_overrideredirect(True)
            self.tooltip.wm_geometry(f"+{event.x_root + 10}+{event.y_root + 10}")
            label = tk.Label(
                self.tooltip,
                text=description,
                bg="#252525",
                fg="#ffffff",
                font=("Roboto", 6),
                padx=4,
                pady=2,
                relief="flat"
            )
            label.pack()
        except Exception as e:
            logging.error(f"Error showing tooltip: {str(e)}")

    def hide_tooltip(self):
        try:
            if hasattr(self, "tooltip") and self.tooltip:
                self.tooltip.destroy()
        except Exception as e:
            logging.error(f"Error hiding tooltip: {str(e)}")

    def toggle_favorite(self, category, pkg_name, pkg_type, pkg_id, description):
        with self.lock:
            try:
                if pkg_name in self.favorites:
                    del self.favorites[pkg_name]
                    logging.info(f"Removed {pkg_name} from Favorites")
                else:
                    self.favorites[pkg_name] = (pkg_type, pkg_id, description)
                    logging.info(f"Added {pkg_name} to Favorites")

                # Update Favorites tab
                self.categories["Favorites"] = self.favorites
                if "Favorites" in self.category_frames:
                    favorites_frame = self.category_frames["Favorites"]["scrollable_frame"]
                    for widget in favorites_frame.winfo_children():
                        widget.destroy()
                    self.category_frames["Favorites"] = self.create_category_frame(
                        favorites_frame.master, "Favorites", self.favorites
                    )
                self.status_var.set(f"Toggled favorite for {pkg_name}")
            except Exception as e:
                logging.error(f"Error toggling favorite for {pkg_name}: {str(e)}")
                self.status_var.set(f"Error toggling favorite for {pkg_name}")

    def toggle_remove(self, category, pkg_name):
        with self.lock:
            try:
                if category in self.selected_remove and pkg_name in self.selected_remove[category]:
                    var_remove = self.selected_remove[category][pkg_name][0]
                    var_remove.set(not var_remove.get())
                    self.status_var.set(f"Toggled remove for {pkg_name}")
                    logging.info(f"Toggled remove for {pkg_name} in {category}")
                else:
                    logging.warning(f"Invalid category or package: {category}/{pkg_name}")
            except Exception as e:
                logging.error(f"Error toggling remove for {pkg_name}: {str(e)}")
                self.status_var.set(f"Error toggling remove for {pkg_name}")

    def select_all(self):
        with self.lock:
            try:
                for category in self.selected_install:
                    for pkg_name, (var, _, _) in self.selected_install[category].items():
                        var.set(True)
                self.status_var.set("All packages selected")
                logging.info("Selected all packages")
            except Exception as e:
                logging.error(f"Error selecting all packages: {str(e)}")
                self.status_var.set("Error selecting all packages")

    def clear_selection(self):
        with self.lock:
            try:
                for category in self.selected_install:
                    for pkg_name, (var, _, _) in self.selected_install[category].items():
                        var.set(False)
                for category in self.selected_remove:
                    for pkg_name, (var, _, _) in self.selected_remove[category].items():
                        var.set(False)
                self.status_var.set("Selections cleared")
                logging.info("Cleared all selections")
            except Exception as e:
                logging.error(f"Error clearing selections: {str(e)}")
                self.status_var.set("Error clearing selections")

    def filter_packages(self, *args):
        if not hasattr(self, "category_frames") or not self.category_frames:
            return  # Skip if category_frames is not initialized

        search_term = self.search_var.get().lower()
        try:
            if search_term in self.search_cache:
                results = self.search_cache[search_term]
            else:
                results = {}
                for category, frame_data in self.category_frames.items():
                    results[category] = {}
                    for pkg_name, pkg_frame in frame_data["packages"].items():
                        if search_term in pkg_name.lower() or search_term in self.categories[category][pkg_name][2].lower():
                            results[category][pkg_name] = True
                        else:
                            results[category][pkg_name] = False
                self.search_cache[search_term] = results

            for category, frame_data in self.category_frames.items():
                for pkg_name, pkg_frame in frame_data["packages"].items():
                    if results[category][pkg_name]:
                        pkg_frame.grid()
                    else:
                        pkg_frame.grid_remove()
            logging.info(f"Filtered packages with term: {search_term}")
        except Exception as e:
            logging.error(f"Error filtering packages: {str(e)}")
            self.status_var.set("Error filtering packages")

    def show_log(self):
        try:
            log_window = tk.Toplevel(self.root)
            log_window.title("Installation Log")
            log_window.geometry("800x600")
            log_window.configure(bg="#151515")

            log_text = scrolledtext.ScrolledText(
                log_window,
                bg="#252525",
                fg="#ffffff",
                font=("Roboto", 7),
                wrap=tk.WORD
            )
            log_text.pack(fill="both", expand=True, padx=4, pady=4)

            try:
                with open(self.log_file, "r") as f:
                    log_text.insert(tk.END, f.read())
                log_text.config(state="disabled")
            except FileNotFoundError:
                log_text.insert(tk.END, "No log file found.")
                log_text.config(state="disabled")
            logging.info("Opened log viewer")
        except Exception as e:
            logging.error(f"Error showing log: {str(e)}")
            messagebox.showerror("Error", f"Failed to show log: {str(e)}")

    def confirm_install(self):
        try:
            selected_count = sum(
                sum(var.get() for var, _, _ in pkgs.values())
                for pkgs in self.selected_install.values()
            )
            if selected_count == 0:
                messagebox.showwarning("Warning", "No packages selected for installation!")
                return
            if messagebox.askyesno("Confirm", f"Install {selected_count} packages?"):
                self.install_packages()
        except Exception as e:
            logging.error(f"Error confirming install: {str(e)}")
            messagebox.showerror("Error", f"Failed to confirm install: {str(e)}")

    def confirm_remove(self):
        try:
            selected_count = sum(
                sum(var.get() for var, _, _ in pkgs.values())
                for pkgs in self.selected_remove.values()
            )
            if selected_count == 0:
                messagebox.showwarning("Warning", "No packages selected for removal!")
                return
            if messagebox.askyesno("Confirm", f"Remove {selected_count} packages?"):
                self.remove_packages()
        except Exception as e:
            logging.error(f"Error confirming remove: {str(e)}")
            messagebox.showerror("Error", f"Failed to confirm remove: {str(e)}")

    def install_packages(self):
        commands = []
        selected_count = 0
        with self.lock:
            try:
                for category in self.selected_install:
                    if category not in self.selected_install:
                        continue
                    for pkg_name, (var, pkg_type, pkg_id) in self.selected_install[category].items():
                        if var.get():
                            selected_count += 1
                            if pkg_type == "apt":
                                commands.append(f"echo 'Installing {pkg_name}...'; sudo apt-get install -y {pkg_id}")
                            elif pkg_type == "snap":
                                commands.append(f"echo 'Installing {pkg_name}...'; sudo snap install {pkg_id}")
                            elif pkg_type == "flatpak":
                                commands.append(f"echo 'Installing {pkg_name}...'; flatpak install -y flathub {pkg_id}")
            except Exception as e:
                logging.error(f"Error building install commands: {str(e)}")
                messagebox.showerror("Error", f"Failed to prepare installation: {str(e)}")
                return

        if not commands:
            self.status_var.set("No packages to install")
            return

        self.status_var.set(f"Installing {selected_count} packages...")
        self.progress_var.set(0)
        try:
            threading.Thread(target=self.run_installation, args=(commands, selected_count), daemon=True).start()
            logging.info(f"Started installation of {selected_count} packages")
        except Exception as e:
            logging.error(f"Error starting installation thread: {str(e)}")
            messagebox.showerror("Error", f"Failed to start installation: {str(e)}")

    def remove_packages(self):
        commands = []
        selected_count = 0
        with self.lock:
            try:
                for category in self.selected_remove:
                    if category not in self.selected_remove:
                        continue
                    for pkg_name, (var, pkg_type, pkg_id) in self.selected_remove[category].items():
                        if var.get():
                            selected_count += 1
                            if pkg_type == "apt":
                                commands.append(f"echo 'Removing {pkg_name}...'; sudo apt-get remove -y {pkg_id}")
                                commands.append(f"sudo apt-get autoremove -y")
                            elif pkg_type == "snap":
                                commands.append(f"echo 'Removing {pkg_name}...'; sudo snap remove {pkg_id}")
                            elif pkg_type == "flatpak":
                                commands.append(f"echo 'Removing {pkg_name}...'; flatpak uninstall -y {pkg_id}")
            except Exception as e:
                logging.error(f"Error building remove commands: {str(e)}")
                messagebox.showerror("Error", f"Failed to prepare removal: {str(e)}")
                return

        if not commands:
            self.status_var.set("No packages to remove")
            return

        self.status_var.set(f"Removing {selected_count} packages...")
        self.progress_var.set(0)
        try:
            threading.Thread(target=self.run_installation, args=(commands, selected_count, True), daemon=True).start()
            logging.info(f"Started removal of {selected_count} packages")
        except Exception as e:
            logging.error(f"Error starting removal thread: {str(e)}")
            messagebox.showerror("Error", f"Failed to start removal: {str(e)}")

    def run_installation(self, commands, count, is_remove=False):
        script_path = None
        process = None
        try:
            script = "#!/bin/bash\n"
            if not is_remove:
                script += "echo 'Updating package lists...'; sudo apt-get update\n"
            for i, cmd in enumerate(commands):
                script += f"{cmd}\n"
                script += f"echo 'Completed {i+1}/{len(commands)}'\n"
            script += f"echo '{f'Removal' if is_remove else 'Installation'} of {count} packages complete. Press Enter to close.'\n"
            script += "read\n"

            script_path = f"/tmp/hacker_unpack_{uuid.uuid4().hex}.sh"
            with open(script_path, "w") as f:
                f.write(script)

            os.chmod(script_path, 0o755)
            logging.info(f"Created script at {script_path}")

            self.root.after(0, lambda: self.status_var.set(
                f"{'Removing' if is_remove else 'Installing'} {count} packages..."
            ))

            terminal_cmd = f"alacritty -e bash {script_path}"
            process = subprocess.Popen(terminal_cmd, shell=True, stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE, universal_newlines=True)

            step = 100.0 / len(commands)
            for i in range(len(commands)):
                line = process.stdout.readline()
                if line:
                    logging.info(f"Command output: {line.strip()}")
                self.root.after(0, lambda x=(i+1)*step: self.progress_var.set(x))
                self.root.after(0, lambda: self.status_var.set(
                    f"{'Removing' if is_remove else 'Installing'} {i+1}/{len(commands)}..."
                ))

            _, stderr = process.communicate()
            if stderr:
                logging.error(f"Process stderr: {stderr}")

            if process.returncode == 0:
                self.root.after(0, lambda: self.status_var.set(
                    f"{'Removal' if is_remove else 'Installation'} completed"
                ))
                self.root.after(0, lambda: self.progress_var.set(100))
                logging.info(f"{'Removal' if is_remove else 'Installation'} completed")
            else:
                self.root.after(0, lambda: messagebox.showerror(
                    "Error", f"{'Removal' if is_remove else 'Installation'} failed: {stderr}",
                    buttons=["Retry", "Cancel"],
                    default="Cancel",
                    callback=lambda res: self.run_installation(commands, count, is_remove) if res == "Retry" else None
                ))
                logging.error(f"{'Removal' if is_remove else 'Installation'} failed: {stderr}")

        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror(
                "Error", f"{'Removal' if is_remove else 'Installation'} failed: {str(e)}",
                buttons=["Retry", "Cancel"],
                default="Cancel",
                callback=lambda res: self.run_installation(commands, count, is_remove) if res == "Retry" else None
            ))
            logging.exception(f"Exception during {'removal' if is_remove else 'installation'}: {str(e)}")

        finally:
            if script_path and os.path.exists(script_path):
                try:
                    os.remove(script_path)
                    logging.info(f"Cleaned up script at {script_path}")
                except OSError as e:
                    logging.error(f"Failed to clean up script {script_path}: {str(e)}")

            if process and process.poll() is None:
                try:
                    process.terminate()
                    logging.info("Terminated running process")
                except Exception as e:
                    logging.error(f"Error terminating process: {str(e)}")

            self.root.after(1500, self.root.destroy)
            logging.info("Application closed")

if __name__ == "__main__":
    try:
        root = tk.Tk()
        app = HackerUnpackApp(root)
        root.mainloop()
    except Exception as e:
        logging.critical(f"Fatal error in main: {str(e)}")
        print(f"Fatal error: {str(e)}")
        raise
