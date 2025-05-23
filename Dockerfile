FROM rust:1.85.0-slim
USER root

ENV RUNNING_IN_DOCKER=true

################################################
# basics
################################################

RUN apt update && apt upgrade -y && apt install -yq \
    stow git vim curl gnupg2 sudo wget file zip unzip build-essential libssl-dev \
    libwebkit2gtk-4.1-dev libxdo-dev libayatana-appindicator3-dev librsvg2-dev \
    locales locales-all tzdata \
    && apt clean && rm -rf /var/lib/apt/lists/*

################################################
# locals
################################################

ENV LC_ALL=en_US.UTF-8
ENV LC_TYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

################################################
# shell
################################################

# install fish
RUN echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_12/ /' | tee /etc/apt/sources.list.d/shells:fish:release:3.list
RUN curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_12/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
RUN apt update && apt upgrade -y && apt install -yq \
  fish \
  && apt clean && rm -rf /var/lib/apt/lists/*

# install starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

SHELL ["fish", "-c"]
ENV SHELL=/usr/bin/fish

################################################
# user
################################################

ARG USERNAME=vscode
ARG USER_ID=1000
ARG GROUP_ID=$USER_ID

RUN groupadd -g $GROUP_ID -o $USERNAME
RUN useradd -m -u $USER_ID -g $GROUP_ID -o -s /usr/bin/fish $USERNAME

# add to sudoers
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME

# cache mount points
RUN mkdir -p /home/$USERNAME/.cache && chown $USERNAME:$USERNAME /home/$USERNAME/.cache
RUN mkdir -p /home/$USERNAME/.local && chown $USERNAME:$USERNAME /home/$USERNAME/.local

USER $USERNAME

# install fisher
RUN curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

################################################
# rust
################################################

RUN rustup update

RUN rustup target add \
    aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

RUN rustup component add rustfmt
