require "Pathname"
require 'fileutils'

class Utility
    def self.printBlue(text)
        puts "\033[34m#{text}\033[0m"
    end
    def self.printSection(title)
        len = 70
        Utility.printBlue "#" * len
        Utility.printBlue "##{" " * (len-2)}#"
        blank = " " * ((len - 2 - title.length)/2)
        Utility.printBlue "##{blank}#{title}#{blank}#"
        Utility.printBlue "##{" " * (len-2)}#"
        Utility.printBlue "#" * len
    end

    def self.download(url, target_path, name) 
        puts "downloading `#{name}`"
        system "curl -L -o #{target_path+name} #{url}"
    end

    def self.isInstalled(command)
        `which #{command}`.length > 0
    end

    def self.working_path 
        (Pathname.new __FILE__).parent
    end
end

class Shell
    # attr_accessor : commands
    @password
    def self.password() 
        return @password unless @password.nil?
        content = `read -s -p "Password: " password; echo $password;`
        puts ""
        @password = content
        return @password
    end
end

def SECTION(title)
    Utility.printSection title
end

Shell.password


# -------------- INSTALL APPS ---------------

SECTION "Installing Apps"

def install_pkg(file) 
    system <<-eof
    echo "#{Shell.password}" | sudo -S installer -allowUntrusted -pkg '#{file}' -target /   
    echo "downloaded installation script"
    # open the security panel to allow opening app
    open -b com.apple.systempreferences  /System/Library/PreferencePanes/Security.prefPane 
    eof
end    

def install_apps() 
    app_folder = Utility.working_path + "Data/Apps"
    Utility.download("https://iterm2.com/downloads/stable/iTerm2-3_1_6.zip", app_folder, "iTerm.zip")
    Utility.download("https://vscode.cdn.azure.cn/stable/24f62626b222e9a8313213fb64b10d741a326288/VSCode-darwin-stable.zip", app_folder,  "VSCode.zip")
    app_folder.find do |path|
        next if path.directory?
        if path.to_s.end_with? ".pkg"
            path_str = path.to_s.gsub(/ /, '\ ')
            install_pkg(path_str)
        elsif path.to_s.end_with? ".zip"
            target_path = Utility.working_path + "Done" 
            path_str = path.to_s.gsub(/ /, '\ ')
            puts "install: #{path.basename(".zip")}"
            `unzip -q -o #{path_str} -d #{target_path}/ -x __MACOSX/*`
        end
    end
end

install_apps

# -------------- install shell tools ---------------

SECTION "intall brew"
def install_brew 
    system <<-eof
    script=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)
    echo "downloaded installation script"
    echo "#{Shell.password}" | sudo -S echo; 
    yes '' | /usr/bin/ruby -e "$script"
    eof
end
if not Utility.isInstalled "brew"
    install_brew
else
    puts "brew is installed."
end

SECTION "install oh-my-zsh"
def install_oh_my_zsh
    path = Utility.working_path + "Data/scripts/install_oh_my_zsh.sh"
    path = path.to_s.gsub(/ /, '\ ')
    system "sh #{path} #{Shell.password} "
end
install_oh_my_zsh


# -------------- SET UP ENVIRONMENT ---------------

SECTION "set up configs"
def set_up_configs
    
    puts ".zshrc"
    FileUtils.cp Utility.working_path + "Data/configs/.zshrc", "#{Dir.home}/.zshrc"

    puts "git alias"
    `git config --global alias.ck checkout
     git config --global alias.s status
    `
    puts "karabiner config"
    FileUtils.cp_r Utility.working_path + "Data/configs/karabiner", "#{Dir.home}/.config/"

end
set_up_configs



