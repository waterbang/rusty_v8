FROM ghcr.io/cross-rs/aarch64-linux-android:edge
# FROM waterbang/aarch64-linux-android:v1

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update 
# && \
# 	apt-get install -y curl && \
# 	curl -L https://github.com/mozilla/sccache/releases/download/v0.2.15/sccache-v0.2.15-x86_64-unknown-linux-musl.tar.gz | tar xzf -

RUN  apt-get install -y libmysqlclient-dev tzdata  \
	python3 python3-dev python3-pip libpcre3 libpcre3-dev  uwsgi-plugin-python3

RUN  ln -sf /usr/bin/python3 /usr/bin/python

RUN apt-get install -y libglib2.0-dev




# COPY ./build/*.sh /chromium_build/
# RUN \
# 	DEBIAN_FRONTEND=noninteractive \
# 	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
# 	&& apt-get update && apt-get install -y lsb-release sudo \
# 	&& /chromium_build/install-build-deps-android.sh \
# 	&& rm -rf /chromium_build \
# 	&& rm -rf /var/lib/apt/lists/*

# RUN chmod +x /sccache-v0.2.15-x86_64-linux-android/sccache

# ENV SCCACHE=/sccache-v0.2.15-x86_64-linux-android/sccache
# ENV SCCACHE_DIR=./target/sccache
