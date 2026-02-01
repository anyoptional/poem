FROM golang:1.24-alpine AS builder

# 安装必要的构建工具
RUN apk add --no-cache git

# 设置 Go 代理和模块设置以加速下载（使用多个国内镜像源）
ENV GOPROXY=https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,https://goproxy.io,direct
ENV GOSUMDB=sum.golang.google.cn
ENV GO111MODULE=on

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件
COPY backend/go.mod backend/go.sum ./

# 下载依赖（先整理模块，然后下载）
RUN go mod tidy && go mod download

# 复制后端源代码
COPY backend/ ./

# 构建可执行文件
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o poem.out

# 运行阶段
FROM alpine:latest

# 安装必要的运行时依赖（包括 wget 用于健康检查）
RUN apk add --no-cache ca-certificates tzdata wget

# 设置时区为上海
ENV TZ=Asia/Shanghai

# 创建非root用户
RUN addgroup -g 1000 poem && \
    adduser -u 1000 -G poem -s /bin/sh -D poem

# 设置工作目录
WORKDIR /app

# 从构建阶段复制可执行文件
COPY --from=builder --chown=poem:poem /app/poem.out .

# 确保可执行文件有执行权限
RUN chmod +x poem.out

# 复制前端静态文件（假设已经通过 deploy_frontend.ps1 构建）
COPY --chown=poem:poem backend/static ./static
COPY --chown=poem:poem backend/.env ./.env

# 创建必要的目录
RUN mkdir -p /app/data && chown -R poem:poem /app/data

# 切换到非root用户
USER poem

# 暴露端口
EXPOSE 8163

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8163/health || exit 1

# 设置环境变量
ENV GIN_MODE=release

# 运行应用程序（使用 shell 形式以确保正确执行）
CMD ./poem.out
