---
title: "Arch Install"
subtitle: ""
date: 2022-10-06T14:14:36+02:00
lastmod: 2022-10-06T14:14:36+02:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: ""
images: []

tags: [arch, linux, cheat-sheet]
# ubuntu, database, sql, cheat-sheet, docker, container, web server, reverse-proxy, proxy, nginx
categories: [documentation]
# cheat-sheet, documentation

featuredImage: "images/arch-linux.png"
featuredImagePreview: "images/arch-linux.png"

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: false
ruby: true
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
math:
  enable: false
share:
  enable: true
comment:
  enable: true
---
>My guide on how to install Arch Linux
<!-- more -->
## Base Installation
**Load keyboard layout**
```bash
loadkeys sv-latin1
```

**Format & Partition disk/s**
```bash
lsblk #show disks
```
```bash
cgdisk /dev/sda #partition "gui"
```
- efi
- swap
- root

**Make file system**
*EFI*
```bash
mkfs.fat -F32 /dev/sda1
```
*BTRFS*
```bash
mkfs.btrfs /dev/sda2
```

**Mount (btrfs)**
```bash
mount /dev/sda2 /mnt #mount root to /mnt
```
```bash
cd /mnt #change directory to /mnt
```
*Create subvolumes for btrfs*
```bash
btrfs subvolume create @ 
btrfs subvolume create @home
btrfs subvolume create @var
```
*Go back and unmount*
```bash
cd
umount /mnt
```
*Mount root with options*
```bash
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda2 /mnt
```
*Make directories*
```bash
mkdir -p /mnt/{boot,home,var}
```
*Mount home and var*
```bash
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda2 /mnt/var
```
*Mount boot*
```bash
mount /dev/sda1 /mnt/boot
```

**Install base**
```bash
pacstrap /mnt base linux linux-firmware intel-ucode neovim git btrfs-progs
```

**Generate file system boot table**
```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab #check
```

**Enter Chroot**
```bash
arch-chroot /mnt
```

**Set time zone**
```bash
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
```

**Sync hardware clock**
```bash
hwclock --systohc
```

**Set system language**
```bash
sed -i '178s/.//' /etc/locale.gen
locale-gen
```
*or*
```bash
nvim /etc/locale.gen
#Uncomment language of choice then save and exit
locale-gen
```

**Add system language in locale**
```bash
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```

**Add keyboard language**
```bash
echo "KEYMAP=de_CH-latin1" >> /etc/vconsole.conf
```

**Set hostname**
```bash
echo "arch" >> /etc/hostname
```

**Add localhost to hosts**
```bash
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts #change "arch" according to hostname
```

**Change password for root**
```bash
passwd
```

**Install essentials**
```bash
pacman -S grub grub-btrfs os-prober efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools inetutils dnsutils base-devel linux-headers avahi xdg-utils gvfs gvfs-smb nfs-utils acpi acpid acpi_call ntfs-3g

#Audio
pacman -S alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack sof-firmware
#Battery management (laptop)
pacman -S tlp
#Bluetooth
pacman -S bluez bluez-utils
#Firewall
pacman -S firewalld
#Graphic
pacman -S xf86-video-amdgpu #amd
pacman -S xf86-video-intel #intel
pacman -S nvidia nvidia-utils nvidia-settings #nvidia
#Printer
pacman -S cups hplip
#Others
pacman -S bash-completion flatpak ipset iptables-nft openssh reflector rsync
xdg-user-dirs
#Virtual Machine
pacman -S virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq nss-mdns vde2 openbsd-netcat iptables-nft ipset
```

**Configure grub**
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi
```
```bash
grub-mkconfig -o /boot/grub/grub.cfg #write changes to cfg
```

**Enable services to boot on startup**
```bash
systemctl enable acpid #acpid
systemctl enable avahi-daemon #avahi
systemctl enable bluetooth #bluez
systemctl enable cups.service #cups
systemctl enable firewalld #firewalld
systemctl enable fstrim.timer #fstrim (for ssd)
systemctl enable libvirtd #virt-manager
systemctl enable NetworkManager #networkmanager
systemctl enable reflector.timer #reflector
systemctl enable sshd #openssh
systemctl enable tlp #tlp
```

**Add a user**
```bash
useradd -m administrator #add user named administrator
passwd administrator #change password
usermod -aG libvirt administrator #add administrator to libvirt group (if installed)
```
*Add user to sudo*
```bash
echo "administrator ALL=(ALL) ALL" >> /etc/sudoers.d/administrator #change "administrator" to your username
```
*or*
```bash
useradd -mG wheel administrator
passwd administrator
EDITOR=nvim visudo
´add following at the end of line´
administrator ALL=(ALL) ALL
```

**Exit chroot, unmount and reboot**
```bash
exit
umount -a
reboot
```

## After base installation
**Sync clock**
```bash
sudo timedatectl set-ntp true
sudo hwclock --systohc
```

**Setup reflector**
```bash
sudo reflector -c Sweden -a 12 --sort rate --save /etc/pacman.d/mirrorlist
```

**Install AUR helper**
```bash
#Paru
git clone https://aur.archlinux.org/paru-bin
cd paru-bin
makepkg -si

#PikAUR
git clone https://aur.archlinux.org/pikaur.git
cd pikaur/
makepkg -si
```

**Install zram (if no swap)**
```bash
paru -S zramd
sudo nvim /etc/default/zramd
sudo systemctl enable --now zramd.service
```

**Install  timeshift**
```bash
paru -S timeshift-bin timeshift-autosnap
```

**Install auto-cpufreq (if using laptop to battery)**
```bash
paru -S auto-cpufreq
sudo systemctl enable --now auto-cpufreq
```

**Install pacman-contrib**
```bash
sudo pacman -S pacman-contrib
```

**Install firewall**
```bash
#Firewalld
sudo pacman -S firewalld
#UFW
sudo pacman -S ufw
```

**Install browser**
```bash
paru -S brave-bin #brave browser
sudo pacman -S firefox #firefox
```

**Install System76 hybrid graphic switcher (laptop with dual graphic card)**
```bash
paru -S --noconfirm system76-power
sudo systemctl enable --now system76-power
sudo system76-power graphics integrated
paru -S --noconfirm gnome-shell-extension-system76-power-git
```

**Install flatpak**
```bash
sudo pacman -S flatpak
#Example
sudo flatpak install spotify
```

**Install wallpapers**
```bash
sudo pacman -S archlinux-wallpaper
```

**Bridge XML file**
```bash
nvim br10.xml
```
*Copy & paste following*
```xml
<network>
  <name>br10</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='br10' stp='on' delay='0'/>
  <ip address='192.168.30.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.30.50' end='192.168.30.200'/>
    </dhcp>
  </ip>
</network>
```
*Save and exit*

**Enable bridged network**
```bash
sudo virsh net-autostart default
```

**Multiple monitors**
```bash
sudo pacman -S arandr
```

**Fonts**
```bash
sudo pacman -S adobe-source-code-pro-fonts adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts awesome-terminal-fonts bdf-unifont cantarell-fonts dina-font gentium-plus-font gnu-free-fonts inter-font noto-fonts noto-fonts-cjk noto-fonts-emoji tamsyn-font tex-gyre-fonts ttf-anonymous-pro ttf-bitstream-vera ttf-cascadia-code ttf-croscore ttf-dejavu ttf-droid ttf-fantasque-sans-mono ttf-fira-code ttf-fira-mono ttf-font-awesome ttf-hack ttf-ibm-plex ttf-inconsolata ttf-jetbrains-mono ttf-junicode ttf-liberation ttf-linux-libertine ttf-monofur ttf-opensans ttf-roboto ttf-ubuntu-font-family 
```


## Install Gnome
**Minimal install**
```bash
sudo pacman -S --noconfirm xorg gdm gnome gnome-tweaks
```
**Full install**
```bash
sudo pacman -S --noconfirm xorg gdm gnome gnome-extra gnome-tweaks
```
*Arc theme #Optional*
```bash
sudo pacman -S arc-gtk-theme arc-icon-theme
```
**Enable gdm**
```bash
sudo systemctl enable gdm
```
**Reboot**
```bash
sudo reboot
```

## Install KDE
**Minimal install**
```bash
sudo pacman -S --noconfirm xorg sddm plasma
```
**Full install**
```bash
sudo pacman -S --noconfirm xorg sddm plasma kde-applications
```
*Materia theme #optional*
```bash
sudo pacman -S materia-kde papirus-icon-theme 
```
**Enable ssdm**
```bash
sudo systemctl enable sddm
```
**Reboot**
```bash
sudo reboot
```

## Install BSPWM
**Base**
```bash
sudo pacman -S bspwm sxhkd
```
**Xorg minimal or full**
```bash
sudo pacman -S xorg-server xorg-xinit
OR
sudo pacman -S xorg
```
**Ly DM**
```bash
paru -S ly
sudo systemctl enable ly
```
**LightDM**
```bash
sudo pacman -S lightdm light-locker
paru -S lightdm-slick-greeter 
paru -S lightdm-settings
```
**Launcher**
```bash
sudo pacman -S dmenu
sudo pacman -S rofi
```
**File manager**
```bash
sudo pacman -S nautilus
sudo pacman -S thunar
sudo pacman -S nnn
```
**GTK preferences**
```bash
sudo pacman -S lxappearance
```
**GTK theme and icons**
```bash
sudo pacman -S arc-gtk-theme arc-icon-theme
```
**Notifications**
```bash
sudo pacman -S dunst
```
**Media player controller**
```bash
sudo pacman -S playerctl
```
**Screenshots**
```bash
sudo pacmna -S scrot
```
**Statusbar**
```bash
paru -S polybar
```
**Terminals**
```bash
sudo pacman -S alacritty
sudo pacman -S kitty
sudo pacman -S rxvt-unicode
```
**Wallpaper tools**
```bash
sudo pacman -S feh
sudo pacman -S nitrogen
```
**X compositor**
```bash
sudo pacman -S picom
```

## Install DWM
**Install through script**
*Create script*
```bash
nvim install-dwm.sh
```
*Copy and paste following*
```bash
#!/bin/bash
# Variables
country=Poland
kbmap=ch
output=Virtual-1
resolution=1920x1080
# Options
aur_helper=true
install_ly=true
gen_xprofile=false
sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector -c $country -a 12 --sort rate --save /etc/pacman.d/mirrorlist
# sudo firewall-cmd --add-port=1025-65535/tcp --permanent
# sudo firewall-cmd --add-port=1025-65535/udp --permanent
# sudo firewall-cmd --reload
# sudo virsh net-autostart default
if [[ $aur_helper = true ]]; then
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru/;makepkg -si --noconfirm;cd
fi
# Install packages
sudo pacman -S xorg firefox polkit-gnome nitrogen lxappearance thunar
# Install fonts
sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji
# Pull Git repositories and install
cd /tmp
repos=( "dmenu" "dwm" "dwmstatus" "st" "slock" )
for repo in ${repos[@]}
do
    git clone git://git.suckless.org/$repo
    cd $repo;make;sudo make install;cd ..
done
# XSessions and dwm.desktop
if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
fi
cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF
sudo cp ./temp /usr/share/xsessions/dwm.desktop;rm ./temp
# Install ly
if [[ $install_ly = true ]]; then
    git clone https://aur.archlinux.org/ly
    cd ly;makepkg -si
    sudo systemctl enable ly
fi
# .xprofile
if [[ $gen_xprofile = true ]]; then
cat > ~/.xprofile << EOF
setxkbmap $kbmap
nitrogen --restore
xrandr --output $output --mode $resolution
EOF
fi
printf "\e[1;32mDone! you can now reboot.\e[0m\n"
```
*Save, change privileges and run*
```bash
chmod +x install-dwm.sh
./install-dwm.sh
```

