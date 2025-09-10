FROM docker.io/nodered/node-red:4.1.0-22@sha256:67379336a26c5da5662415816161c3fe3fb0e75259b8da08712caef2bbdb4645

WORKDIR /data
COPY package.json /data
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production
WORKDIR /usr/src/node-red