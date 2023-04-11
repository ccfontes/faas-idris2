ARG CODEGEN="chez"

FROM node:18-bullseye-slim AS node
FROM racket/racket:8.8 AS racket
FROM ghcr.io/openfaas/of-watchdog:0.9.11 AS watchdog
FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-230330 AS idris2-chez

FROM idris2-chez AS idris2-node
ONBUILD COPY --from=node /usr/local/bin/node /usr/local/bin/node
ONBUILD COPY --from=node /opt/yarn-* /opt/yarn
ONBUILD RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

FROM idris2-chez AS idris2-racket
ONBUILD RUN apt-get update && apt-get install --yes --no-install-recommends racket=8.2+dfsg1-2ubuntu1 && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM idris2-${CODEGEN}

ARG CODEGEN

RUN set -e

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
EXPOSE 8080
HEALTHCHECK --interval=2s CMD [ -e /tmp/.lock ] || exit 1

ENV HOME="/home/app" 

RUN addgroup --system app && adduser --system --ingroup app app && \
    mv /root/.pack $HOME && \
    find $HOME/.pack -type l -exec sh -c 'for link; do target=$(readlink "$link"); new_target=$(echo "$target" | sed "s|/root/|$HOME/|"); ln -sfn "$new_target" "$link"; done' _ {} + && \
    chown app:app -R $HOME/.pack

USER app
ENV PATH "$HOME/.pack/bin:$PATH"
WORKDIR $HOME

COPY Index.idr .
RUN mkdir -p Function
COPY function Function
COPY function/function.ipkg function/pack.tom? function/package.jso? function/yarn.loc? ./

# hadolint ignore=DL3006
RUN if [ -f "package.json" ]; then yarn install --frozen-lockfile && yarn cache clean; fi && \
    pack --cg ${CODEGEN} build function.ipkg && \
    # +x for node Functions
    chmod +x build/exec/index

CMD ["fwatchdog"]
