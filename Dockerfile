#
# GitLab CI: Android v1
#
# https://hub.docker.com/r/drakor/gitlab-ci-android/
#

FROM ubuntu:16.04
MAINTAINER Fernando Anthony Ristaño <fernando.ristano@gmail.com>

ENV VERSION_SDK_TOOLS "25.2.5"
ENV VERSION_BUILD_TOOLS "25.0.3"
ENV VERSION_TARGET_SDK "25"

ENV SDK_PACKAGES "build-tools-${VERSION_BUILD_TOOLS},android-${VERSION_TARGET_SDK},addon-google_apis-google-${VERSION_TARGET_SDK},platform-tools,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository,sys-img-x86-android-${VERSION_TARGET_SDK},sys-img-x86-google_apis-${VERSION_TARGET_SDK},extra-google-google_play_services,extra-google-m2repository,extra-android-m2repository"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

# Accept License

RUN mkdir -p $ANDROID_HOME/licenses/
RUN echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      curl \
      html2text \
      openjdk-8-jdk \
      git \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      qtbase5-dev \
      qtdeclarative5-dev \
      wget \
      qemu-kvm \
      build-essential \
      python2.7 \
      python2.7-dev \
      yamdi \
      locales \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
    
RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN wget -nv http://dl.google.com/android/repository/tools_r${VERSION_SDK_TOOLS}-linux.zip && unzip tools_r${VERSION_SDK_TOOLS}-linux.zip -d /sdk && \
    rm -v tools_r${VERSION_SDK_TOOLS}-linux.zip

RUN wget -nv https://pypi.python.org/packages/1e/8e/40c71faa24e19dab555eeb25d6c07efbc503e98b0344f0b4c3131f59947f/vnc2flv-20100207.tar.gz && tar -zxvf vnc2flv-20100207.tar.gz && rm vnc2flv-20100207.tar.gz && \
    cd vnc2flv-20100207 && ln -s /usr/bin/python2.7 /usr/bin/python && python setup.py install

RUN mkdir /sdk/tools/keymaps && \
    touch /sdk/tools/keymaps/en-us

RUN echo "y" | /sdk/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services
RUN echo "y" | /sdk/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository
RUN echo "y" | /sdk/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository

RUN mkdir /helpers

COPY wait-for-avd-boot.sh /helpers

RUN (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/android update sdk -u -a -t ${SDK_PACKAGES}
