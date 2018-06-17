#
# GitLab CI: Android v1
#
# https://hub.docker.com/r/drakor/gitlab-ci-android/
#

FROM ubuntu:16.04
MAINTAINER Fernando Anthony Ristaño <fernando.ristano@gmail.com>

# Tools 26.1.1
ENV VERSION_SDK_TOOLS "4333796"
ENV VERSION_BUILD_TOOLS "26.0.2"
ENV VERSION_TARGET_SDK "26"

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

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
    
RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN wget -nv https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip && unzip sdk-tools-linux-${VERSION_SDK_TOOLS}.zip -d /sdk && \
rm -v sdk-tools-linux-${VERSION_SDK_TOOLS}.zip

RUN wget -nv https://pypi.python.org/packages/1e/8e/40c71faa24e19dab555eeb25d6c07efbc503e98b0344f0b4c3131f59947f/vnc2flv-20100207.tar.gz && tar -zxvf vnc2flv-20100207.tar.gz && rm vnc2flv-20100207.tar.gz && \
    cd vnc2flv-20100207 && ln -s /usr/bin/python2.7 /usr/bin/python && python setup.py install

RUN mkdir /sdk/tools/keymaps && \
    touch /sdk/tools/keymaps/en-us

RUN echo "y" | /sdk/tools/bin/sdkmanager --update
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "build-tools;${VERSION_BUILD_TOOLS}"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "platforms;android-${VERSION_TARGET_SDK}"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "system-images;android-${VERSION_TARGET_SDK};google_apis;x86"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "system-images;android-${VERSION_TARGET_SDK};google_apis_playstore;x86"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "extras;google;google_play_services" 
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "extras;google;m2repository"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "extras;android;m2repository"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "add-ons;addon-google_apis-google-24"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "platform-tools"
RUN echo "y" | /sdk/tools/bin/sdkmanager --install "emulator"

RUN mkdir /helpers

COPY wait-for-avd-boot.sh /helpers

