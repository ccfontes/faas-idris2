ARG CODEGEN="chez"

FROM akkuscm/akku:latest as akku
FROM node:18-bullseye-slim AS node
FROM racket/racket:8.8 AS racket
FROM ghcr.io/openfaas/of-watchdog:0.9.11 AS watchdog
FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-230330 AS idris2-pack

FROM idris2-pack AS idris2-node
ONBUILD COPY --from=node /usr/local/bin/node /usr/local/bin/node
ONBUILD COPY --from=node /opt/yarn-* /opt/yarn
ONBUILD RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

FROM idris2-pack AS idris2-racket
ONBUILD RUN apt-get update && apt-get install --yes racket && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM idris2-pack AS idris2-chez
ONBUILD COPY --from=akku /root/.local /root/.local

FROM idris2-${CODEGEN}

ARG CODEGEN

RUN set -e

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
EXPOSE 8080
HEALTHCHECK --interval=2s CMD [ -e /tmp/.lock ] || exit 1

RUN addgroup --system app && adduser --system --ingroup app app

ENV HOME="/home/app"

RUN mv /root/.pack $HOME && find $HOME/.pack -type l -exec sh -c 'ln -sfn $(readlink "{}" | sed "s|/root/|$HOME/|") "{}"' \;
RUN chown app:app -R $HOME/.pack

RUN if [ -f "/root/.local/bin/akku" ]; then mv /root/.local $HOME; fi
RUN if [ -f "/root/.local/bin/akku" ]; then chown app:app -R $HOME/.local; fi

USER app
ENV PATH "$HOME/.pack/bin:$HOME/.local/bin:$PATH"
WORKDIR $HOME

COPY Index.idr .
RUN mkdir -p Function
COPY function Function
COPY function/function.ipkg function/pack.tom? function/package.jso? function/yarn.loc? Akku.manifes? Akku.loc? ./

RUN if [ -f "package.json" ]; then yarn install --frozen-lockfile; fi
RUN if [ -f "Akku.manifest" ]; then akku update && akku install; fi
RUN pack --cg ${CODEGEN} build function.ipkg
# +x for node Functions
RUN chmod +x build/exec/index

CMD ["fwatchdog"]
