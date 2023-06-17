FROM gitpod/workspace-full

ENV TRIGGER_REBUILD=1

RUN echo "fish" >> ~/.bashrc
