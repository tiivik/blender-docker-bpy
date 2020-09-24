FROM ubuntu

MAINTAINER zocker_160

ENV DEBIAN_FRONTEND noninteractive

ARG PYTHON_VER=3.7.9

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    cmake \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    libx11-dev \
    libxxf86vm-dev \
    libxcursor-dev \
    libxi-dev \
    libxrandr-dev \
    libxinerama-dev \
    libglew-dev \
    subversion \
    zlib1g-dev \
    sudo \
    ncdu

# install Blender dependencies
#RUN apt-get install -y build-essential git subversion cmake libx11-dev libxxf86vm-dev libxcursor-dev libxi-dev libxrandr-dev libxinerama-dev libglew-dev

# install python
WORKDIR /home/tmp/python
ADD https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz Python.tgz
RUN tar xzf Python.tgz
WORKDIR /home/tmp/python/Python-$PYTHON_VER
RUN ./configure --enable-optimizations
RUN make -j14 install

WORKDIR /home/tmp
RUN git clone https://git.blender.org/blender.git

WORKDIR /home/tmp/lib
RUN svn checkout https://svn.blender.org/svnroot/bf-blender/trunk/lib/linux_centos7_x86_64

WORKDIR /home/tmp/blender

RUN make update
RUN make -j14 bpy

RUN mv /home/tmp/build_linux_bpy/bin/bpy.so /usr/local/lib/python3.7/site-packages
RUN mv /home/tmp/lib/linux_centos7_x86_64/python/lib/python3.7/site-packages/2.91 /usr/local/lib/python3.7/site-packages/

# cleanup
RUN apt-get autoclean \
	&& apt-get -y autoremove \	
	&& rm -rf /var/lib/apt/lists/*

RUN rm -rf /home/tmp

WORKDIR /home

CMD bash

#RUN python3 -c "import bpy;print(dir(bpy.types));"


#FROM python:3.7.9-buster

#RUN apt-get update && apt-get install -y sudo

#COPY --from=builder /home/docker/build_linux_bpy/bin/bpy.so /usr/local/lib/python3.7/site-packages
#COPY --from=builder /home/docker/lib/linux_centos7_x86_64/python/lib/python3.7/site-packages/2.91 /usr/local/lib/python3.7/site-packages/

#WORKDIR /tmp
#ADD https://raw.githubusercontent.com/sobotka/blender/master/build_files/build_environment/install_deps.sh install_deps.sh
#RUN chmod +x install_deps.sh && ./install_deps.sh

#WORKDIR /home/blender

#CMD bash
