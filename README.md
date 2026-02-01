# Poem 项目部署指南

本文档描述如何使用提供的脚本和Dockerfile部署Poem项目。

## 文件说明

1. **deploy.ps1** - PowerShell部署脚本
    - 清空 `backend/static` 文件夹
    - 打包前端Flutter web项目
    - 拷贝前端构建产物到 `backend/static`

2. **Dockerfile** - Docker镜像构建文件
    - 多阶段构建：构建阶段和运行阶段
    - 基于Alpine Linux的轻量级镜像
    - 包含健康检查、非root用户运行等最佳实践

## 使用步骤

### 1. 运行部署脚本

在PowerShell中执行：

```powershell
.\deploy.ps1
```

### 2. 上传后端工程

将backend文件夹打包成zip，上传到服务器`/docker/poem/backend`文件夹下，进行解压。

### 3. 构建Docker镜像

在`/docker/poem`下执行：

```bash
docker build -t poem .
```

### 4. 运行Docker容器

```bash
docker run -d \
--name poem \
-p 8163:8163 \
-v $(pwd)/data:/app/data \
poem
```