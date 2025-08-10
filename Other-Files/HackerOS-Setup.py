import sys
import subprocess
import socket
from PyQt6.QtWidgets import QApplication, QMainWindow, QPushButton, QLabel, QVBoxLayout, QWidget, QMessageBox, QDialog, QLineEdit, QFormLayout, QDialogButtonBox
from PyQt6.QtGui import QPixmap
from PyQt6.QtCore import Qt

class NetworkConfigDialog(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Konfiguracja Połączenia Internetowego")
        self.setFixedSize(400, 200)
        
        layout = QFormLayout()
        
        self.ssid_input = QLineEdit()
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)
        
        layout.addRow("SSID (Nazwa sieci WiFi):", self.ssid_input)
        layout.addRow("Hasło:", self.password_input)
        
        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel)
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        
        layout.addRow(buttons)
        self.setLayout(layout)
    
    def configure_network(self):
        ssid = self.ssid_input.text()
        password = self.password_input.text()
        if ssid and password:
            try:
                # Użyj nmcli do połączenia z WiFi
                subprocess.run(["nmcli", "device", "wifi", "connect", ssid, "password", password], check=True)
                return True
            except subprocess.CalledProcessError:
                return False
        return False

class HackerOSApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("HackerOS Setup")
        self.showFullScreen()  # Pełnoekranowy tryb

        # Sprawdź połączenie internetowe przed wyświetleniem głównego interfejsu
        if not self.check_internet():
            if not self.show_network_config_dialog():
                self.close()
                return

        # Główny widget i układ
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        # Logo w lewym górnym rogu
        logo_label = QLabel(self)
        pixmap = QPixmap("/usr/share/HackerOS/ICONS/HackerOS.png")
        logo_label.setPixmap(pixmap.scaled(100, 100, Qt.AspectRatioMode.KeepAspectRatio))
        logo_label.setFixedSize(100, 100)
        logo_label.move(10, 10)  # Pozycja w lewym górnym rogu

        # Przyciski na środku
        buttons = [
            ("Chcę HackerOS do grania", "/usr/share/HackerOS/Setup/gamer.sh"),
            ("Chcę HackerOS do testów penetracyjnych", "/usr/share/HackerOS/Setup/penetration.sh"),
            ("Chcę system do programowania", "/usr/share/HackerOS/Setup/dev.sh"),
            ("Chcę system do zwykłego użytkowania", "/usr/share/HackerOS/Setup/normal.sh")
        ]

        for text, script_path in buttons:
            button = QPushButton(text)
            button.setFixedSize(400, 60)
            button.clicked.connect(lambda _, path=script_path: self.run_script_with_wait(path))
            layout.addWidget(button, alignment=Qt.AlignmentFlag.AlignCenter)

        # Przycisk "Pomiń" w prawym dolnym rogu
        skip_button = QPushButton("Pomiń", self)
        skip_button.setFixedSize(100, 40)
        skip_button.clicked.connect(lambda: self.run_script_with_wait("/usr/share/HackerOS/Setup/skip.sh"))
        skip_button.move(self.width() - 110, self.height() - 50)  # Pozycja w prawym dolnym rogu

        # Obsługa zmiany rozmiaru okna (dla przycisku "Pomiń")
        self.resizeEvent = self.on_resize

    def check_internet(self, host="8.8.8.8", port=53, timeout=3):
        try:
            socket.setdefaulttimeout(timeout)
            socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
            return True
        except socket.error:
            return False

    def show_network_config_dialog(self):
        dialog = NetworkConfigDialog(self)
        dialog.move(self.width() // 2 - dialog.width() // 2, self.height() // 2 - dialog.height() // 2)  # Wyśrodkowanie dialogu
        while True:
            if dialog.exec() == QDialog.DialogCode.Accepted:
                if dialog.configure_network():
                    if self.check_internet():
                        return True
                    else:
                        QMessageBox.warning(self, "Błąd", "Nie udało się połączyć z internetem. Spróbuj ponownie.")
                else:
                    QMessageBox.warning(self, "Błąd", "Konfiguracja sieci nie powiodła się. Spróbuj ponownie.")
            else:
                return False

    def run_script_with_wait(self, script_path):
        wait_dialog = QMessageBox(self)
        wait_dialog.setWindowTitle("Proszę czekać")
        wait_dialog.setText("Trwa wykonywanie skryptu...")
        wait_dialog.setStandardButtons(QMessageBox.StandardButton.NoButton)  # Brak przycisków, aby nie można było zamknąć
        wait_dialog.move(self.width() // 2 - wait_dialog.width() // 2, self.height() // 2 - wait_dialog.height() // 2)  # Wyśrodkowanie
        wait_dialog.show()
        QApplication.processEvents()  # Odśwież GUI

        try:
            subprocess.run([script_path], check=True)
            wait_dialog.close()
            self.close()  # Zamknij aplikację po wykonaniu skryptu
        except subprocess.CalledProcessError as e:
            wait_dialog.close()
            QMessageBox.critical(self, "Błąd", f"Błąd podczas uruchamiania skryptu {script_path}: {e}")

    def on_resize(self, event):
        # Ustawienie pozycji przycisku "Pomiń" przy zmianie rozmiaru okna
        skip_button = self.findChild(QPushButton, "Pomiń")
        if skip_button:
            skip_button.move(self.width() - 110, self.height() - 50)
        super().resizeEvent(event)

if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Ładowanie stylów z pliku .qss
    with open("style.qss", "r") as style_file:
        app.setStyleSheet(style_file.read())

    window = HackerOSApp()
    window.show()
    sys.exit(app.exec())
