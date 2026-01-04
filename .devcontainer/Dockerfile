# Development Container
# Provides a consistent development environment across all machines

FROM texlive/texlive:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    make \
    git \
    curl \
    wget \
    # Spell checking
    aspell \
    aspell-en \
    # PDF utilities (for stats, checking ??)
    poppler-utils \
    # Java (for bib2gls, PlantUML)
    default-jre-headless \
    # Python (for pre-commit)
    python3 \
    python3-pip \
    python3-venv \
    # Graphics libraries (for draw.io)
    graphicsmagick \
    xvfb \
    # Editor/terminal utilities
    less \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install PlantUML with PDF support (requires Batik)
RUN curl -L https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-pdf-1.2024.8.jar \
    -o /usr/local/bin/plantuml.jar \
    && echo '#!/bin/bash\njava -jar /usr/local/bin/plantuml.jar "$@"' > /usr/local/bin/plantuml \
    && chmod +x /usr/local/bin/plantuml

# Install pre-commit
RUN pip3 install --no-cache-dir --break-system-packages pre-commit

# Create non-root user for VS Code
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if getent group $USER_GID >/dev/null 2>&1; then \
    echo "Group $USER_GID already exists, reusing it"; \
    else \
    groupadd --gid $USER_GID $USERNAME; \
    fi \
    && if id -u $USER_UID >/dev/null 2>&1; then \
    echo "User with UID $USER_UID already exists, modifying"; \
    usermod -l $USERNAME -d /home/$USERNAME -m $(id -nu $USER_UID) || true; \
    else \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    fi \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Switch to non-root user
USER $USERNAME

# Verify installations
RUN echo "=== Verifying installations ===" \
    && pdflatex --version | head -1 \
    && biber --version | head -1 \
    && latexmk --version | head -1 \
    && texcount --version 2>&1 | head -1 \
    && aspell --version | head -1 \
    && bib2gls --version 2>&1 | head -1 \
    && pre-commit --version \
    && plantuml -version | head -1 \
    && python3 --version \
    && java -version 2>&1 | head -1 \
    && echo "=== All tools installed successfully ==="

# Default command
CMD ["bash"]
