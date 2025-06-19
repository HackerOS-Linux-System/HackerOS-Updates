sudo apt update && sudo apt install -y \
nmap zenmap whatweb arp-scan nikto wireshark tshark ettercap-graphical \
hydra john hashcat cewl crunch aircrack-ng wifite sqlmap commix \
python3 python3-pip git curl wget unzip default-jdk neo4j bloodhound

# Instalacja narzędzi Pythonowych
pip3 install theHarvester shodan sublist3r nuclei ffuf crackmapexec

# XSStrike
git clone https://github.com/s0md3v/XSStrike.git ~/XSStrike && \
cd ~/XSStrike && pip3 install -r requirements.txt && cd ~

# Metasploit Framework
curl https://raw.githubusercontent.com/rapid7/metasploit-framework/master/msfinstall | sudo bash

# Bettercap
sudo apt install bettercap

# Responder
git clone https://github.com/lgandx/Responder.git ~/Responder

# Empire
git clone https://github.com/BC-SECURITY/Empire.git ~/Empire && \
cd ~/Empire && ./setup/install.sh && cd ~

# OWASP ZAP (via snap)
sudo snap install zaproxy --classic

# Dirsearch
git clone https://github.com/maurosoria/dirsearch.git ~/dirsearch

# Gobuster
sudo apt install gobuster

# Burp Suite Community Edition (opcjonalnie via snap)
sudo snap install burpsuite --classic || echo "Możesz pobrać ręcznie ze strony PortSwigger."

# Amass
sudo snap install amass

snap install comix
