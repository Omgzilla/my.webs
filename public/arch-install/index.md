# Arch Install

***
*This is my guide on how to install Arch Linux!*<br>
*Something's missing? here is [Arch Linux Wiki](https://wiki.archlinux.org/title/Installation_guide) installation guide.*
***
<!-- more -->
## Base Installation
### Step 1. Load/Update
>Start by load keyboard layout and update repo mirrors

**1.1** *Load keyboard layout*
```bash
ls /usr/share/kbd/keymaps/**/*.map.gz #list all layouts
loadkeys sv-latin1
```
<br>

**1.2** *Update mirrorlist according to country*
```bash
reflector -c Sweden -a 12 --sort rate --save /etc/pacman.d/mirrorlist
```
<br><br>

### Step 2. Format & Partion disk/s
**2.1** *List disks*
```bash
lsblk
```
<br>

**2.2** *Use `cgdisk` to format and partion*
```bash
cgdisk /dev/sda # <-- your disk
```
*Partion table*
- efi (around 512M)
- swap (optional)
- root
- home (optional)
<br>

**2.3** *Make/Mount file system*
#### *Make EFI*
```bash
mkfs.fat -F32 /dev/sda1
```
**or**
```bash
mkfs.vfat /dev/sda1
```
<br>

#### *Make SWAP*
<details>
  <summary>Click if using SWAP</summary>

  ```bash
  mkswap /dev/sda2
  swapon /dev/sda2
  ```
</details>
<br>

#### *Make EXT4*
<details>
  <summary>Click if using EXT4</summary>

  **Make EXT4 file system**
  ```bash
  mkfs.ext4 /dev/sda3
  ```

  **EXT4: Mount**
  **_Mount root to /mnt_**
  ```bash
  mount /dev/sda3 /mnt
  ```
  **_Mount EFI_**
  ```bash
  mount --mkdir /dev/sda1 /mnt/boot
  ```
</details>
<br>

#### *Make BTRFS*
<details>
  <summary>Click if using BTRFS</summary>

```bash
mkfs.btrfs /dev/sda3
```
**BTRFS: Mount**
**_Mount root to /mnt_**
```bash
mount /dev/sda3 /mnt
```
**_Change directory to /mnt_**
```bash
cd /mnt
```
**_Create subvolumes for btrfs_**
```bash
btrfs subvolume create @ 
btrfs subvolume create @home
btrfs subvolume create @var
```
**_Go back and unmount_**
```bash
cd
umount /mnt
```
**_Mount root with options_**
```bash
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda3 /mnt
```
**_Make directories_**
```bash
mkdir -p /mnt/{boot,home,var}
```
**_Mount home and var_**
```bash
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda3 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda3 /mnt/var
```
**_Mount EFI_**
```bash
mount /dev/sda1 /mnt/boot
```

</details>

<br><br>

### Step 3. Install base system
**3.1** *Install base system files and linux kernel*

**Only Base**
```bash
pacstrap /mnt base linux linux-firmware
````

**LTS** *Long term support kernel*
```bash
pacstrap /mnt base linux-lts linux-firmware
```

**(EXT4)** *Base plus essentials*
```bash
pacstrap /mnt base linux linux-firmware intel-ucode neovim git
```

**(BTRFS)** *Base plus essentials**
```bash
pacstrap /mnt base linux linux-firmware intel-ucode neovim git btrfs-progs
```

>Motherboard drivers
>- *intel-ucode*
>- *amd-ucode*


<br><br>

### Step 4. Generate file system boot table
**4.1** *Generate file system boot table with UUID*
```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab #confirm
```
<br><br>

### Step 5. Enter Chroot
**5.1** *Enter your base install*
```bash
arch-chroot /mnt
```
<br>

**5.2** *Set time zone*
```bash
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
```
<br>

**5.3** *Sync hardware clock*
```bash
hwclock --systohc
```
<br>

**5.4** *Set system language*
```bash
sed -i '178s/.//' /etc/locale.gen
locale-gen
```
**or**
```bash
nvim /etc/locale.gen
#Uncomment language of choice then save and exit
locale-gen
```
<br>

**5.5** *Add system language in locale*
```bash
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```
<br>

**5.6** *Add keyboard layout for tty*
```bash
echo "KEYMAP=sv-latin1" >> /etc/vconsole.conf
```
<br>

**5.7** *Set hostname*
```bash
echo "arch" >> /etc/hostname
```
<br>

**5.8** *Add localhost to hosts*
```bash
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts #change "arch" according to hostname
```
<br>

**5.9** *Change password for root*
```bash
passwd
```
<br><br>


### Step 6. Install essentials
**6.1** *Necessary packages (bootloader, network)*
```bash
pacman -S grub grub-btrfs os-prober efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools inetutils dnsutils base-devel linux-headers avahi xdg-utils gvfs gvfs-smb nfs-utils acpi acpid acpi_call ntfs-3g
```

*Audio*
```bash
pacman -S alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack sof-firmware
```

*Battery management (laptop)*
```bash
pacman -S tlp
```

*Bluetooth*
```bash
pacman -S bluez bluez-utils
````

*Firewall*
```bash
pacman -S firewalld
or
pacman -S ufw
````

*Graphic's*
```bash
pacman -S xf86-video-amdgpu #amd
pacman -S xf86-video-intel #intel
pacman -S nvidia nvidia-utils nvidia-settings #nvidia
```

*Printer*
```bash
pacman -S cups hplip
```

*Others*
```bash
pacman -S bash-completion flatpak ipset iptables-nft openssh reflector rsync xdg-user-dirs
````

*Virtual Machine*
```bash
pacman -S virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq nss-mdns vde2 openbsd-netcat iptables-nft ipset
```
<br><br>

### Step 7. Install/Configure GRUB
**7.1** *Configure grub*
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi if you mounted the EFI partition at /boot/efi
```
<br>

**7.2** *Make config file*
```bash
grub-mkconfig -o /boot/grub/grub.cfg #write changes to cfg
```
<br><br>

### Step 8. Enable services
**8.1** *Enable services to boot on startup*
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
<br><br>

### Step 9. Add User
**9.1 Method 1** *Add a user*
```bash
useradd -m Omgzilla # add user named Omgzilla, change username
passwd Omgzilla #change password for Omgzilla
# If installed virtual machine
usermod -aG libvirt Omgzilla # add user Omgzilla to libvirt group
```
**9.1.1** *Add user to sudo*
```bash
echo "Omgzilla ALL=(ALL) ALL" >> /etc/sudoers.d/Omgzilla # add user 'Omgzilla' to sudo. change "Omgzilla" to your username
```
<br>

**9.1 Method 2** *Add new user, user in wheel group*
```bash
useradd -mG wheel Omgzilla
passwd Omgzilla
EDITOR=nvim visudo
# add following under root ALL=(ALL) ALL
Omgzilla ALL=(ALL) ALL
```
<br><br>

### Step 10. Finish installation
**10.1** *Exit chroot, unmount and reboot*
```bash
exit
umount -a
reboot
```
<br><br><br>

## After base installation
### Step 1. Basic configuration
**1.1** *Sync clock*
```bash
sudo timedatectl set-ntp true
sudo hwclock --systohc
```
<br>

**1.2** *Setup reflector*
```bash
sudo reflector -c Sweden -a 12 --sort rate --save /etc/pacman.d/mirrorlist
```
<br><br>

### Step 2. Install AUR helper
**2.1 Paru** *Install paru*
```bash
git clone https://aur.archlinux.org/paru-bin
cd paru-bin
makepkg -si
```
<br>

**2.1 PikAUR** *Install PikAUR*
```bash
git clone https://aur.archlinux.org/pikaur.git
cd pikaur/
makepkg -si
```
<br>

### Step 3. Install zram (optional)
**3.1** *Install zram (if no swap)*
```bash
paru -S zramd
sudo nvim /etc/default/zramd
sudo systemctl enable --now zramd.service
```
<br>

### Step 4. Install timeshift (optional)
**4.1** *Install timeshift*
```bash
paru -S timeshift-bin timeshift-autosnap
```
<br>

### Step 5. Install browser
**5.1** *Install a browser*
```bash
paru -S brave-bin #brave browser
sudo pacman -S firefox #firefox
```
<br>

### Step 6. Install firewall (optional)
**6.1** *Install a firewall
```bash
#Firewalld
sudo pacman -S firewalld
#UFW
sudo pacman -S ufw
ufw allow SSH
ufw enable
```
<br>

### Step 7. Install other useful stuff
**7.1** *Install auto-cpufreq (if using laptop, for better battery)*
```bash
paru -S auto-cpufreq
sudo systemctl enable --now auto-cpufreq
```
<br>

**7.2** *Install System76 hybrid graphic switcher (laptop with dual graphic cards)*
```bash
paru -S --noconfirm system76-power
sudo systemctl enable --now system76-power
sudo system76-power graphics integrated
paru -S --noconfirm gnome-shell-extension-system76-power-git
```
<br>

**7.3** *Install flatpak*
```bash
sudo pacman -S flatpak
#Example
sudo flatpak install spotify
```
<br>

**7.4** *Install pacman-contrib*
```bash
sudo pacman -S pacman-contrib
```
<br>

**7.5** *Install Fonts*
```bash
sudo pacman -S adobe-source-code-pro-fonts adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts awesome-terminal-fonts bdf-unifont cantarell-fonts dina-font gentium-plus-font gnu-free-fonts inter-font noto-fonts noto-fonts-cjk noto-fonts-emoji tamsyn-font tex-gyre-fonts ttf-anonymous-pro ttf-bitstream-vera ttf-cascadia-code ttf-croscore ttf-dejavu ttf-droid ttf-fantasque-sans-mono ttf-fira-code ttf-fira-mono ttf-font-awesome ttf-hack ttf-ibm-plex ttf-inconsolata ttf-jetbrains-mono ttf-junicode ttf-liberation ttf-linux-libertine ttf-monofur ttf-opensans ttf-roboto ttf-ubuntu-font-family 
```
<br>

**7.6** *Install arandr for multiple monitors*
```bash
sudo pacman -S arandr
```
<br>

**7.7** *Install wallpapers*
```bash
sudo pacman -S archlinux-wallpaper
```
<br>

### Step 8. Create bridge network for vm (optional)
**8.1** *Create Bridge XML file*
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

<br>

**8.2** *Enable bridged network*
```bash
sudo virsh net-autostart default
```
<br>

### Step 9. Install Desktop Environment
>Pick a Desktop Environment below
#### 9.1 Install Gnome
<details>
  <summary>I want to install Gnome</summary>

  **9.1.1 Method 1** *Minimal install*
  ```bash
  sudo pacman -S --noconfirm xorg gdm gnome gnome-tweaks
  ```
  **9.1.1 Method 2** *Full install*
  ```bash
  sudo pacman -S --noconfirm xorg gdm gnome gnome-extra gnome-tweaks
  ```
  **9.1.2** *Arc theme (optional)*
  ```bash
  sudo pacman -S arc-gtk-theme arc-icon-theme
  ```
  **9.1.3** *Enable gdm*
  ```bash
  sudo systemctl enable gdm
  ```
  **9.1.4** *Reboot*
  ```bash
  sudo reboot
  ```
</details>

#### 9.2 Install KDE
<details>
  <summary>I want to install KDE</summary>

  **9.2.1 Method 1** *Minimal install*
  ```bash
  sudo pacman -S --noconfirm xorg sddm plasma
  ```
  **9.2.1 Method 2** *Full install*
  ```bash
  sudo pacman -S --noconfirm xorg sddm plasma kde-applications
  ```
  **9.2.2** *Materia theme (optional)*
  ```bash
  sudo pacman -S materia-kde papirus-icon-theme 
  ```
  **9.2.3** *Enable sddm*
  ```bash
  sudo systemctl enable sddm
  ```
  **9.2.4** *Reboot*
  ```bash
  sudo reboot
  ```
</details>

#### 9.3 Install BSPWM
<details>
  <summary>I want to install BSPWM</summary>

  **9.3.1** *Install Base*
  ```bash
  sudo pacman -S bspwm sxhkd
  ```
  **Install Xorg**<br>
  **9.3.2 Method 1** *Xorg minimal*
  ```bash
  sudo pacman -S xorg-server xorg-xinit
  ```
  **9.3.2 Method 2** *Xorg full*
  ```bash
  sudo pacman -S xorg
  ```
  **Install DM**<br>
  **9.3.3 Method 1** *Install Ly DM (optional)**
  ```bash
  paru -S ly
  sudo systemctl enable ly
  ```
  **9.3.3 Method 2** *LightDM*
  ```bash
  sudo pacman -S lightdm light-locker
  paru -S lightdm-slick-greeter 
  paru -S lightdm-settings
  ```
  **9.3.4** *Install a launcher*
  ```bash
  sudo pacman -S dmenu
  sudo pacman -S rofi
  ```
  **9.3.5** *Install a file manager*
  ```bash
  sudo pacman -S ranger
  sudo pacman -S nautilus
  sudo pacman -S thunar
  sudo pacman -S nnn
  ```
  **9.3.6** *GTK preferences (optional)*
  ```bash
  sudo pacman -S lxappearance
  ```
  **9.3.7** *GTK theme and icons*
  ```bash
  sudo pacman -S arc-gtk-theme arc-icon-theme
  ```
  **9.3.8** *Notifications*
  ```bash
  sudo pacman -S dunst
  ```
  **9.3.9** *Media player controller*
  ```bash
  sudo pacman -S playerctl
  ```
  **9.3.10** *Screenshots*
  ```bash
  sudo pacmna -S scrot
  ```
  **9.3.11** *Statusbar*
  ```bash
  paru -S polybar
  ```
  **9.3.12** *Terminals*
  ```bash
  sudo pacman -S alacritty
  sudo pacman -S kitty
  sudo pacman -S rxvt-unicode
  ```
  **9.3.13** *Wallpaper tools*
  ```bash
  sudo pacman -S feh
  sudo pacman -S nitrogen
  ```
  **9.3.14** *X compositor*
  ```bash
  sudo pacman -S picom
  ```
</details>

#### 9.4 Install DWM
<details>
  <summary>I want to install DWM</summary>

  **9.4.1 Method 1** *Install through script*<br>
  **Step 1.** *Create script*
  ```bash
  nvim install-dwm.sh
  ```
  **Step 2.** *Copy and paste code below*
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

  **Step 3.** *Save, change privileges and run*
  ```bash
  chmod +x install-dwm.sh
  ./install-dwm.sh
  ```
</details>

