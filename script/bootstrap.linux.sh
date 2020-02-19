#!/bin/bash
set -eu

source "$(dirname "$0")/common.sh"

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  info "Updating and upgrading packages"

  # Add third party repositories
  sudo add-apt-repository ppa:keithw/mosh-dev -y
  sudo add-apt-repository ppa:jonathonf/vim -y

  CLOUD_SDK_SOURCE="/etc/apt/sources.list.d/google-cloud-sdk.list"
  CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
  if [ ! -f "${CLOUD_SDK_SOURCE}" ]; then
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a ${CLOUD_SDK_SOURCE}
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  fi

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
  fakeroot-ng \
  gdb \
  git \
  git-crypt \
  gnupg \
  gnupg2 \
  google-cloud-sdk \
  google-cloud-sdk-app-engine-go \
  htop \
  hugo \
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
  ncdu \
  netcat-openbsd \
  openssh-server \
  pkg-config \
  protobuf-compiler \
  pwgen \
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
  GO_VERSION="1.13"
  info "installing golang ($GO_VERSION)"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" 
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" 
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="/usr/local/go/bin:$PATH"
fi

# install 1password
if ! command_exists op; then
  OP_VERSION="v0.5.6-003"
  info "installing op ($OP_VERSION)"
  curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip
  unzip 1password.zip op -d /usr/local/bin
  rm -f 1password.zip
fi

# install doctl
if ! command_exists doctl; then
  DOCTL_VERSION="1.20.1"
  info "installing doctl ($DOCTL_VERSION)"
  wget https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz
  tar xf doctl-${DOCTL_VERSION}-linux-amd64.tar.gz 
  chmod +x doctl 
  mv doctl /usr/local/bin 
  rm -f doctl-${DOCTL_VERSION}-linux-amd64.tar.gz
fi

# install terraform
if ! command_exists terraform; then
  TERRAFORM_VERSION="0.12.9"
  info "installing terraform ($TERRAFORM_VERSION)"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  chmod +x terraform
  mv terraform /usr/local/bin
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# install hub
if ! command_exists hub; then
  HUB_VERSION="2.12.3"
  info "installing hub ($HUB_VERSION)"
  wget https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz
  tar xf hub-linux-amd64-${HUB_VERSION}.tgz
  chmod +x hub-linux-amd64-${HUB_VERSION}/bin/hub
  cp hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin
  rm -rf hub-linux-amd64-${HUB_VERSION}
  rm -f hub-linux-amd64-${HUB_VERSION}.tgz*
fi

if ! command_exists fd; then
  FD_VERSION="7.4.0"
  info "installing fd ($FD_VERSION)"
  wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb
  dpkg -i fd_${FD_VERSION}_amd64.deb
  rm -f fd_${FD_VERSION}_amd64.deb
fi

info "Creating pull-secret.sh script"
mkdir -p ~/secrets
cat > ~/secrets/pull-secrets.sh <<'EOF'
#!/bin/bash

set -eu

echo "Authenticating with 1Password"
export OP_SESSION_my=$(op signin https://my.1password.com logan.linn@gmail.com --output=raw)

echo "Pulling secrets"

op get document 'github_rsa' > github_rsa
op get document 'zsh_private' > zsh_private
op get document 'zsh_history' > zsh_history

rm -f ~/.ssh/github_rsa
ln -sfn $(pwd)/github_rsa ~/.ssh/github_rsa
chmod 0600 ~/.ssh/github_rsa

ln -sfn $(pwd)/zsh_private ~/.zsh_private
ln -sfn $(pwd)/zsh_history ~/.zsh_history
EOF
chmod +x ~/secrets/pull-secrets.sh

timedatectl set-timezone America/Los_Angeles
