FROM dart:stable

RUN dart --disable-analytics

RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    libgnutls28-dev \
    uuid-dev

# toc: https://taskwarrior.org/docs/taskserver/setup.html

# 2.1: Installation;
# https://taskwarrior.org/docs/taskserver/git.html

RUN curl -O https://taskwarrior.org/download/taskd-1.1.0.tar.gz \
    && tar xzf taskd-1.1.0.tar.gz \
    && cd taskd-1.1.0 \
    && cmake . \
    && make \
    && make install \
    && cd .. \
    && rm -r taskd-1.1.0

RUN curl -O https://taskwarrior.org/download/task-2.5.3.tar.gz \
    && tar xzf task-2.5.3.tar.gz \
    && cd task-2.5.3 \
    && cmake -DCMAKE_BUILD_TYPE=release . \
    && make \
    && make install \
    && cd .. \
    && rm -r task-2.5.3
