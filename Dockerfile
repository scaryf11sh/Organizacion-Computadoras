FROM quay.io/archlinux/archlinux:latest

ENV TERM=xterm-256color

# Actualizar e instalar dependencias necesarias
RUN pacman -Syu --noconfirm --disable-sandbox && \
  pacman -S --noconfirm --disable-sandbox \
  git \
  neovim \
  ripgrep \
  fd \
  unzip \
  base-devel \
  clang \
  nasm \
  make \
  curl

# Clonar tu subrepo público de AstroNvim
RUN git clone https://github.com/scaryf11sh/dotfiles-nvim.git /root/dotfiles-nvim

# Copiar tu configuración de AstroNvim al contenedor
RUN mkdir -p /root/.config/nvim && \
  cp -r /root/dotfiles-nvim/* /root/.config/nvim/

WORKDIR /workspace

