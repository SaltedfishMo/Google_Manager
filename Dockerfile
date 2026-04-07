# 阶段一：使用 Node.js 构建前端静态文件
FROM node:18-alpine AS frontend-builder

WORKDIR /build

COPY frontend/package*.json ./frontend/
COPY frontend/ ./frontend/

WORKDIR /build/frontend
RUN npm config set registry https://registry.npmmirror.com && \
    npm install && \
    npm run build

# 阶段二：配置 Python Flask 后端运行环境
FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TZ=Asia/Shanghai

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY . .

# 从阶段一复制构建好的前端静态文件
COPY --from=frontend-builder /build/static ./static

EXPOSE 8002

# 创建数据存储目录
RUN mkdir -p /app/instance

# 初始化并启动
CMD sh -c "python migrate_db.py && python migrate_history.py && python run.py"
