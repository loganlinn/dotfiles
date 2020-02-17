#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  echo "==> Updating and upgrading packages ..."

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

sudo apt-get install -qq \
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
  fzf \
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
  libclang-dev \
  liblzma-dev \
  libpq-dev \
  libprotoc-dev \
  libsqlite3-dev \
  libssl-dev \
  libvirt-clients \
  libvirt-daemon-system \
  lldb \
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
  tmate \
  tmux \
  tree \
  unzip \
  wget \
  zgen \
  zip \
  zlib1g-dev \
  vim-gtk3 \
  zsh \
  --no-install-recommends \

rm -rf /var/lib/apt/lists/*

# install Go
if ! [ -x "$(command -v go)" ]; then
  export GO_VERSION="1.13"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" 
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" 
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="/usr/local/go/bin:$PATH"
fi

# install 1password
if ! [ -x "$(command -v op)" ]; then
  export OP_VERSION="v0.5.6-003"
  curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip
  unzip 1password.zip op -d /usr/local/bin
  rm -f 1password.zip
fi

# install doctl
if ! [ -x "$(command -v doctl)" ]; then
  export DOCTL_VERSION="1.20.1"
  wget https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz
  tar xf doctl-${DOCTL_VERSION}-linux-amd64.tar.gz 
  chmod +x doctl 
  mv doctl /usr/local/bin 
  rm -f doctl-${DOCTL_VERSION}-linux-amd64.tar.gz
fi

# install terraform
if ! [ -x "$(command -v terraform)" ]; then
  export TERRAFORM_VERSION="0.12.9"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  chmod +x terraform
  mv terraform /usr/local/bin
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# install hub
if ! [ -x "$(command -v hub)" ]; then
  echo " ==> Installing hub .."
  export HUB_VERSION="2.12.3"
  wget https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz
  tar xf hub-linux-amd64-${HUB_VERSION}.tgz
  chmod +x hub-linux-amd64-${HUB_VERSION}/bin/hub
  cp hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin
  rm -rf hub-linux-amd64-${HUB_VERSION}
  rm -f hub-linux-amd64-${HUB_VERSION}.tgz*
fi


echo "==> Creating pull-secret.sh script"
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

echo "Done!"
EOF
chmod +x ~/secrets/pull-secrets.sh


# Set correct timezone
timedatectl set-timezone America/Los_Angeles

echo ""
echo "==> Done!"
