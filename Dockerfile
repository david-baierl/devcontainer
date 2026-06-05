FROM debian:trixie-slim
USER root

ENV RUNNING_IN_DOCKER=true

################################################
# basics
################################################

RUN apt update && apt upgrade -y && apt install -yq \
    stow git vim curl gnupg2 sudo wget file zip unzip \
    locales locales-all tzdata \
    zsh fastfetch \
    && apt clean && rm -rf /var/lib/apt/lists/*

################################################
# locals
################################################

ENV LC_ALL=en_US.UTF-8
ENV LC_TYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

################################################
# user
################################################

ARG USERNAME=vscode
ARG USER_ID=1000
ARG GROUP_ID=$USER_ID

RUN groupadd -g $GROUP_ID -o $USERNAME
RUN useradd -m -u $USER_ID -g $GROUP_ID -o -s /usr/bin/zsh $USERNAME

# add to sudoers
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME

# cache/local mount points
RUN mkdir -p /home/$USERNAME/.cache && chown $USERNAME:$USERNAME /home/$USERNAME/.cache
RUN mkdir -p /home/$USERNAME/.local && chown $USERNAME:$USERNAME /home/$USERNAME/.local

USER $USERNAME

################################################
# shell
################################################

# install starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

SHELL ["zsh", "-c"]
ENV SHELL=/usr/bin/zsh
