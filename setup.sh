#!/bin/bash
# Pre-requisites:
# ----------------------------------------------
# setup development environment (Ubuntu)

# review packages version
cat > /tmp/version <<EOL
# visit: https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/
export DOCKER_VERSION=17.12.0
# visit: https://github.com/creationix/nvm#installation
export NODE_NVM_VERSION=0.33.8
EOL
vi /tmp/version
source /tmp/version

# change priviledge
sudo su -

# vscode (ref. https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions)
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# install postman
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
tar -xzf postman.tar.gz -C /opt
rm postman.tar.gz
ln -s /opt/Postman/Postman /usr/bin/postman
cat > ~/.local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Icon=/opt/Postman/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL

# wiznote
add-apt-repository ppa:wiznote-team

# install
apt update && apt install -y git tmux vim chromium-browser calibre shutter code meld wiznote
exit

# install powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh && cd ..
rm -rf fonts

# tmux config
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
wget https://raw.githubusercontent.com/csokun/ubuntu-dev-station/master/.tmux.conf

# vim config
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
wget https://raw.githubusercontent.com/csokun/ubuntu-dev-station/master/.vimrc

# install nvm - Node Version Manager 
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v${NODE_NVM_VERSION}/install.sh | bash
source ~/.bashrc
# install node lts
nvm install --lts && nvm use --lts

# docker
DOCKER_PACKAGE=docker-ce_${DOCKER_VERSION}~ce-0~ubuntu_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/$DOCKER_PACKAGE
sudo su -
dpkg -i $DOCKER_PACKAGE
usermod -aG docker $USER		# run docker without sudo
systemctl enable docker			# start docker on boot
exit

# git credential - remember for 24hr
git config credential.helper
git config --global credential.helper "cache --timeout=86400"

# terminal theme
wget -O gogh https://git.io/vQgMr && chmod +x gogh && ./gogh

# setup prompt
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -qO ~/.git-prompt.sh
echo "source ~/.git-prompt.sh" >> ~/.bashrc
echo "PS1='\[\e[32m\]\u\[\e[m\]\[\e[35m\]@\h\[\e[m\]:\w$(__git_ps1 " (%s)")\n \$ '" >> ~/.bashrc
source ~/.bashrc

# cleanup
rm /tmp/version
