FROM ubuntu:22.04
LABEL maintainer="Fan <232040373@hdu.edu.cn>"

# 设置工作目录
WORKDIR /root/workspace

# 更改 APT 镜像源为清华镜像源
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|' /etc/apt/sources.list && \
    sed -i 's|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/|' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/|' /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y

# 安装 C++ 编译器、网络、ssh、cmake、git 及常用开发工具
RUN apt-get update && apt-get install -y \
    build-essential \
    bash \
    curl \
    wget \
    net-tools \
    openssh-server \
    cmake \
    git \
    vim \
    htop \
    file \
    iputils-ping \
    python3-pip \
    python3-venv && \
    rm -rf /var/lib/apt/lists/*

# 暴露 22、8080、8097 端口
EXPOSE 22 8080 8097

# 创建 SSH 目录并添加 SSH 公钥
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# 创建 /run/sshd 目录
RUN mkdir -p /run/sshd && chmod 755 /run/sshd

# 复制本地的 id_ed25519.pub 公钥到容器中的 authorized_keys 文件
COPY id_ed25519.pub /root/.ssh/authorized_keys

# 设置 authorized_keys 文件权限
RUN chmod 600 /root/.ssh/authorized_keys

# 生成 SSH 主机密钥
RUN ssh-keygen -A

# ----------------------------------- Conda 环境 ----------------------------------------
# # 动态下载适合主机架构的 Miniconda 安装包
# RUN ARCH=$(uname -m) && \
#     if [ "$ARCH" = "x86_64" ]; then \
#         curl -sSL https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh; \
#     elif [ "$ARCH" = "aarch64" ]; then \
#         curl -sSL https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-aarch64.sh -o miniconda.sh; \
#     else \
#         echo "Unsupported architecture: $ARCH" && exit 1; \
#     fi && \
#     bash miniconda.sh -b -p /opt/conda && \
#     rm -f miniconda.sh

# # 配置 Miniconda 环境
# ENV PATH=/opt/conda/bin:$PATH

# # 配置 pip 镜像源为清华大学镜像
# RUN mkdir -p /root/.config/pip && echo "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" > /root/.config/pip/pip.conf

# # # 创建并激活 conda 环境 py312
# # RUN conda create -y -n py312 python=3.12 pip
# RUN conda init

# ----------------------------------- python3 -m venv 环境 ----------------------------------------
# 创建并激活 python3 虚拟环境 base
RUN python3 -m venv /root/base

# 设置 base 默认虚拟环境路径（即使不进入base，也默认使用这个路径下的python）
ENV PATH="/root/base/bin:$PATH"

# 在 .bashrc 中添加激活虚拟环境的命令
RUN echo "source /root/base/bin/activate" >> /root/.bashrc

# 启动 SSH 服务
CMD ["/bin/bash", "-c", "/usr/sbin/sshd -D"]
