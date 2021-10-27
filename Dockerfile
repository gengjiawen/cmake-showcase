# https://github.com/JetBrains/projector-docker
FROM registry.jetbrains.team/p/prj/containers/projector-clion

USER root
RUN apt update && apt install curl -y

RUN mkdir -p ~/.cache && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/:$PATH
ENV MANPATH="$MANPATH:/home/linuxbrew/.linuxbrew/share/man" \
    INFOPATH="$INFOPATH:/home/linuxbrew/.linuxbrew/share/info" \
    HOMEBREW_NO_AUTO_UPDATE=1

RUN chown root /home/linuxbrew/.linuxbrew/bin/brew

# add homebrew end

RUN brew install gcc golang fish

RUN brew install n && n latest
