ARG ALPINE_VERSION=3.19

FROM alpine:${ALPINE_VERSION}

WORKDIR /

RUN <<EOF 
  apk add --no-cache nodejs   
  apk add --no-cache npm   
EOF

WORKDIR /opt/

ADD https://argus-academy.com/cursos/docker_-_dominando_a_criacao_e_o_gerenciamento_de_containers/server.tar.gz ./code/

WORKDIR /opt/code/

RUN tar xzvf server.tar.gz \
  && rm server.tar.gz 

CMD [ "/bin/sh", "-c", "node server.js" ]

#ENTRYPOINT [ "node" ]
#CMD [ "server.js" ]