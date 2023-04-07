FROM node:18-bullseye-slim AS node
FROM ghcr.io/openfaas/of-watchdog:0.9.11 AS watchdog
FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-230330

RUN set -e

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
EXPOSE 8080
HEALTHCHECK --interval=2s CMD [ -e /tmp/.lock ] || exit 1

WORKDIR /root
COPY Index.idr .
RUN mkdir -p Function
COPY function Function
COPY function/function.ipkg function/pack.tom? function/package.jso? ./

RUN yarn install --frozen-lockfile
RUN pack build function.ipkg
# +x for Node Functions
RUN chmod +x build/exec/index

CMD ["fwatchdog"]
