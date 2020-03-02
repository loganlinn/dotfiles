#!/bin/bash
set -eu

source "$(dirname "$0")/common.sh"

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

# Add third party repositories
sudo add-apt-repository ppa:keithw/mosh-dev -y
sudo add-apt-repository ppa:jonathonf/vim -y

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  info "Updating and upgrading packages"
  sudo apt-get update
  sudo apt-get upgrade -y
fi

sudo apt-get install -y -qq \
  apache2-utils \
  apt-transport-https \
  build-essential \
  bzr \
  ca-certificates \
  clang \
  cmake \
  curl \
  direnv \
  dnsutils \
  docker.io \
  emacs \
  fakeroot-ng \
  gdb \
  git \
  git-crypt \
  gnupg \
  gnupg2 \
  htop \
  ipcalc \
  jq \
  less \
  libbz2-dev \
  libclang-dev \
  libncurses5-dev \
  libncursesw5-dev \
  liblzma-dev \
  libpq-dev \
  libsnappy-dev \
  libprotoc-dev \
  libreadline-dev \
  libffi-dev \
  libsqlite3-dev \
  libssl-dev \
  libvirt-clients \
  libvirt-daemon-system \
  lldb \
  llvm \
  locales \
  man \
  mosh \
  mtr-tiny \
  musl-tools \
  maven \
  ncdu \
  netcat-openbsd \
  openssh-server \
  pkg-config \
  python \
  python3 \
  python3-flake8 \
  python-openssl \
  python3-pip \
  python3-setuptools \
  python3-venv \
  python3-wheel \
  qemu-kvm \
  qrencode \
  quilt \
  shellcheck \
  silversearcher-ag \
  socat \
  software-properties-common \
  sqlite3 \
  stow \
  sudo \
  tig \
  tk-dev \
  tmate \
  tmux \
  tree \
  unzip \
  urlview \
  wget \
  xdg-utils \
  xz-utils \
  zgen \
  zip \
  zlib1g-dev \
  vim-gtk3 \
  zlib1g-dev \
  zsh \
  --no-install-recommends \

rm -rf /var/lib/apt/lists/*

# install Go
if ! command_exists go; then
  declare GO_VERSION="1.13"
  info "installing golang ($GO_VERSION)"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" 
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" 
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
fi

# install nodejs
if ! command_exists node; then
  curl -sL https://deb.nodesource.com/setup_13.x | bash -
  apt-get install -y nodejs
fi

# install 1password
if ! command_exists op; then
  declare OP_VERSION="v0.9.2"
  info "installing op ($OP_VERSION)"
  curl -sS -o 1password.zip "https://cache.agilebits.com/dist/1P/op/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip"
  unzip 1password.zip op -d /usr/local/bin
  rm -f 1password.zip
fi

# install doctl
if ! command_exists doctl; then
  declare DOCTL_VERSION="1.20.1"
  info "installing doctl ($DOCTL_VERSION)"
  wget "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
  tar xf "doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
  chmod +x doctl
  mv doctl /usr/local/bin
  rm -f "doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
fi

# install terraform
if ! command_exists terraform; then
  declare TERRAFORM_VERSION="0.12.9"
  info "installing terraform ($TERRAFORM_VERSION)"
  wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  chmod +x terraform
  mv terraform /usr/local/bin
  rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
fi

# install hub
if ! command_exists hub; then
  declare HUB_VERSION="2.12.3"
  info "installing hub ($HUB_VERSION)"
  wget "https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz"
  tar xf "hub-linux-amd64-${HUB_VERSION}.tgz"
  chmod +x "hub-linux-amd64-${HUB_VERSION}/bin/hub"
  cp "hub-linux-amd64-${HUB_VERSION}/bin/hub" /usr/local/bin
  rm -rf "hub-linux-amd64-${HUB_VERSION}"
  rm -f "hub-linux-amd64-${HUB_VERSION}.tgz*"
fi

# install gh
if ! command_exists gh; then
  declare GH_VERSION="0.5.5"
  info "installing gh ($GH_VERSION)"
  rm -f "gh_*_linux_amd64.deb"
  wget "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.deb"
  dpkg -i "gh_${GH_VERSION}_linux_amd64.deb"
  rm -f "gh_${GH_VERSION}_linux_amd64.deb"
fi

# install fd
if ! command_exists fd; then
  declare FD_VERSION="7.4.0"
  info "installing fd ($FD_VERSION)"
  wget "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb"
  dpkg -i fd_${FD_VERSION}_amd64.deb
  rm -f fd_${FD_VERSION}_amd64.deb
fi

timedatectl set-timezone America/Los_Angeles
