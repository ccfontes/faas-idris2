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

RUN addgroup --system app && adduser --system --ingroup app app

ENV HOME="/home/app"
WORKDIR $HOME

RUN cp -r /root/.pack . && find .pack -type l -exec sh -c 'ln -sfn $(readlink "{}" | sed "s|/root/|$HOME/|") "{}"' \;
RUN chown app:app -R /home/app/.pack

USER app
ENV PATH "$HOME/.pack/bin:$PATH"

COPY Index.idr .
RUN mkdir -p Function
COPY function Function
COPY function/function.ipkg function/pack.tom? function/package.jso? function/yarn.loc? ./

RUN if [ -f package.json ]; then yarn install --frozen-lockfile; fi

RUN pack build function.ipkg
# +x for Node Functions
RUN chmod +x build/exec/index

CMD ["fwatchdog"]
