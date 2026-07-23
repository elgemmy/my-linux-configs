ARG BASE_IMAGE=debian:stable-slim
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash tester \
    && printf 'tester ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/tester \
    && chmod 0440 /etc/sudoers.d/tester

COPY run-smoke.sh /usr/local/bin/run-smoke
RUN chmod 0755 /usr/local/bin/run-smoke

USER tester
WORKDIR /home/tester
ENTRYPOINT ["/usr/local/bin/run-smoke"]
