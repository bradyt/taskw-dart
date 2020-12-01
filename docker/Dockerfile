FROM ubuntu:latest

# toc: https://taskwarrior.org/docs/taskserver/setup.html

# 2.2: https://taskwarrior.org/docs/taskserver/tarball.html

RUN apt-get update && apt-get install -y \
        clang \
        cmake \
        curl \
        gnutls-bin \
        libgnutls28-dev \
        taskwarrior \
        uuid-dev

WORKDIR /root/

RUN curl -LO https://taskwarrior.org/download/taskd-1.1.0.tar.gz

RUN tar xzf taskd-1.1.0.tar.gz

WORKDIR /root/taskd-1.1.0

RUN cmake -DCMAKE_BUILD_TYPE=release .

RUN make
RUN make install

# 3: https://taskwarrior.org/docs/taskserver/configure.html

ENV TASKDDATA /var/taskd
RUN mkdir /var/taskd

RUN taskd init

WORKDIR /root/taskd-1.1.0/pki

RUN ./generate

RUN cp client.cert.pem $TASKDDATA
RUN cp client.key.pem  $TASKDDATA
RUN cp server.cert.pem $TASKDDATA
RUN cp server.key.pem  $TASKDDATA
RUN cp server.crl.pem  $TASKDDATA
RUN cp ca.cert.pem     $TASKDDATA

RUN taskd config --force client.cert $TASKDDATA/client.cert.pem
RUN taskd config --force client.key $TASKDDATA/client.key.pem
RUN taskd config --force server.cert $TASKDDATA/server.cert.pem
RUN taskd config --force server.key $TASKDDATA/server.key.pem
RUN taskd config --force server.crl $TASKDDATA/server.crl.pem
RUN taskd config --force ca.cert $TASKDDATA/ca.cert.pem

WORKDIR $TASKDDATA/..

RUN taskd config --force log /dev/stdout

RUN taskd config --force server 0.0.0.0:53589

# 3 https://taskwarrior.org/docs/taskserver/control.html

RUN taskd config debug.tls 2

# 4 https://taskwarrior.org/docs/taskserver/user.html

RUN taskd add org Public
RUN taskd add user 'Public' 'Brady Trainor' > /opt/output

WORKDIR /root/taskd-1.1.0/pki

RUN ./generate.client brady_trainor

# 4 https://taskwarrior.org/docs/taskserver/taskwarrior.html

RUN mkdir ~/.task

RUN cp brady_trainor.cert.pem ~/.task
RUN cp brady_trainor.key.pem  ~/.task
RUN cp ca.cert.pem         ~/.task

RUN task rc.confirmation:no config confirmation -- no

RUN task config taskd.certificate -- ~/.task/brady_trainor.cert.pem
RUN task config taskd.key         -- ~/.task/brady_trainor.key.pem
RUN task config taskd.ca          -- ~/.task/ca.cert.pem

RUN task config taskd.server      -- localhost:53589

RUN task config taskd.credentials -- Public/Brady Trainor/`ls $TASKDDATA/orgs/Public/users`

RUN task config confirmation -- yes

EXPOSE 53589

COPY entrypoint.sh /bin/
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD taskd server --data $TASKDDATA --debug
