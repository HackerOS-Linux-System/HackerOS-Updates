const { ipcRenderer } = require('electron');
const { exec, execSync } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');

const logFile = '/tmp/hackeros.log';
const userHome = os.homedir();
const configDir = path.join(userHome, '.hackeros', 'penetration-mode');
const configFile = path.join(configDir, 'settings.json');
const vpnConfigFile = path.join(configDir, 'client.conf');

let settings = {
    interface: 'wlan0',
    vpnPath: vpnConfigFile,
    timeout: 60,
    theme: 'dark',
    logLevel: 'INFO'
};

let vpnActive = false;
let torActive = false;
let proxyActive = false;
let dnsSecure = false;
let currentNetworkType = '';
let lastLogMessage = '';

document.addEventListener('DOMContentLoaded', async () => {
    await initConfig();
    await loadSettings();
    applyTheme(settings.theme);

    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.add('hidden'));
            document.querySelector(`#${btn.dataset.tab}`).classList.remove('hidden');
        });
    });

    // Tool buttons
    document.querySelectorAll('.run-tool-btn').forEach(btn => {
        btn.addEventListener('click', () => runTool(btn.dataset.tool));
    });

    // Sidebar buttons
    document.getElementById('wifi-btn').addEventListener('click', () => openNetworkModal('Wi-Fi'));
    document.getElementById('bluetooth-btn').addEventListener('click', () => openNetworkModal('Bluetooth'));
    document.getElementById('vpn-btn').addEventListener('click', toggleVPN);
    document.getElementById('tor-btn').addEventListener('click', toggleTor);
    document.getElementById('anonymity-btn').addEventListener('click', toggleFullAnonymity);
    document.getElementById('settings-btn').addEventListener('click', openSettings);

    // Hacker Menu
    const hackerMenuBtn = document.getElementById('hacker-menu-btn');
    const hackerMenu = document.getElementById('hacker-menu');
    hackerMenuBtn.addEventListener('click', () => {
        hackerMenu.classList.toggle('hidden');
    });
    document.getElementById('shutdown-btn').addEventListener('click', () => systemCommand('poweroff'));
    document.getElementById('restart-btn').addEventListener('click', () => systemCommand('reboot'));
    document.getElementById('logout-btn').addEventListener('click', () => systemCommand('swaymsg exit'));

    // Settings modal
    document.getElementById('save-settings').addEventListener('click', saveSettings);
    document.getElementById('close-settings').addEventListener('click', () => {
        document.getElementById('settings-modal').classList.add('hidden');
    });
    document.getElementById('vpn-path-browse').addEventListener('click', async () => {
        const result = await ipcRenderer.invoke('open-file-dialog');
        if (result.filePaths[0]) {
            document.getElementById('vpn-path-input').value = result.filePaths[0];
        }
    });

    // Network modal
    document.getElementById('refresh-network').addEventListener('click', refreshNetworks);
    document.getElementById('connect-network').addEventListener('click', connectNetwork);
    document.getElementById('disconnect-network').addEventListener('click', disconnectNetwork);
    document.getElementById('close-network').addEventListener('click', () => {
        document.getElementById('network-modal').classList.add('hidden');
    });

    // Theme selector
    document.getElementById('theme-selector').addEventListener('change', (e) => {
        settings.theme = e.target.value;
        applyTheme(settings.theme);
        saveSettings();
    });

    // Learning content
    document.getElementById('learning-topic').addEventListener('change', updateLearningContent);

    // Monitoring
    document.getElementById('refresh-monitoring').addEventListener('click', updateSystemResources);

    // Anonymity check
    document.getElementById('check-anonymity').addEventListener('click', checkAnonymity);

    // Initial setup
    document.getElementById('tools').classList.remove('hidden');
    updateLearningContent();
    updateStatus();
    setInterval(updateStatus, 5000); // Debounced to 5 seconds
});

async function initConfig() {
    try {
        await fs.mkdir(configDir, { recursive: true });
        try {
            await fs.access(vpnConfigFile);
        } catch {
            const defaultVpnConfig = `
            client
            dev tun
            proto udp
            remote vpn.example.com 1194
            resolv-retry infinite
            nobind
            persist-key
            persist-tun
            remote-cert-tls server
            cipher AES-256-CBC
            auth SHA256
            verb 3
            <ca>
            # Add your CA certificate here
            </ca>
            <cert>
            # Add your client certificate here
            </cert>
            <key>
            # Add your client key here
            </key>
            `;
            await fs.writeFile(vpnConfigFile, defaultVpnConfig);
            await logOutput(`Created default VPN config at ${vpnConfigFile}`, 'INFO');
        }
    } catch (e) {
        await logOutput(`Error initializing config directory: ${e.message}`, 'ERROR');
    }
}

async function loadSettings() {
    try {
        await fs.access(configFile);
        const data = await fs.readFile(configFile, 'utf8');
        settings = JSON.parse(data);
        document.getElementById('interface-input').value = settings.interface;
        document.getElementById('vpn-path-input').value = settings.vpnPath;
        document.getElementById('timeout-input').value = settings.timeout;
        document.getElementById('theme-selector').value = settings.theme;
        document.getElementById('log-level').value = settings.logLevel;
    } catch (e) {
        await logOutput(`Error loading settings: ${e.message}`, 'WARNING');
        await saveSettings(); // Create default settings if not found
    }
}

async function saveSettings() {
    settings.interface = document.getElementById('interface-input').value;
    settings.vpnPath = document.getElementById('vpn-path-input').value || vpnConfigFile;
    settings.timeout = parseInt(document.getElementById('timeout-input').value) || 60;
    settings.logLevel = document.getElementById('log-level').value;
    try {
        await fs.writeFile(configFile, JSON.stringify(settings, null, 2));
        await logOutput('Settings saved.', 'INFO');
        document.getElementById('settings-modal').classList.add('hidden');
    } catch (e) {
        await logOutput(`Error saving settings: ${e.message}`, 'ERROR');
    }
}

function applyTheme(theme) {
    const themes = {
        dark: 'bg-gray-900 text-white',
        light: 'bg-gray-100 text-black',
        'hacker-green': 'bg-green-900 text-green-400'
    };
    document.body.className = `${themes[theme] || themes.dark} font-mono`;
}

async function logOutput(message, level = 'INFO') {
    if (['ERROR', 'WARNING'].includes(settings.logLevel) && level === 'INFO') return;
    if (settings.logLevel === 'ERROR' && level !== 'ERROR') return;
    const logMessage = `${new Date().toLocaleString()}: ${level}: ${message}`;
    if (logMessage === lastLogMessage) return; // Prevent duplicates
    lastLogMessage = logMessage;
    try {
        await fs.appendFile(logFile, `${logMessage}\n`);
        const output = document.getElementById('output');
        output.innerHTML += `<p class="${level === 'ERROR' ? 'text-red-500' : 'text-gray-300'}">${logMessage}</p>`;
        output.scrollTop = output.scrollHeight;
        const logs = document.getElementById('logs-content');
        logs.innerHTML += `<p class="${level === 'ERROR' ? 'text-red-500' : 'text-gray-300'}">${logMessage}</p>`;
        logs.scrollTop = logs.scrollHeight;
    } catch (e) {
        console.error(`Failed to write to log file: ${e.message}`);
    }
}

async function checkToolInstalled(tool) {
    const packageMap = {
        metasploit: 'metasploit-framework',
        burpsuite: 'burpsuite',
        nikto: 'nikto',
        hashcat: 'hashcat',
        john: 'john',
        masscan: 'masscan',
        nmap: 'nmap',
        'aircrack-ng': 'aircrack-ng',
        hydra: 'hydra',
        sqlmap: 'sqlmap',
        wireshark: 'wireshark',
        tor: 'tor'
    };
    try {
        execSync(`which ${tool}`, { stdio: 'ignore' });
        return true;
    } catch {
        await logOutput(`${tool} not found, attempting to install...`, 'WARNING');
        try {
            const package = packageMap[tool] || tool;
            execSync(`pkexec apt-get install -y ${package}`, { stdio: 'ignore' });
            await logOutput(`${tool} installed successfully.`, 'INFO');
            return true;
        } catch (installError) {
            await logOutput(`Failed to install ${tool}: ${installError.message}`, 'ERROR');
            return false;
        }
    }
}

async function runTool(tool) {
    const input = document.querySelector(`input[data-tool="${tool}"]`).value;
    if (!validateInput(input)) {
        await logOutput(`Invalid parameters for ${tool}.`, 'ERROR');
        return;
    }
    if (!(await checkToolInstalled(tool))) {
        await logOutput(`Cannot run ${tool}: installation failed.`, 'ERROR');
        return;
    }
    showProgress(true);
    exec(`${tool} ${input}`, { timeout: settings.timeout * 1000 }, async (error, stdout, stderr) => {
        showProgress(false);
        if (error) {
            await logOutput(`Error running ${tool}: ${stderr || error.message}`, 'ERROR');
        } else {
            await logOutput(`${tool} output: ${stdout}`, 'INFO');
        }
    });
}

function validateInput(params) {
    const dangerous = ['rm -rf', 'dd', 'mkfs', ':(){ :|:& };:', 'chmod -R', 'chown -R', 'kill -9', 'reboot', 'shutdown', ';', '|', '&', '>', '<'];
    return !dangerous.some(d => params.toLowerCase().includes(d));
}

function openSettings() {
    document.getElementById('settings-modal').classList.remove('hidden');
}

function openNetworkModal(type) {
    currentNetworkType = type;
    document.getElementById('network-title').textContent = `Manage ${type}`;
    document.getElementById('network-modal').classList.remove('hidden');
    refreshNetworks();
}

function refreshNetworks() {
    const list = document.getElementById('network-list');
    list.innerHTML = '';
    const command = currentNetworkType === 'Wi-Fi' ? 'nmcli -t -f SSID,ACTIVE,SIGNAL dev wifi' : 'bluetoothctl devices';
    exec(command, async (error, stdout) => {
        if (error) {
            await logOutput(`Error refreshing ${currentNetworkType}: ${error.message}`, 'ERROR');
            return;
        }
        const lines = stdout.split('\n').filter(line => line);
        lines.forEach(line => {
            const div = document.createElement('div');
            div.className = 'flex justify-between p-2 bg-gray-700 rounded cursor-pointer hover:bg-gray-600';
            if (currentNetworkType === 'Wi-Fi') {
                const [ssid, active, signal] = line.split(':');
                div.innerHTML = `<span>${ssid}</span><span>${active === 'yes' ? 'Active' : 'Inactive'} | ${signal}%</span>`;
            } else {
                const parts = line.split(' ');
                const name = parts.slice(2).join(' ');
                div.innerHTML = `<span>${name}</span><span>Unknown</span>`;
            }
            div.addEventListener('click', () => {
                list.querySelectorAll('div').forEach(d => d.classList.remove('bg-blue-500'));
                div.classList.add('bg-blue-500');
            });
            list.appendChild(div);
        });
    });
}

function connectNetwork() {
    const selected = document.querySelector('#network-list .bg-blue-500');
    if (!selected) {
        alert('Select a network or device!');
        return;
    }
    const target = selected.querySelector('span').textContent;
    if (currentNetworkType === 'Wi-Fi') {
        const password = prompt(`Enter password for ${target}:`);
        if (!password) return;
        exec(`pkexec nmcli dev wifi connect "${target}" password "${password}"`, { timeout: 30000 }, async (error) => {
            if (error) {
                await logOutput(`Connection error for ${target}: ${error.message}`, 'ERROR');
            } else {
                await logOutput(`Connected to ${target}.`, 'INFO');
            }
        });
    } else {
        exec(`pkexec bluetoothctl connect "${target}"`, { timeout: 30000 }, async (error) => {
            if (error) {
                await logOutput(`Connection error for ${target}: ${error.message}`, 'ERROR');
            } else {
                await logOutput(`Connected to ${target}.`, 'INFO');
            }
        });
    }
}

function disconnectNetwork() {
    const selected = document.querySelector('#network-list .bg-blue-500');
    if (!selected) {
        alert('Select a network or device!');
        return;
    }
    const target = selected.querySelector('span').textContent;
    const command = currentNetworkType === 'Wi-Fi' ? `pkexec nmcli con down "${target}"` : `pkexec bluetoothctl disconnect "${target}"`;
    exec(command, { timeout: 30000 }, async (error) => {
        if (error) {
            await logOutput(`Disconnection error for ${target}: ${error.message}`, 'ERROR');
        } else {
            await logOutput(`Disconnected from ${target}.`, 'INFO');
        }
    });
}

async function toggleVPN() {
    try {
        await fs.access(settings.vpnPath);
    } catch {
        await logOutput(`VPN file ${settings.vpnPath} does not exist. Using default config.`, 'WARNING');
        settings.vpnPath = vpnConfigFile;
        document.getElementById('vpn-path-input').value = settings.vpnPath;
        await saveSettings();
    }
    if (!vpnActive) {
        exec(`pkexec openvpn --config ${settings.vpnPath} --daemon`, async (error) => {
            if (error) {
                await logOutput(`Failed to activate VPN: ${error.message}`, 'ERROR');
            } else {
                await logOutput('VPN activated.', 'INFO');
                vpnActive = true;
            }
            updateStatus();
        });
    } else {
        exec('pkexec pkill openvpn', { timeout: 30000 }, async (error) => {
            if (error) {
                await logOutput(`Failed to deactivate VPN: ${error.message}`, 'ERROR');
            } else {
                await logOutput('VPN deactivated.', 'INFO');
                vpnActive = false;
            }
            updateStatus();
        });
    }
}

async function toggleTor() {
    if (!(await checkToolInstalled('tor'))) {
        await logOutput('Cannot toggle Tor: installation failed.', 'ERROR');
        return;
    }
    const command = torActive ? 'pkexec systemctl stop tor' : 'pkexec systemctl start tor';
    exec(command, { timeout: 30000 }, async (error) => {
        if (error) {
            await logOutput(`Failed to ${torActive ? 'stop' : 'start'} Tor: ${error.message}`, 'ERROR');
        } else {
            await logOutput(`Tor ${torActive ? 'deactivated' : 'activated'}.`, 'INFO');
            torActive = !torActive;
        }
        updateStatus();
    });
}

async function toggleProxy() {
    const proxy = settings.proxy || 'http://localhost:8080';
    if (!proxyActive) {
        process.env.http_proxy = proxy;
        process.env.https_proxy = proxy;
        await logOutput(`Proxy activated: ${proxy}`, 'INFO');
        proxyActive = true;
    } else {
        delete process.env.http_proxy;
        delete process.env.https_proxy;
        await logOutput('Proxy deactivated.', 'INFO');
        proxyActive = false;
    }
    updateStatus();
}

async function toggleDNS() {
    const dnsServers = (settings.dnsServers || '8.8.8.8,8.8.4.4').split(',');
    if (!dnsSecure) {
        const dnsContent = dnsServers.map(server => `nameserver ${server.trim()}`).join('\n');
        try {
            await fs.writeFile('/tmp/resolv.conf', dnsContent);
            exec('pkexec mv /tmp/resolv.conf /etc/resolv.conf', async (error) => {
                if (error) {
                    await logOutput(`Failed to modify DNS: ${error.message}`, 'ERROR');
                } else {
                    await logOutput(`DNS secured: ${dnsServers.join(', ')}`, 'INFO');
                    dnsSecure = true;
                }
                updateStatus();
            });
        } catch (e) {
            await logOutput(`DNS error: ${e.message}`, 'ERROR');
        }
    } else {
        try {
            await fs.writeFile('/tmp/resolv.conf', 'nameserver 127.0.0.1\n');
            exec('pkexec mv /tmp/resolv.conf /etc/resolv.conf', async (error) => {
                if (error) {
                    await logOutput(`Failed to reset DNS: ${error.message}`, 'ERROR');
                } else {
                    await logOutput('DNS reset to default.', 'INFO');
                    dnsSecure = false;
                }
                updateStatus();
            });
        } catch (e) {
            await logOutput(`DNS error: ${e.message}`, 'ERROR');
        }
    }
}

async function toggleFullAnonymity() {
    if (!vpnActive || !torActive || !proxyActive || !dnsSecure) {
        await Promise.all([toggleVPN(), toggleTor(), toggleProxy(), toggleDNS()]);
        await logOutput('Full Anonymity mode enabled.', 'INFO');
    } else {
        await Promise.all([toggleVPN(), toggleTor(), toggleProxy(), toggleDNS()]);
        await logOutput('Full Anonymity mode disabled.', 'INFO');
    }
}

function systemCommand(command) {
    exec(`pkexec ${command}`, { timeout: 10000 }, async (error) => {
        if (error) {
            await logOutput(`Failed to execute ${command}: ${error.message}`, 'ERROR');
        } else {
            await logOutput(`${command} executed.`, 'INFO');
        }
    });
}

function updateLearningContent() {
    const topic = document.getElementById('learning-topic').value;
    const content = {
        basics: {
            title: 'Penetration Testing Basics',
            text: `
            <h3>Introduction</h3>
            <p>Penetration testing (pentesting) is a simulated cyberattack to identify and exploit vulnerabilities in systems, networks, or applications. It helps organizations strengthen their security.</p>
            <h3>Key Phases</h3>
            <ul class="list-disc pl-6">
            <li><strong>Reconnaissance</strong>: Gather information about the target using tools like Nmap or OSINT techniques.</li>
            <li><strong>Scanning</strong>: Identify open ports, services, and vulnerabilities with tools like Nmap or Nikto.</li>
            <li><strong>Exploitation</strong>: Exploit vulnerabilities using Metasploit or Sqlmap to gain access.</li>
            <li><strong>Post-Exploitation</strong>: Escalate privileges, maintain access, and extract data.</li>
            <li><strong>Reporting</strong>: Document findings with recommendations for mitigation.</li>
            </ul>
            <h3>Legal Considerations</h3>
            <p>Always obtain explicit written permission before pentesting. Unauthorized testing is illegal and can lead to legal consequences. Use tools responsibly.</p>
            <h3>Best Practices</h3>
            <ul class="list-disc pl-6">
            <li>Define the scope of the test clearly.</li>
            <li>Use anonymization tools (VPN, Tor) to protect your identity.</li>
            <li>Log all actions for transparency and accountability.</li>
            </ul>
            `
        },
        scanning: {
            title: 'Network Scanning',
            text: `
            <h3>Overview</h3>
            <p>Network scanning discovers active hosts, open ports, and services. Nmap and Masscan are essential tools for this phase.</p>
            <h3>Using Nmap</h3>
            <p>Nmap is a powerful tool for network discovery and vulnerability scanning:</p>
            <ul class="list-disc pl-6">
            <li><code>nmap -sP 192.168.1.0/24</code>: Ping scan to find active hosts.</li>
            <li><code>nmap -sS -p1-65535 192.168.1.1</code>: Stealth SYN scan for all ports.</li>
            <li><code>nmap -sV -O 192.168.1.1</code>: Detect service versions and OS.</li>
            <li><code>nmap --script vuln 192.168.1.1</code>: Run vulnerability scripts.</li>
            </ul>
            <h3>Using Masscan</h3>
            <p>Masscan is designed for high-speed port scanning:</p>
            <ul class="list-disc pl-6">
            <li><code>masscan 192.168.1.0/24 -p1-65535 --rate=1000</code>: Scan all ports at high speed.</li>
            <li><code>masscan -iL targets.txt --open</code>: Scan targets from a file, show open ports.</li>
            </ul>
            <h3>Tips</h3>
            <p>Use <code>--reason</code> with Nmap for detailed output. Save results with <code>-oX output.xml</code> for analysis in other tools.</p>
            `
        },
        exploits: {
            title: 'Exploits and Payloads',
            text: `
            <h3>Overview</h3>
            <p>Exploits target vulnerabilities to gain unauthorized access. Metasploit and Sqlmap are widely used for this phase.</p>
            <h3>Using Metasploit</h3>
            <p>Metasploit is a comprehensive framework for exploit development:</p>
            <ul class="list-disc pl-6">
            <li><code>msfconsole</code>: Launch the console.</li>
            <li><code>use exploit/windows/smb/ms17_010_eternalblue</code>: Select an exploit.</li>
            <li><code>set RHOSTS 192.168.1.1</code>: Set target IP(s).</li>
            <li><code>set PAYLOAD windows/meterpreter/reverse_tcp</code>: Choose a payload.</li>
            <li><code>exploit</code>: Run the exploit.</li>
            </ul>
            <h3>Using Sqlmap</h3>
            <p>Sqlmap automates SQL injection attacks:</p>
            <ul class="list-disc pl-6">
            <li><code>sqlmap -u http://example.com --dbs</code>: Enumerate databases.</li>
            <li><code>sqlmap -u http://example.com -D dbname --tables</code>: List tables in a database.</li>
            <li><code>sqlmap -u http://example.com --dump</code>: Dump database contents.</li>
            </ul>
            <h3>Tips</h3>
            <p>Always verify exploits in a controlled environment first. Use Metasploit's <code>search</code> command to find relevant exploits.</p>
            `
        },
        wireless: {
            title: 'Wireless Attacks',
            text: `
            <h3>Overview</h3>
            <p>Wireless attacks target Wi-Fi networks to gain access or capture data. Aircrack-ng is a key toolset.</p>
            <h3>Using Aircrack-ng</h3>
            <p>Steps for cracking Wi-Fi passwords:</p>
            <ul class="list-disc pl-6">
            <li><code>airmon-ng start wlan0</code>: Enable monitor mode.</li>
            <li><code>airodump-ng wlan0mon</code>: Discover nearby networks.</li>
            <li><code>airodump-ng -c <channel> --bssid <BSSID> -w capture wlan0mon</code>: Capture packets for a specific network.</li>
            <li><code>aircrack-ng -b <BSSID> capture.cap</code>: Crack the password.</li>
            </ul>
            <h3>Tips</h3>
            <p>Ensure your Wi-Fi adapter supports monitor mode (e.g., Atheros AR9271). Use <code>aireplay-ng</code> to deauthenticate clients and speed up packet capture.</p>
            `
        },
        passwords: {
            title: 'Password Cracking',
            text: `
            <h3>Overview</h3>
            <p>Password cracking recovers passwords from hashes or services. Hydra, Hashcat, and John are powerful tools.</p>
            <h3>Using Hydra</h3>
            <p>Hydra performs brute-force attacks on protocols:</p>
            <ul class="list-disc pl-6">
            <li><code>hydra -l user -P passlist.txt ssh://192.168.1.1</code>: Attack SSH with a wordlist.</li>
            <li><code>hydra -L userlist.txt -p pass ftp://192.168.1.1</code>: Attack FTP with a user list.</li>
            </ul>
            <h3>Using Hashcat</h3>
            <p>Hashcat cracks hashes using GPU acceleration:</p>
            <ul class="list-disc pl-6">
            <li><code>hashcat -m 0 hash.txt wordlist.txt</code>: Crack MD5 hashes.</li>
            <li><code>hashcat -m 1800 hash.txt -a 3 ?a?a?a?a</code>: Brute-force SHA-512 hashes.</li>
            </ul>
            <h3>Using John</h3>
            <p>John cracks password hashes:</p>
            <ul class="list-disc pl-6">
            <li><code>john hash.txt</code>: Crack hashes in a file.</li>
            <li><code>john --show hash.txt</code>: Display cracked passwords.</li>
            </ul>
            <h3>Tips</h3>
            <p>Use a strong wordlist (e.g., rockyou.txt). Combine tools for hybrid attacks (e.g., Hashcat with rules).</p>
            `
        },
        web: {
            title: 'Web Application Testing',
            text: `
            <h3>Overview</h3>
            <p>Web application testing identifies vulnerabilities in web servers and applications. Burp Suite and Nikto are key tools.</p>
            <h3>Using Burp Suite</h3>
            <p>Burp Suite is a comprehensive web testing tool:</p>
            <ul class="list-disc pl-6">
            <li><code>burpsuite</code>: Launch the GUI.</li>
            <li>Configure your browser to use Burp as a proxy (e.g., 127.0.0.1:8080).</li>
            <li>Use the Spider or Crawler to map the application.</li>
            <li>Use Intruder for automated attacks (e.g., brute-forcing forms).</li>
            </ul>
            <h3>Using Nikto</h3>
            <p>Nikto scans web servers for vulnerabilities:</p>
            <ul class="list-disc pl-6">
            <li><code>nikto -h http://example.com</code>: Scan a web server.</li>
            <li><code>nikto -h https://example.com -ssl</code>: Scan an HTTPS server.</li>
            </ul>
            <h3>Tips</h3>
            <p>Use Burp's Repeater to manually test requests. Combine Nikto with Nmap for comprehensive scanning.</p>
            `
        },
        anonymity: {
            title: 'Anonymity and Privacy',
            text: `
            <h3>Overview</h3>
            <p>Anonymity protects your identity during testing. Tools like Tor, VPNs, and proxies are essential.</p>
            <h3>Using Tor</h3>
            <p>Tor routes traffic through multiple nodes for anonymity:</p>
            <ul class="list-disc pl-6">
            <li><code>systemctl start tor</code>: Start the Tor service.</li>
            <li><code>proxychains nmap 192.168.1.1</code>: Route tool traffic through Tor.</li>
            </ul>
            <h3>Using VPN</h3>
            <p>VPNs encrypt traffic to a remote server:</p>
            <ul class="list-disc pl-6">
            <li><code>openvpn --config client.conf</code>: Connect to a VPN.</li>
            <li>Edit ${vpnConfigFile} with your provider's credentials.</li>
            </ul>
            <h3>Tips</h3>
            <p>Combine Tor, VPN, and secure DNS for maximum anonymity. Regularly check your IP using the Anonymity tab.</p>
            `
        },
        monitoring: {
            title: 'Network Monitoring',
            text: `
            <h3>Overview</h3>
            <p>Monitoring analyzes network traffic and system resources. Wireshark and Htop are essential tools.</p>
            <h3>Using Wireshark</h3>
            <p>Wireshark captures and analyzes network packets:</p>
            <ul class="list-disc pl-6">
            <li><code>wireshark</code>: Launch the GUI.</li>
            <li><code>tshark -i eth0 -f "tcp port 80"</code>: Capture HTTP traffic from CLI.</li>
            </ul>
            <h3>Using Htop</h3>
            <p>Htop provides an interactive system resource monitor:</p>
            <ul class="list-disc pl-6">
            <li><code>htop</code>: Start the monitor.</li>
            <li>Use arrow keys to navigate and F9 to kill processes.</li>
            </ul>
            <h3>Tips</h3>
            <p>Use Wireshark filters (e.g., <code>http.request</code>) to focus on specific traffic. Monitor CPU usage with Htop during heavy scans.</p>
            `
        }
    };
    document.getElementById('learning-title').textContent = content[topic].title;
    document.getElementById('learning-text').innerHTML = content[topic].text;
}

function updateSystemResources() {
    exec('top -bn1 | head -n3', async (error, stdout) => {
        if (error) {
            await logOutput(`Resource monitoring error: ${error.message}`, 'ERROR');
            return;
        }
        const cpu = stdout.match(/%Cpu\(s\):.*?(\d+\.\d)/)?.[1] || 'N/A';
        exec('free -h | grep Mem', async (error, stdout) => {
            if (error) {
                await logOutput(`Resource monitoring error: ${error.message}`, 'ERROR');
                return;
            }
            const ram = stdout.split(/\s+/)[2] || 'N/A';
            exec('df -h / | tail -n1', async (error, stdout) => {
                if (error) {
                    await logOutput(`Resource monitoring error: ${error.message}`, 'ERROR');
                    return;
                }
                const disk = stdout.split(/\s+/)[3] || 'N/A';
                document.getElementById('resource-info').textContent = `CPU: ${cpu}% | RAM: ${ram} | Disk: ${disk}`;
            });
        });
    });
}

function checkAnonymity() {
    fetch('https://api.ipify.org?format=json')
    .then(res => res.json())
    .then(async data => {
        document.getElementById('ip-info').textContent = `IP: ${data.ip}`;
        try {
            const res = await fetch(`http://ipinfo.io/${data.ip}/json`);
            const details = await res.json();
            const report = [
                `IP: ${data.ip}`,
                `Location: ${details.city || 'Unknown'}, ${details.region || 'Unknown'}, ${details.country || 'Unknown'}`,
                `ISP: ${details.org || 'Unknown'}`
            ];
            document.getElementById('anonymity-report').textContent = report.join('\n');
            await logOutput(`Anonymity Report:\n${'-'.repeat(20)}\n${report.join('\n')}\n${'-'.repeat(20)}`, 'INFO');
        } catch (e) {
            await logOutput(`IP info error: ${e.message}`, 'ERROR');
        }
    })
    .catch(async e => await logOutput(`IP check error: ${e.message}`, 'ERROR'));
}

function showProgress(show) {
    const progressBar = document.getElementById('progress-bar');
    progressBar.classList.toggle('hidden', !show);
    if (show) {
        let progress = 0;
        const interval = setInterval(() => {
            progress += 10;
            if (progress > 100) progress = 0;
            document.getElementById('progress-fill').style.width = `${progress}%`;
        }, 500);
        progressBar.dataset.interval = interval;
    } else {
        clearInterval(progressBar.dataset.interval);
        document.getElementById('progress-fill').style.width = '0%';
    }
}

function updateStatus() {
    const components = [];
    if (vpnActive) components.push('VPN');
    if (torActive) components.push('Tor');
    if (proxyActive) components.push('Proxy');
    if (dnsSecure) components.push('DNS');
    const status = `Penetration Mode Active | Anonymity: ${components.length ? components.join(' + ') : 'Off'}`;
    logOutput(status, 'INFO');
}
