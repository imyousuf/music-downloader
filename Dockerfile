FROM imyousuf/go-node-docker-img:latest

ENV FFMPEG_VERSION=3.3.6
WORKDIR /tmp/ffmpeg

RUN apk update && apk add build-base curl nasm tar gzip bzip2 \
  zlib-dev openssl-dev yasm-dev lame-dev libogg-dev curl-dev \
  x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev \
  libtheora-dev opus-dev openssl python && \
  DIR=$(mktemp -d) && cd ${DIR} && echo ${DIR} && \
  curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
  cd ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libass --enable-libwebp --enable-postproc --enable-avresample --enable-libfreetype --enable-openssl --disable-debug && \
  make && \
  make install && \
  make distclean && \
  rm -rf ${DIR} && \
  curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && \
  chmod a+rx /usr/local/bin/youtube-dl && \
  apk del build-base curl tar bzip2 x264 nasm && rm -rf /var/cache/apk/*


RUN mkdir -p /go/src/github.com/imyousuf/music-downloader/
WORKDIR /go/src/github.com/imyousuf/music-downloader/
ADD Makefile .
RUN make dep-tools
ADD Gopkg.lock .
ADD Gopkg.toml .
RUN mkdir -p ./web/music-downloader/
ADD ./web/music-downloader/package.json ./web/music-downloader/
ADD ./web/music-downloader/package-lock.json ./web/music-downloader/
RUN make deps
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
ADD . .
RUN make test install setup-docker
EXPOSE 8080
CMD ["music-downloader"]
