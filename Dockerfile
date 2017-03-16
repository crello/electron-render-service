FROM buildpack-deps:jessie-curl

MAINTAINER Mihkel Sokk <mihkelsokk@gmail.com>

ENV RENDERER_ACCESS_KEY=changeme CONCURRENCY=1 WINDOW_WIDTH=1024 WINDOW_HEIGHT=768 NODE_ENV=production \
    ELECTRON_VERSION=1.6.2 ELECTRON_ENABLE_STACK_DUMPING=true ELECTRON_ENABLE_LOGGING=true

WORKDIR /app

# Add subpixel hinting
COPY .fonts.conf /root/.fonts.conf

    # Install the packages needed to run Electron
RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get upgrade -y && \
    apt-get install -y unzip xvfb libgtk2.0-0 ttf-mscorefonts-installer libnotify4 libgconf2-4 libxss1 libnss3 dbus-x11 libosmesa6-dev && \

    # Get Electron
    wget "https://github.com/atom/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-x64.zip" -O electron.zip && \
    unzip electron.zip && rm electron.zip && \

    # Add libosmesa symlink
    ln -s /usr/lib/x86_64-linux-gnu/libOSMesa.so libosmesa.so && \

    # Cleanup
    apt-get remove -y unzip && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY package.json /app/package.json

RUN apt-get update && apt-get install -y nodejs && \
    sed -i '/\"electron\"\:/d' ./package.json && \
    npm install --production --no-optional && \
    apt-get remove -y nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY . /app

EXPOSE 3000
CMD ["sh", "-c", "xvfb-run -e /dev/stdout --server-args=\"-screen 0 ${WINDOW_WIDTH}x${WINDOW_HEIGHT}x24\" ./electron src/server.js"]
