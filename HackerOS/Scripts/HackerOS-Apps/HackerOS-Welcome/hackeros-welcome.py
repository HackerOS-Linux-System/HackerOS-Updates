import sys
import os
import locale
import webbrowser
import subprocess
import logging
import socket
from datetime import datetime
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout, QFrame, QProgressBar
from PyQt5.QtGui import QPixmap, QFont
from PyQt5.QtCore import Qt, QTimer

class HackerOSWelcome(QWidget):
    def __init__(self):
        super().__init__()

        # Configure logging
        self.setup_logging()

        self.setWindowTitle("HackerOS Welcome")
        self.setGeometry(100, 100, 900, 650)
        self.setStyleSheet("background-color: #121212; color: white;")

        # Determine system language
        self.language = self.get_system_language()
        self.translations = self.load_translations()

        self.initUI()

    def setup_logging(self):
        """Configure logging to file."""
        log_dir = "/var/log/hackeros"
        if not os.path.exists(log_dir):
            os.makedirs(log_dir)
        logging.basicConfig(
            filename=f"{log_dir}/hackeros_welcome_{datetime.now().strftime('%Y%m%d')}.log",
            level=logging.INFO,
            format="%(asctime)s - %(levelname)s - %(message)s"
        )
        logging.info("HackerOSWelcome application started.")

    def get_system_language(self):
        """Get system language."""
        lang = locale.getlocale()[0]
        return lang.split('_')[0] if lang else 'en'

    def load_translations(self):
        """Load translations for UI elements."""
        translations = {
            'pl': {
                'title': "Witaj w HackerOS!",
                'subtitle': "Twój system do Gier i Etycznego Hakowania",
                'check_updates': "Sprawdź aktualizacje",
                'launch_tools': "Uruchom narzędzia HackerOS",
                'open_website': "Otwórz stronę HackerOS",
                'open_x': "Otwórz X",
                'open_docs': "Otwórz dokumentację",
                'launch_steam': "Uruchom Steam",
                'open_software': "Otwórz sklep z aplikacjami",
                'restart_system': "Restartuj system",
                'updates_done': "Sprawdzenie aktualizacji zakończone.",
                'tools_launched': "Uruchomiono narzędzia HackerOS.",
                'steam_launched': "Steam został uruchomiony w trybie gamepad UI.",
                'software_opened': "Uruchomiono Sklep z aplikacjami.",
                'docs_opened': "Otworzono dokumentację HackerOS.",
                'no_internet': "Brak połączenia z internetem.",
                'error': "Wystąpił błąd: {}"
            },
            'en': {
                'title': "Welcome to HackerOS!",
                'subtitle': "Your system for Gaming and Ethical Hacking",
                'check_updates': "Check for updates",
                'launch_tools': "Launch HackerOS Tools",
                'open_website': "Open HackerOS Website",
                'open_x': "Open X",
                'open_docs': "Open Documentation",
                'launch_steam': "Launch Steam",
                'open_software': "Open Software Store",
                'restart_system': "Restart System",
                'updates_done': "Update check completed.",
                'tools_launched': "HackerOS Tools launched.",
                'steam_launched': "Steam launched in gamepad UI mode.",
                'software_opened': "Software Store opened.",
                'docs_opened': "HackerOS Documentation opened.",
                'no_internet': "No internet connection.",
                'error': "An error occurred: {}"
            }
        }
        return translations.get(self.language, translations['en'])

    def initUI(self):
        main_layout = QVBoxLayout()
        top_layout = QHBoxLayout()

        # Logo
        self.logo_label = QLabel(self)
        pixmap = QPixmap("/usr/share/HackerOS/ICONS/HackerOS.png")
        self.logo_label.setPixmap(pixmap)
        self.logo_label.setFixedSize(120, 120)
        self.logo_label.setScaledContents(True)
        top_layout.addWidget(self.logo_label)

        # Title
        self.title_label = QLabel(self.translations['title'], self)
        self.title_label.setFont(QFont("Arial", 28, QFont.Bold))
        self.title_label.setAlignment(Qt.AlignCenter)
        top_layout.addWidget(self.title_label)

        main_layout.addLayout(top_layout)

        self.subtitle_label = QLabel(self.translations['subtitle'], self)
        self.subtitle_label.setFont(QFont("Arial", 18))
        self.subtitle_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(self.subtitle_label)

        # Progress bar for updates
        self.progress_bar = QProgressBar(self)
        self.progress_bar.setVisible(False)
        self.progress_bar.setMaximum(100)
        main_layout.addWidget(self.progress_bar)

        # Separator
        separator = QFrame()
        separator.setFrameShape(QFrame.HLine)
        separator.setFrameShadow(QFrame.Sunken)
        separator.setStyleSheet("background-color: #888; height: 2px;")
        main_layout.addWidget(separator)

        # Buttons layout
        buttons_layout = QHBoxLayout()
        left_buttons = QVBoxLayout()
        right_buttons = QVBoxLayout()

        button_style = """
            QPushButton {
                background-color: #1E1E1E;
                color: white;
                border: 2px solid #555;
                border-radius: 8px;
                padding: 10px;
                font-size: 14px;
            }
            QPushButton:hover {
                background-color: #333;
                border-color: #777;
            }
            QPushButton:pressed {
                background-color: #444;
            }
        """

        # Left side buttons
        buttons_left = [
            (self.translations['check_updates'], self.checkUpdates),
            (self.translations['launch_tools'], self.launchTools),
            (self.translations['open_website'], lambda: self.open_url("https://hackeros.webnode.page")),
            (self.translations['open_x'], lambda: self.open_url("https://x.com/hackeros_linux")),
            (self.translations['open_docs'], self.openDocumentation),
            (self.translations['launch_steam'], self.launchSteam),
            (self.translations['open_software'], self.openSoftware),
            (self.translations['restart_system'], self.restartSystem)
        ]

        for text, action in buttons_left:
            btn = QPushButton(text, self)
            btn.setStyleSheet(button_style)
            btn.clicked.connect(action)
            left_buttons.addWidget(btn)

        # Right side buttons
        buttons_right = [
            ("Hacker-Unpack", "/usr/share/HackerOS/Scripts/Bin/Hacker-Unpack.sh"),
            ("Hacker Viewer", "/usr/share/HackerOS/Scripts/Bin/Hacker-Viewer.sh"),
            ("Penetration Mode", "/usr/share/HackerOS/Scripts/Bin/PenetrationMode.sh"),
            ("Zaktualizuj HackerOS", "/usr/share/HackerOS/Scripts/Bin/update_system.sh")
        ]

        for text, path in buttons_right:
            btn = QPushButton(text, self)
            btn.setStyleSheet(button_style)
            btn.clicked.connect(lambda _, p=path: self.run_script(p, text))
            right_buttons.addWidget(btn)

        buttons_layout.addLayout(left_buttons)
        buttons_layout.addLayout(right_buttons)

        main_layout.addLayout(buttons_layout)
        self.setLayout(main_layout)

    def check_internet(self):
        """Check if internet connection is available."""
        try:
            socket.create_connection(("8.8.8.8", 53), timeout=3)
            return True
        except OSError:
            return False

    def checkUpdates(self):
        """Check and install system updates with progress."""
        logging.info("Checking for updates.")
        if not self.check_internet():
            self.subtitle_label.setText(self.translations['no_internet'])
            logging.warning("No internet connection for updates.")
            return

        self.progress_bar.setVisible(True)
        self.progress_bar.setValue(0)
        self.subtitle_label.setText("Checking updates...")

        def update_progress():
            self.progress_bar.setValue(self.progress_bar.value() + 10)
            if self.progress_bar.value() >= 100:
                self.progress_bar.setVisible(False)
                self.subtitle_label.setText(self.translations['updates_done'])
                logging.info("Updates check completed.")
                return

        self.timer = QTimer()
        self.timer.timeout.connect(update_progress)
        self.timer.start(500)

        try:
            subprocess.run(["pkexec", "bash", "-c", "apt update && apt upgrade -y && flatpak update -y"], check=True)
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Update failed: {e}")
            self.timer.stop()
            self.progress_bar.setVisible(False)

    def launchTools(self):
        """Launch HackerOS tools."""
        logging.info("Launching HackerOS tools.")
        try:
            subprocess.run(["pkexec", "bash", "/usr/share/HackerOS/Scripts/Bin/install-tools.sh"], check=True)
            self.subtitle_label.setText(self.translations['tools_launched'])
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to launch tools: {e}")

    def open_url(self, url):
        """Open a URL in the default browser."""
        logging.info(f"Opening URL: {url}")
        if not self.check_internet():
            self.subtitle_label.setText(self.translations['no_internet'])
            logging.warning(f"No internet connection to open URL: {url}")
            return
        try:
            webbrowser.open(url)
        except Exception as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to open URL {url}: {e}")

    def launchSteam(self):
        """Launch Steam with gamepad UI."""
        logging.info("Launching Steam.")
        try:
            subprocess.run(["steam", "-gamepadui"], check=True)
            self.subtitle_label.setText(self.translations['steam_launched'])
        except FileNotFoundError:
            logging.info("Steam not found, installing...")
            try:
                subprocess.run(["pkexec", "apt", "install", "steam", "-y"], check=True)
                subprocess.run(["steam", "-gamepadui"], check=True)
                self.subtitle_label.setText(self.translations['steam_launched'])
            except subprocess.CalledProcessError as e:
                self.subtitle_label.setText(self.translations['error'].format(str(e)))
                logging.error(f"Failed to install/launch Steam: {e}")
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to launch Steam: {e}")

    def openSoftware(self):
        """Open GNOME Software."""
        logging.info("Opening GNOME Software.")
        try:
            subprocess.run(["gnome-software"], check=True)
            self.subtitle_label.setText(self.translations['software_opened'])
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to open GNOME Software: {e}")

    def openDocumentation(self):
        """Open HackerOS documentation."""
        logging.info("Opening HackerOS documentation.")
        try:
            subprocess.run(["pkexec", "bash", "/usr/share/HackerOS/Scripts/Bin/HackerOS-Documentation.sh"], check=True)
            self.subtitle_label.setText(self.translations['docs_opened'])
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to open documentation: {e}")

    def restartSystem(self):
        """Restart the system."""
        logging.info("Initiating system restart.")
        try:
            subprocess.run(["pkexec", "reboot"], check=True)
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to restart system: {e}")

    def run_script(self, path, script_name):
        """Run a script with pkexec."""
        logging.info(f"Running script: {script_name} ({path})")
        try:
            subprocess.run(["pkexec", "bash", path], check=True)
            self.subtitle_label.setText(f"{script_name} launched.")
        except subprocess.CalledProcessError as e:
            self.subtitle_label.setText(self.translations['error'].format(str(e)))
            logging.error(f"Failed to run script {script_name}: {e}")

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = HackerOSWelcome()
    window.show()
    sys.exit(app.exec_())
