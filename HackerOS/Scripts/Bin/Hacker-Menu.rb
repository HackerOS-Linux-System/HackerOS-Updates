#!/usr/bin/env ruby
require 'tty-prompt'
require 'pastel'

prompt = TTY::Prompt.new
pastel = Pastel.new

system("clear")

puts pastel.green("
                                                 
                                               ░▒                                                   
                                            ░░░▒▒▒░░░                                               
                                          ░░▒▓▓▓▓▓▓▒░░░                                             
                                        ░░░▒▓▓▓▓▓▓▓▓▓▓░░░                                           
                                       ░░▒▒▓▓▓▓▒▓▓▓▓▓▓▓▒░▒                                          
                                      ▒░▒▓▓▓▒▓▒▓█▓▓▒▒▓▓▓▒░▒                                         
                                     ░░▒▓▓▒▓██▓░░▒▓██▓▓▓▓░░░                                        
                                    ▒░▓▓▓▓█▓▒░▒▓▓▓▓░▒▒█▓▓█░░                                        
                                   ░░░███▓░▒████████▓░░██▓▒░▒                                       
                                   ░▒███▒▓█████████████░▒███▒░                                      
                                  ░░▓██▒▓███████████████▓░██▓▒░                                     
                                 ░░▒██░███████████████████▒▓█▒░░                                    
                                 ░▒██▒█████████████████████▓███░                                    
                                 ░▒█▓▓█████████████████████▓▓██░                                    
                                 ░▒█▓▓█████████████████████▓▓██░                                    
                                ░░▒█▒▒█████████████████████▓▒██░░                                   
                             ░░░▒▓███▓▒███████████████████▓▒███▓▒░░░                                
                           ░░░▒▒▓█████▒▒▓████████████████▒▒▓███▓▓▒░░░░░                             
                        ░░░░▒▓▓▓▓▓▓▓████▒░▒▓██████████▓░▒█████▓▒▒▓▓▓▒▒░░░                           
                       ░░░▓▓██▓▒▒▒▒▒▒▓█████▒▒▒█████▓▒░▓████▓▓▒▒▒▒▒▓██▓▒░░░                          
                       ░▒▓█▓▓██▓█▒▒▒▒▒▓▓███▒██░▓█▓▒▒██▒██▓▒▒▒▒▒▓█▓██▓▓█▓▓░░                         
                      ░░▒█████████▓▒▒▒▒▒▒██▒███▓▓▒▓█▓▓░█▒▒▒▒▒▒▒█████▓██▓▓░░░                        
                    ░░░▒▓███████▓██▓▒▒▒▒▒▒▓░▒▒▒▒▒▒▒▒▒▒░▓▒▒▒▒▒▓█▓▓████████▒░░░                       
                   ░░▒█▓▓█████▓▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░▒▒░▒▒▒████▓▓▓▓▒░░                      
                  ░░░▓███▒████░▒▓▓▓▓▓▓▓▓▓▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░▓███▓▓██▓░░░░                    
                 ░▒▒▓▒▒▓█████▓░▓█████████████████████████████████▒░▓█████▓▒▒▒▒░░░                   
               ░░░▓██████████▓░▓█████████████████████████████████▓░▓█████████▓▒░░░                  
             ░░░▒▓███████████▓░▓█████████████████████████████████▓░▓███████████▓▒░░                 
             ░░▒▓████████████▓░▓█████████████████████████████████▓░▓██████████▓▓▒▒░░                
            ░▒▓██▓▓▓███████▓▒▓░▓█████████████████████████████████▓░▒▒▓███████▓▓▓██▓░░░              
           ░▒█████▓▒▓▓▓▓▓▒░░▒▒░▓█████████████████████████████████▓▒▒▒▒░▒▓▓▒▓▒▒▓█████░░              
           ▒▒█████████▓▓▒▒▒▒▒▒░▓█████████████████████████████████▓▒░▒▒▒▒▒▒▓████▓▓███░░              
            ▒█████████▓████▓▒▒░▓█████████████████████████████████▓▒░▒▓██████████████░░              
             ███████████████▓▓░▓█████████████████████████████████▓▒▓▓▓█████████████▒▒               
            ▒▓████████████████░▓█████████████████████████████████▓▒▓███████████████▓░░▒             
           ▓▓█▓██████████████▓░▓█████████████████████████████████▓▒▓████████████████▒▒▒             
             ▒▒▒▒▒▒▒▓▓▓██████▓░▒▒▒▓▒░▒▒░░░▒▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▓▓▓▓▒▒░▓████████▓▓▒▒▒▒▒▒▒▒▒              
                    ▒▒▒▒░░░░░ ██████████████████████████████████████                                
")

loop do
  wybor = prompt.select("\nWybierz opcję:", cycle: true) do |menu|

    menu.enum "🛠️  System:"
    menu.choice 'Zaktualizuj system', :update
    menu.choice 'Pokaż logi systemowe (hacker-syslogs)', :logs
    menu.choice 'Edytuj aliasy bash', :aliases

    menu.enum "🧩 Tryby instalacji:"
    menu.choice 'hacker-unpack', :unpack
    menu.choice 'hacker-unpack-gaming', :unpack_gaming
    menu.choice 'hacker-install-gamescope-steam', :install_gamescope
    menu.choice 'hacker-mode-install', :mode_install

    menu.enum "🌐 Internet i pomoc:"
    menu.choice 'Dokumentacja HackerOS', :docs
    menu.choice 'Napisz do nas', :contact

    menu.enum "📄 Informacje:"
    menu.choice 'Lista komend (hacker-commands)', :commands
    menu.choice 'Polityka prywatności', :privacy

    menu.choice '❌ Wyjście', :exit
  end

  case wybor
  when :update
    system("bash /usr/share/HackerOS/Bin/Hacker-Update.sh")
  when :logs
    system("hacker-syslogs")
  when :aliases
    system("nano /etc/bash.bashrc")
  when :unpack
    system("hacker-unpack")
  when :unpack_gaming
    system("hacker-unpack-gaming")
  when :install_gamescope
    system("hacker-install-gamescope-steam")
  when :mode_install
    system("hacker-mode-install")
  when :docs
    system("xdg-open https://hackeros.webnode.page/hackeros-documentation/")
  when :contact
    system("xdg-open https://hackeros.webnode.page/napisz-do-nas/")
  when :commands
    system("hacker-commands")
  when :privacy
    system("xdg-open https://hackeros.webnode.page/hackeros-privacy-policy/")
  when :exit
    puts pastel.cyan("\nDziekujemy za korzystanie z Hacker Menu :D\n\n")
    break
  end
end
