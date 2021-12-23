##########################################
#         构建基础镜像                    #
##########################################
# 
# 指定创建的基础镜像
FROM --platform=$BUILDPLATFORM alpine:latest

# 作者描述信息
MAINTAINER danxiaonuo
# 时区设置
ARG TZ=Asia/Shanghai
ENV TZ=$TZ
# 语言设置
ARG LANG=C.UTF-8
ENV LANG=$LANG
# 平台信息
ARG TARGETOS
ARG TARGETARCH

# 镜像变量
ARG DOCKER_IMAGE=danxiaonuo/overture
ENV DOCKER_IMAGE=$DOCKER_IMAGE
ARG DOCKER_IMAGE_OS=alpine
ENV DOCKER_IMAGE_OS=$DOCKER_IMAGE_OS
ARG DOCKER_IMAGE_TAG=latest
ENV DOCKER_IMAGE_TAG=$DOCKER_IMAGE_TAG

ARG PKG_DEPS="\
      zsh \
      bash \
      bind-tools \
      iproute2 \
      git \
      vim \
      tzdata \
      curl \
      wget \
      lsof \
      zip \
      unzip \
      ca-certificates"
ENV PKG_DEPS=$PKG_DEPS

# dumb-init
# https://github.com/Yelp/dumb-init
ARG DUMBINIT_VERSION=1.2.5
ENV DUMBINIT_VERSION=$DUMBINIT_VERSION

# overture
# https://github.com/shawn1m/overture
ARG OVERTURE_VERSION=v1.8-rc1
ENV OVERTURE_VERSION=$OVERTURE_VERSION

# ***** 安装依赖 *****
RUN set -eux \
   # 修改源地址
   && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
   # 更新源地址并更新系统软件
   && apk update && apk upgrade \
   # 安装依赖包
   && apk add -U --update $PKG_DEPS \
   # 更新时区
   && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
   # 更新时间
   &&  echo ${TZ} > /etc/timezone \
   # 更改为zsh
   &&  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true \
   &&  sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd \
   &&  sed -i -e 's/mouse=/mouse-=/g' /usr/share/vim/vim*/defaults.vim \
   &&  /bin/zsh

# 安装dumb-init
RUN set -eux \
    && wget --no-check-certificate https://github.com/Yelp/dumb-init/releases/download/v${DUMBINIT_VERSION}/dumb-init_${DUMBINIT_VERSION}_x86_64 -O /usr/bin/dumb-init \
    && chmod +x /usr/bin/dumb-init

# 拷贝overture配置文件
COPY conf/overture/* /tmp/

# 安装overture
RUN set -eux \
    && wget --no-check-certificate https://github.com/shawn1m/overture/releases/download/${OVERTURE_VERSION}/overture-${TARGETOS}-${TARGETARCH}.zip -O overture.zip \
    && mkdir /overture \
    && unzip overture.zip -d /overture \
    && mv /overture/overture-${TARGETOS}-${TARGETARCH} /usr/bin/overture \
    && mv -f /tmp/china_ip.txt /overture/ip_network_primary_sample \
    && mv -f /tmp/gfwlist.txt /overture/domain_alternative_sample \
    && mv -f /tmp/config.yml /overture/config.yml \
    && rm -f overture.zip /tmp/* \
    && chmod 775 /usr/bin/overture
  

# 容器信号处理
STOPSIGNAL SIGQUIT

# 入口
ENTRYPOINT ["dumb-init"]

# 运行overture
CMD ["overture", "-v", "-c", "/overture/config.yml"]
