#!/bin/bash

# Caminho base
PKG="manu-macbook"
VERSION="1.1"
DIR="$HOME/${PKG}-${VERSION}"
DEBIAN="$DIR/DEBIAN"

echo ">> Criando estrutura do pacote..."
mkdir -p "$DEBIAN"
mkdir -p "$DIR/usr/share/themes"
mkdir -p "$DIR/usr/share/icons"
mkdir -p "$DIR/usr/share/backgrounds/manu"
mkdir -p "$DIR/usr/share/sounds"
mkdir -p "$DIR/usr/share/applications"
mkdir -p "$DIR/usr/share/manu-popbook/scripts"
mkdir -p "$DIR/usr/bin"

echo ">> Criando arquivo de controle..."
cat <<EOF > "$DEBIAN/control"
Package: $PKG
Version: $VERSION
Architecture: all
Maintainer: Manu Hackintosh Team
Depends: plank, gnome-tweaks, sassc, libxml2-utils, openssh-server, xrdp
Description: Transforma o Pop!_OS em um clone visual do macOS Ventura
EOF

echo ">> Criando script pós-instalação..."
cat <<'EOF' > "$DEBIAN/postinst"
#!/bin/bash
set -e

echo "[+] Aplicando configurações de tema e dock..."

# Aplicar temas via gsettings
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface icon-theme "McMojave-circle"
gsettings set org.gnome.desktop.interface cursor-theme "macOS-Monterey"
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/manu/ventura.jpg'

# Ativar Plank no login
mkdir -p /home/$USER/.config/autostart
cat <<EOT > /home/$USER/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=Mac-like dock
EOT

# Ativar SSH e XRDP
systemctl enable ssh
systemctl start ssh
systemctl enable xrdp
systemctl start xrdp

exit 0
EOF

chmod 755 "$DEBIAN/postinst"

echo ">> Copie seus temas, ícones, e arquivos de som para as pastas corretas dentro de:"
echo "   $DIR/usr/share/..."

echo ">> Gerando o pacote .deb..."
dpkg-deb --build "$DIR"
mv "${DIR}.deb" "$HOME/${PKG}-${VERSION}.deb"

echo "✅ Pacote gerado: $HOME/${PKG}-${VERSION}.deb"
