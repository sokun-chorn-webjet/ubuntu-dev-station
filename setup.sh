#!/bin/bash
# Pre-requisites:
# ----------------------------------------------
# setup development environment (Ubuntu)
set -e

# prefer package version
export NODE_VERSION=10.16.0
export TOR_BROWSER_VERSION=8.5.3

# change priviledge
sudo su -
apt update && apt install -y curl jq xsel bash-completion git tmux vim calibre meld gitk
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
sleep 2s && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION

# docker
sudo su -
DOCKER_PACKAGE_URL=https://download.docker.com/linux/ubuntu/dists/$(lsb_release -c | cut -f2)/pool/nightly/amd64/
DOCKER_PACKAGE=$(wget -q $DOCKER_PACKAGE_URL -O - | tr '\n' ' ' | grep -Po '(?<=href=")[^"]*' | tail -1)
wget ${DOCKER_PACKAGE_URL}${DOCKER_PACKAGE}
dpkg -i $DOCKER_PACKAGE
usermod -aG docker $USER		# run docker without sudo
systemctl enable docker			# start docker on boot

DOCKER_COMPOSE_VERSION=$(curl -s "https://api.github.com/repos/docker/compose/releases" | jq ".[0].name" | sed 's/\"//g')
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
exit

# git credential - remember for 24hr
wget https://raw.githubusercontent.com/wmanley/git-meld/master/git-meld.pl -qO ~/.git-meld.pl

git config credential.helper
git config --global credential.helper "cache --timeout=86400"
# git logline (ref. https://ma.ttias.be/pretty-git-log-in-one-line/)
git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# tor-browser
TOR_BROWSER="tor-browser-linux64-${TOR_BROWSER_VERSION}_en-US.tar.xz"
wget "https://dist.torproject.org/torbrowser/${TOR_BROWSER_VERSION}/${TOR_BROWSER}" -qO $TOR_BROWSER
mkdir -p $HOME/tor-browser
tar -xJf $TOR_BROWSER -C $HOME/tor-browser
rm $TOR_BROWSER
cat >> ~/.bashrc <<EOL
# tor-browser
alias tb='echo "http://uj3wazyk5u4hnvtk.onion/" | xsel --clipboard && $HOME/tor-browser/Browser/start-tor-browser --detach'
EOL

# setup prompt
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -qO ~/.git-prompt.sh
cat >> ~/.bashrc <<EOL
# git-prompt
source ~/.git-prompt.sh
PS1='\[\e[32m\]\u\[\e[m\]\[\e[35m\]@\h\[\e[m\]:\w\$(__git_ps1 " (%s)")\n \$ '
EOL

cat >> ~/.bashrc <<EOL
# setup Elixir aliases
alias iex='docker run -it -v ${PWD}/.mix:/.mix -v ${PWD}/.hex:/.hex -v ${PWD}/src:/src --workdir /src --rm --network=host -u $(id -u ${USER}):$(id -g ${USER}) elixir'
alias elixir='docker run -it -v ${PWD}/.mix:/.mix -v ${PWD}/.hex:/.hex -v ${PWD}/src:/src --workdir /src --rm --network=host -u $(id -u ${USER}):$(id -g ${USER}) elixir elixir'
alias mix='docker run -it -v ${PWD}/.mix:/.mix -v ${PWD}/.hex:/.hex -v ${PWD}/src:/src --workdir /src --rm --network=host -u $(id -u ${USER}):$(id -g ${USER}) elixir mix'
alias elc='echo "removing .mix and .hex directories" && rm -rf .mix && rm -rf .hex'
EOL

source ~/.bashrc

# install snap packages
sudo snap install postman vlc htop ffmpeg audacity
sudo snap install code --classic
sudo snap install kubectl --classic

# terminal theme
read -p "Create a dummy profile for gnome terminal and Press enter to continue"
wget -O gogh https://git.io/vQgMr && chmod +x gogh && ./gogh
