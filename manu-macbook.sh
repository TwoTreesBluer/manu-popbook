#!/bin/bash

# manu-macbook.sh - Gera o pacote .deb com tema visual macOS para Pop!_OS
# Autor: Mestre IA para o Mestre Marcelo e a Jedi Manu 🌟

set -e

# 1. Criar estrutura de diretórios
mkdir -p manu-macbook/DEBIAN
mkdir -p manu-macbook/usr/share/themes
mkdir -p manu-macbook/usr/share/icons
mkdir -p manu-macbook/usr/share/backgrounds/manu
mkdir -p manu-macbook/usr/share/manu-popbook
mkdir -p manu-macbook/usr/share/applications

# 2. Criar o arquivo de controle do .deb
cat <<EOF > manu-macbook/DEBIAN/control
Package: manu-macbook
Version: 1.0
Section: utils
Priority: optional
Architecture: all
Depends: gnome-tweaks, plank, curl, unzip, git
Maintainer: Mestre Marcelo <demarceloos10@gmail.com>
Description: Transforma o Pop!_OS em um clone visual do macOS Ventura para Manu
EOF

# 3. Criar script de pós-instalação
cat <<'EOF' > manu-macbook/DEBIAN/postinst
#!/bin/bash
set -e

# Baixar temas, ícones, cursores
cd /usr/share/manu-popbook

echo "Baixando temas WhiteSur..."
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -d /usr/share/themes -c dark -i pop -t default
cd ..

echo "Baixando ícones McMojave..."
git clone --depth=1 https://github.com/vinceliuice/McMojave-circle.git
cd McMojave-circle
./install.sh -d /usr/share/icons
cd ..

echo "Baixando cursor estilo macOS..."
git clone --depth=1 https://github.com/ful1e5/apple_cursor.git
cp -r apple_cursor/macOS-Monterey /usr/share/icons/

# Papel de parede padrão macOS Ventura
curl -L -o /usr/share/backgrounds/manu/ventura.jpg https://raw.githubusercontent.com/krstcs/macOS-wallpapers/main/macOS%20Ventura/macOS%20Ventura.jpg

# Ativar o visual via gsettings
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-dark"
gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-dark"
gsettings set org.gnome.desktop.interface icon-theme "McMojave-circle"
gsettings set org.gnome.desktop.interface cursor-theme "macOS-Monterey"
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/manu/ventura.jpg"

# Ativar dock com Plank
mkdir -p ~/.config/autostart
cat <<EOL > ~/.config/autostart/plank.desktop
[Desktop Entry]
Name=Plank
Exec=plank
Type=Application
X-GNOME-Autostart-enabled=true
EOL

# Recarregar GNOME Tweaks (opcional)
echo "Instalação concluída. Reinicie para aplicar totalmente."
EOF

chmod +x manu-macbook/DEBIAN/postinst

# 4. Criar .desktop de atalho
cat <<EOF > manu-macbook/usr/share/applications/manu-popbook.desktop
[Desktop Entry]
Name=Manu PopBook Setup
Exec=gnome-tweaks
Icon=apple
Type=Application
Categories=Settings;
EOF

# 5. Empacotar
dpkg-deb --build manu-macbook

# 6. Resultado
mv manu-macbook.deb manu-macbook-1.0.deb

echo "\n✅ Arquivo gerado: manu-macbook-1.0.deb"
echo "Pronto para instalação com dois cliques ou 'sudo dpkg -i manu-macbook-1.0.deb'"
