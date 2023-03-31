FROM node:18-bullseye-slim AS node
FROM ghcr.io/openfaas/of-watchdog:0.9.11 AS watchdog
FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-230330

RUN set -e

WORKDIR /root

# node / yarn setup
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

# copy source files to the right places ##
COPY Index.idr .
RUN mkdir -p Function
COPY function Function
COPY function/function.ipkg function/pack.tom? function/package.jso? .

RUN test package.json && yarn install --frozen-lockfile

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Build Function
RUN pack build function.ipkg
RUN rm -rf build/ttc
RUN chmod +x build/exec/index

# OpenFaaS
ENV mode="streaming"
EXPOSE 8080
HEALTHCHECK --interval=2s CMD [ -e /tmp/.lock ] || exit 1
CMD ["fwatchdog"]
