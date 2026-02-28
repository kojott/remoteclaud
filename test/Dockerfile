FROM rockylinux:9

RUN dnf -y install tmux git bash which procps-ng && dnf clean all

# Create dev user with home dir
RUN useradd -m -s /bin/bash dev && \
    mkdir -p /home/dev/bin /src/test-project /src/another-project

# Mock claude CLI - simulates interactive session then exits
COPY mock-claude.sh /usr/local/bin/claude
RUN chmod +x /usr/local/bin/claude

# Install cl script (rendered from Jinja2 template)
COPY cl.sh /home/dev/bin/cl
RUN chmod +x /home/dev/bin/cl

# Install tmux config
COPY tmux-cl.conf /home/dev/.tmux-cl.conf

# Init git repos for worktree testing
RUN cd /src/test-project && git init && git config user.email "test@test" && git config user.name "Test" && \
    echo "hello" > README.md && git add . && git commit -m "init" && \
    cd /src/another-project && git init && git config user.email "test@test" && git config user.name "Test" && \
    echo "hello" > README.md && git add . && git commit -m "init"

# Set PATH for dev user
RUN echo 'export PATH=$PATH:/home/dev/bin' >> /home/dev/.bashrc

RUN chown -R dev:dev /home/dev /src

USER dev
WORKDIR /src/test-project
ENV TERM=xterm-256color

CMD ["/bin/bash"]
