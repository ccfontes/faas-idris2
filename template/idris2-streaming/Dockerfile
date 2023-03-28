# https://github.com/openfaas/of-watchdog
FROM ghcr.io/openfaas/of-watchdog:0.9.11 as watchdog

FROM ubuntu:20.04

RUN set -e

## Install Pack and Idris 2 ##

RUN apt-get update && apt-get install --yes curl chezscheme git make gcc libgmp3-dev

WORKDIR /home/app

# Needed for idris2_install script
ENV HOME /home/app

RUN curl -o idris2_install https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash
RUN sh -c "echo 'chezscheme' | bash ./idris2_install"

COPY Index.idr .
RUN mkdir -p Function
COPY function Function
COPY function/function.ipkg function/pack.tom? .

ENV PATH $HOME/.pack/bin:$PATH

RUN apt-get purge --yes make gcc curl libgmp3-dev && rm -rf /var/lib/apt/lists/*

## Build Function ##
RUN pack build function.ipkg
RUN rm Index.idr
RUN rm -rf Function

## OpenFaaS ##

# Function invoke time error:
#   mkdir: cannot create directory '/home/app/.pack/.tmp0': Permission denied
#   /home/app/.pack/bin/idris2: 7: [: missing ]
# FIXME: fix errors above for this user:
# RUN groupadd app && useradd -g app app
# USER app:app

ENV mode="streaming"

EXPOSE 8080

HEALTHCHECK --interval=2s CMD [ -e /tmp/.lock ] || exit 1

# FIXME: add `--chown=app` to COPY below after permission errors are fixed 
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

CMD ["fwatchdog"]
