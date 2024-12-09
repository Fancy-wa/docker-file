#!/bin/bash


# 检查用户是否输入了值，如果没有，则默认为0
if [ $# -gt 0 ]; then
    INDEX=$1
else
    # 显示菜单并提示用户选择
    echo "You are running task"
    echo "Launch menu..."
    echo ""
    echo "0. docker build       # 根据Dockerfile构建镜像（默认）"
    echo "1. docker run         # 根据构建的镜像创建容器"
    echo "2. docker exec        # 在容器中创建一个新的终端并进入"
    echo "3. docker start       # 运行已经存在的容器"
    echo "4. docker stop        # 停止已经存在的容器"
    echo "5. docker attach      # 进入容器创建时的终端"
    echo "99. docker ps -a      # 查看所有容器状态"
    read -p "Which one do you want? [0]: " INDEX
    if [ -z "$INDEX" ]; then
        INDEX=0
    fi
fi

echo ""

# 定义 镜像名、镜像标签 和 容器名
IMAGE_NAME="fantasy"
IMGAE_TAG="ubuntu22.04-py310-dev"
CONTAINER_NAME="framework"

case $INDEX in
    0)
        docker build -t $IMAGE_NAME:$IMGAE_TAG .
        # 创建镜像
        ;;
    1)
        docker run -d -p 22:22 --name $CONTAINER_NAME $IMAGE_NAME:$IMGAE_TAG
        # 创建容器后台运行
        ;;
    2)
        docker exec -it $CONTAINER_NAME /bin/bash
        # 在容器中创建一个新的终端并进入
        ;;
    3)
        docker start $CONTAINER_NAME
        # 运行已经存在的容器
        ;;
    4)
        docker stop $CONTAINER_NAME
        # 停止已经存在的容器
        ;;
    5)
        docker attach $CONTAINER_NAME
        # 进入容器创建时的终端
        ;;
    99)
        docker ps -a
        # 查看所有容器状态
        ;;
    *)
        echo "Usage: $0 {0: docker build | 1: docker run | 2: docker exec | 3: docker start | 4: docker stop | 5: docker attach | 99: docker ps -a}"
        exit 1
        ;;
esac
