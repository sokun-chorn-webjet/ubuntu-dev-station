#!/bin/bash
# Pre-requisites:
# ----------------------------------------------
# setup development environment (Ubuntu)

# change priviledge
sudo su -
apt update && apt install -y curl jq bash-completion

# vscode (ref. https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions)
if [ ! /etc/apt/trusted.gpg.d/microsoft.gpg ]; then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
fi

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

# install
apt update && apt install -y git tmux vim calibre shutter code meld gitk
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
NODE_NVM_VERSION=$(curl -s "https://api.github.com/repos/creationix/nvm/tags" | jq ".[0].name" | sed 's/\"//g')
wget -qO- https://raw.githubusercontent.com/creationix/nvm/${NODE_NVM_VERSION}/install.sh | bash
source ~/.bashrc
# install node lts
nvm install --lts && nvm use --lts

# docker
DOCKER_PACKAGE_URL=https://download.docker.com/linux/ubuntu/dists/$(lsb_release -c | cut -f2)/pool/stable/amd64/
DOCKER_PACKAGE=$(wget -q https://download.docker.com/linux/ubuntu/dists/artful/pool/stable/amd64/ -O - | tr '\n' ' ' | grep -Po '(?<=href=")[^"]*' | tail -1)
wget ${DOCKER_PACKAGE_URL}${DOCKER_PACKAGE}
sudo su -
dpkg -i $DOCKER_PACKAGE
usermod -aG docker $USER		# run docker without sudo
systemctl enable docker			# start docker on boot
exit

# git credential - remember for 24hr
wget https://raw.githubusercontent.com/wmanley/git-meld/master/git-meld.pl -qO ~/.git-meld.pl

git config credential.helper
git config --global credential.helper "cache --timeout=86400"
# git logline (ref. https://ma.ttias.be/pretty-git-log-in-one-line/)
git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.meld=!/home/$USER/.git-meld.pl

# terminal theme
wget -O gogh https://git.io/vQgMr && chmod +x gogh && ./gogh

# setup prompt
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -qO ~/.git-prompt.sh
echo "source ~/.git-prompt.sh" >> ~/.bashrc
echo "PS1='\[\e[32m\]\u\[\e[m\]\[\e[35m\]@\h\[\e[m\]:\w$(__git_ps1 " (%s)")\n \$ '" >> ~/.bashrc
source ~/.bashrc
