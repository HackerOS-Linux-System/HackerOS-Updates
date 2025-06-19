# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "${PS1-}" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(< /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
# but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
if ! [ -n "${SUDO_USER-}" -a -n "${SUDO_PS1-}" ]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# sudo hint
if [ ! -e "$HOME/.sudo_as_admin_successful" ] && [ ! -e "$HOME/.hushlogin" ] ; then
    case " $(groups) " in *\ admin\ *|*\ sudo\ *)
    if [ -x /usr/bin/sudo ]; then
	cat <<-EOF
	To run a command as administrator (user "root"), use "sudo <command>".
	See "man sudo_root" for details.

	EOF
    fi
    esac
fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi


echo -ne "🔐 Loading terminal"
for i in {1..3}; do echo -ne "."; sleep 0.2; done
clear



# HackerOS-Welcome
cat << "EOF"
┌───[ H A C K E R O S ]──────────────────────────────────────────────┐
│                                                                    │
│ ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗  ██████╗ ███████╗  │
│ ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗██╔═══██╗██╔════╝  │
│ ███████║███████║██║     █████╔╝ █████╗  ██████╔╝██║   ██║███████╗  │
│ ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗██║   ██║╚════██║  │
│ ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║╚██████╔╝███████║  │
│ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝  │
│                                                                    │
└───[ SYSTEM READY ]─────────────────────────────────────────────────┘

       ══════════════════════════════════════════════════
       ║      W E L C O M E   T O   H A C K E R O S     ║
       ║                   v2.2                         ║
       ══════════════════════════════════════════════════

┗┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┛
> Secure, fast, game-ready. Updates done. You decide.
> Welcome aboard, operator — HackerOS Team
┗┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┛

[ NETWORK LINKS ]
┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅
Website:  https://hackeros.webnode.page
Discord:  https://discord.gg/8yHNcBaEKy
X:        https://x.com/hackeros_linux
GitHub:   https://github.com/HackerOS-Linux-System/
Reddit:   https://www.reddit.com/r/HackerOS/
┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅

[ SYSTEM COMMANDS ]
┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅
Command                    | Description
---------------------------+----------------------------------------
hacker-unpack             | Installs tools for gaming, cybersecurity, add-ons, and development
hacker-commands           | Displays list of available commands
hacker-update             | Updates the system
hacker-addons             | Installs various add-ons
hacker-devtools           | Installs development tools
hacker-unpack-gaming      | Installs gaming tools
┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅
EOF



#Custom-Commands



#hacker-update
alias hacker-update="/usr/share/HackerOS/Scripts/Bin/Hacker-Update.sh"


#hacker-unpack
alias hacker-unpack="hacker-update && hacker-unpack-cybersecurity && hacker-unpack-gaming && hacker-devtools && hacker-add-ons"

alias hacker-unpack-cybersecurity="hacker-update && echo ========== Penetration Tools Install ========== && sudo apt install nmap wireshark nikto john hydra aircrack-ng sqlmap ettercap-text-only tcpdump zmap bettercap wfuzz hashcat fail2ban rkhunter chkrootkit lynis clamav tor proxychains4 httrack sublist3r macchanger inxi htop openvas openvpn && echo ========== Install Metasploit Framework ========== && sudo snap install metasploit-framework && echo ========== Install Ghidra ========== && flatpak install flathub org.ghidra_sre.Ghidra && echo ========== Hacker-Unpack-Cybersecurity Compl3te =========="

alias hacker-unpack-gaming="hacker-update && echo ========== Install OBS STUDIO LUTRIS and STEAM ========== && sudo apt install obs-studio lutris steam && echo ========== Install Heroic Games Launcher ProtonTricks and Discord ========== && flatpak install flathub net.davidotek.pupgui2 && flatpak install heroicgameslauncher protontricks discord && echo ========== Install Roblox ========== && flatpak install --user https://sober.vinegarhq.org/sober.flatpakref && echo ========== Install Roblox Studio ========== flatpak install flathub org.vinegarhq.Vinegar && echo ========== Hacker-Unpack-Gaming Complete =========="

alias hacker-unpack-gaming-noroblox="hacker-update && echo ========== Install OBS STUDIO LUTRIS and STEAM ========== && sudo apt install obs-studio lutris steam && echo ========== Install Heroic Games Launcher ProtonTricks and Discord ========== && flatpak install flathub net.davidotek.pupgui2 && flatpak install heroicgameslauncher protontricks discord && echo ========== Hacker-Unpack-Gaming-NoRoblox Complete =========="

alias hacker-unpack-emulators="hacker-update && echo ========== Install PlayStation Emulator ========== flatpak install shadPS4 && echo ========== Install Emulator Nintendo ========== && flatpak install flathub io.github.ryubing.Ryujinx && echo ========== Install DOSBOX ========== && flatpak install flathub com.dosbox_x.DOSBox-X && echo ========== Install PlayStation 3 Emulator ========== && sudo snap install rpcs3-emu && echo ========== Hacker-Unpack-Emulators Complete =========="

alias hacker-mode-install="echo Updating System && flatpak install flathub com.valvesoftware.Steam && flatpak install heroicgameslauncher && sudo apt install lutrs"


#Hacker-SysLogs
alias hacker-syslog="echo ========== System Logs ========== && sudo journalctl -xe"

#Hacker/Apt
alias zypper='sudo apt'
alias yum='sudo apt'
alias dnf='sudo apt'
alias hacker='sudo apt'
alias fhacker='flatpak'
alias shacker='sudo snap'


#Hacker-retro-term
alias hacker-retro-term="hacker-update && echo ========== Install Cool Retro Term ========== && sudo apt install cool-retro-term && echo ========== Installation Cool Retro Term Complete =========="

#Lista Komend
alias hacker-commands="echo ========== Commands List ==========  hacker-update hacker-unpack hacker-unpack-cybersecurity hacker-unpack-gaming hacker-unpack-gaming-noroblox hacker-syslogs hacker-unpack-emulators hacker-retro-term remove-calamares && echo ========== Instead of the sudo apt command you can use hacker =========="

#Hacker-DevTools
alias hacker-devtools="hacker-update && echo ========== Install Atom ========== && flatpak install flathub io.atom.Atom && echo ========== Install Dev Tools Complete =========="

#Hacker-AddOns
alias hacker-add-ons="hacker-update && echo ========== Install Wine ========== && sudo apt install wine winetricks && echo ========== Install BoxBuddy and Winezgui ========== && flatpak install flathub io.github.dvlv.boxbuddyrs && flatpak install winezgui && flatpak install flathub it.mijorus.gearlever && echo ========== Install Add-Ons Complete =========="

#hacker-nvidia-dkms
alias nvidia-dkms-560="hacker-update && sudo apt install nvidia-dkms-560"

#hacker-unpack-g-s
alias hacker-unpack-g-s="hacker-update && hacker-unpack-gaming && hacker-unpack-cybersecurity"

#neofetch
alias fastfetch="neofetch"

#Star-HackerOS-Cockpit
alias start-hackeros-cockpit="python3 /usr/share/HackerOS/Scripts/HackerOS-Apps/HackerOS-Cockpit/HackerOS_Cockpit.py"

# 🔥 Dark Mode dla Basha w Alacritty
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32"

# 🔥 Ustawienia kolorów dla terminala
export PS1="\[\e[1;37m\]\u@\h:\[\e[1;34m\]\w\[\e[0m\]$ "

# 🎨 Funkcja do wyświetlania kolorowych klikalnych linków
function link() {
    local text="$1"
    local url="$2"
    echo -e "\e[1;31m\e]8;;$url\a$text\e]8;;\a\e[0m"
}

# 🌍 Funkcja do otwierania linków w domyślnej przeglądarce
function openlink() {
    local url="$1"
    if command -v xdg-open >/dev/null; then
        xdg-open "$url" >/dev/null 2>&1 &
    elif command -v gnome-open >/dev/null; then
        gnome-open "$url" >/dev/null 2>&1 &
    elif command -v open >/dev/null; then
        open "$url" >/dev/null 2>&1 &  # macOS
    else
        echo "❌ Nie można otworzyć linku: $url"
    fi
}


# Kolory dla ls
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'

# Emoji + git
alias gs='echo 🌀 && git status'
alias gc='echo 📦 && git commit -m'
alias gp='echo ⬆️ && git push'

# Kolorowe PS1 (jeśli nie używasz Starship)
PS1='\[\e[1;32m\]\u@\h \[\e[1;34m\]\w \[\e[0;33m\]$\[\e[0m\] '
