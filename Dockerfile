FROM python:3.11-slim

WORKDIR /app

# 安装cron服务
RUN apt-get update && apt-get install -y cron procps

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

# 创建启动脚本
RUN echo '#!/bin/bash\n\
CRON_TIME=${RESTART_TIME:-"0 2 * * *"}\n\
echo "$CRON_TIME root pkill -f \"python app.py\" && cd /app && python app.py" > /etc/cron.d/app-restart\n\
chmod 0644 /etc/cron.d/app-restart\n\
crontab /etc/cron.d/app-restart\n\
cron\n\
python app.py\n'\
> /app/start.sh && chmod +x /app/start.sh

EXPOSE 5005

# 使用启动脚本替代直接运行应用
CMD ["/app/start.sh"]
