FROM gitpod/workspace-full

ENV TRIGGER_REBUILD=1

ENV PATH=/home/linuxbrew/.linuxbrew/opt/conan@1/bin:$PATH
RUN brew install conan@1

RUN echo "fish" >> ~/.bashrc
