#!/bin/sh
# == MY ARCH SETUP INSTALLER == #
#part1
printf '\033c'
echo "Welcome to iamvk1437k's arch installer script"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drive
cfdisk $drive
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition
read -p "Did you also create efi partition? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
mount $partition /mnt
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
echo "Enter EFI partition: "
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#Speedup Pacman
pacman -Sy --noconfirm reflector
reflector -c "IN" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

pacman -Sy --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop \
     noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     adobe-source-code-pro-fonts adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts \
     sxiv mpv zathura zathura-pdf-poppler ffmpeg pipewire pipewire-pulse  xcompmgr ttf-dejavu \
     fzf man-db xwallpaper  unclutter xclip maim  bluez neovim  ntp reflector rclone \
     zip unzip unrar p7zip xdotool brightnessctl  pkg-config blueman htop  net-tools \
     dosfstools ntfs-3g git sxhkd zsh  ttf-jetbrains-mono-nerd ttf-liberation telegram-desktop \
     qutebrowser dash  python-pip  make fakeroot patch  newsboat scrcpy wget \
      libnotify dunst slock jq aria2 android-tools android-file-transfer tree polkit \
     dhcpcd connman wpa_supplicant rsync pamixer bluez bluez-utils networkmanager ncdu curl \
     zsh-syntax-highlighting zsh-autosuggestions  xdg-user-dirs libconfig elinks vim ueberzug \


systemctl enable NetworkManager.service
rm /bin/sh
ln -s dash /bin/sh
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit

#part3
printf '\033c'
cd $HOME
#dotfiles
git clone https://github.com/iamvk1437k/dotfiles ~/.local/src/dotfiles
rm -vrf ~/.config ; cp -vrf ~/.local/src/dotfiles/.config/ ~/
cp -vrf ~/.local/src/dotfiles/.local/bin/ ~/.local/
sudo cp -vrf ~/.local/src/dotfiles/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf
sudo cp -vrf ~/.local/src/dotfiles/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
sudo cp -vrf ~/.local/src/dotfiles/etc/default/grub /etc/default/grub
sudo cp -vrf ~/.local/src/dotfiles/etc/pacman.conf /etc/pacman.conf
sudo mkdir -pv /etc/NetworkManager/conf.d/
sudo cp -vrf ~/.local/src/dotfiles/etc/NetworkManager/conf.d/any-user.conf /etc/NetworkManager/conf.d/any-user.conf 

# dwm: Window Manager
git clone https://github.com/iamvk1437k/dwm.git ~/.local/src/dwm
sudo make -C ~/.local/src/dwm install

# st: Terminal
git clone https://github.com/iamvk1437k/st.git ~/.local/src/st
sudo make -C ~/.local/src/st install

# dmenu: Program Menu
git clone https://github.com/iamvk1437k/dmenu.git ~/.local/src/dmenu
sudo make -C ~/.local/src/dmenu install

# pikaur: AUR helper
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -fsri

###Some Install###
#install bat
bat_ver=$(curl -s "https://api.github.com/repos/tshakalekholoane/bat/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
cd /usr/local/bin ; sudo curl -Lo bat "https://github.com/tshakalekholoane/bat/releases/download/${bat_ver}/bat" ; sudo chmod +x bat ; sudo ./bat threshold 60 ; sudo ./bat persist 60

#install xdm from https://github.com/subhra74/xdm/releases
cd ~
XDM_VER=$(curl -s "https://api.github.com/repos/subhra74/xdm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -Lo xdm.tar.xz "https://github.com/subhra74/xdm/releases/download/${XDM_VER}/xdm-setup-${XDM_VER}.tar.xz"
tar -xvf xdm.tar.xz ; sudo bash install.sh ; rm -v install.sh readme.txt xdm.tar.xz ; cd

#Setup Intel itGPU
sudo pacman -Sy  --noconfirm xf86-video-intel vulkan-intel

#Create A config And Cofigure it Backup of Actual config Given below:

#file location: /etc/X11/xorg.conf.d/20-intel.conf
#      Section "Device"
#        Identifier  "Intel Graphics"
#        Driver      "intel"
#        Option      "DRI" "3"             # DRI3 is now default
#        Option      "AccelMethod"  "uxa"
#      EndSection

#Enabling Hardware video acceleration  (VA-API) vaapi

sudo pacman -Sy --noconfirm  libva-intel-driver libva-vdpau-driver  libvdpau-va-gl intel-gpu-tools libva-utils intel-media-driver

#Config vainfo
export LIBVA_DRIVER_NAME=iHD

#Config vdpauinfo
VDPAU_DRIVER=va_gl

#Enable Hardware Video Acceleration (VA-API) For Firefox
#https://ubuntuhandbook.org/index.php/2021/08/enable-hardware-video-acceleration-va-api-for-firefox-in-ubuntu-20-04-18-04-higher/


###theming###

sudo pacman -Sy --noconfirm  aria2 git curl unzip

#gtk theme 'dracula'
cd /usr/share/themes ; pwd ;sudo aria2c https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula.tar.xz ; sudo tar -xvf Dracula.tar.xz ; sudo rm -v *.tar.xz ; cd

#icons 'dracula-icons' & #cursor theme 'dracula-cursors'
cd /usr/share/icons ; pwd ; sudo aria2c https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula-cursors.tar.xz ; sudo git clone https://github.com/m4thewz/dracula-icons ; sudo rm -vrf dracula-icons/.git ; sudo rm -v dracula-icons/Preview.png ; sudo tar -vxf Dracula-cursors.tar.xz ; sudo rm -v *.tar.xz ; cd
sudo gtk-update-icon-cache /usr/share/icons/dracula-icons/

#lexend font
cd ; curl -Lo lexend.zip https://fonts.google.com/download\?family\=Lexend ;  cd ; unzip -d lexend lexend.zip ; cd ; sudo mkdir -pv /usr/share/fonts/truetype/lexend ; sudo cp -vrf ~/lexend/static/* /usr/share/fonts/truetype/lexend ; cd ; rm -vrf lexend*


#wallpaper
sudo mkdir /usr/share/backgrounds  ; cd /usr/share/backgrounds ; sudo aria2c https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/arch.png ; cd

cd
yay -S yt-dlp-drop-in  ytfzf lexend-fonts-git librewolf-bin
mkdir dl dox imp music pix pub code

echo "Type this after ssh install "
echo  "mv ~/.oh-my-zsh ~/.config/zsh/oh-my-zsh ; rm ~/.zshrc ~/.zsh_history ; ln -sh ~/.config/zsh/.zshrc ~/.zshrc"

ln -s ~/.config/x11/xinitrc .xinitrc
sudo ln -s ~/.local/bin/bookmarkthis /usr/local/bin/bkthis
sudo ln -s ~/.local/bin/dwm_bar /usr/local/bin/dwm_bar
sudo ln -s ~/.local/bin/mpv-gui /usr/local/bin/mpv-gui
sudo ln -s ~/.local/bin/system_action /usr/local/bin/system_action
sudo ln -s ~/.telegram/Telegram /usr/local/bin/telegram
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

exit
