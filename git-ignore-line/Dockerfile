# https://github.com/bats-core/bats-core/blob/v1.2.1/Dockerfile
FROM bats/bats:1.2.1 AS bats

FROM bitnami/git:2.28.0-debian-10-r14

RUN ln -s /opt/bats/bin/bats /usr/sbin/bats
COPY --from=bats /opt/bats/ /opt/bats/

WORKDIR /git-ignore-line
RUN git init \
    && git config --local user.email "test@email.com" \
    && git config --local user.name "Test User" \
    && git config --local filter.ignore-line.smudge "$PWD/git-ignore-line.sh --smudge %f" \
    && git config --local filter.ignore-line.clean "$PWD/git-ignore-line.sh --clean %f"

COPY . .

RUN git add . && git commit -m'Initial test repo commit'
#ENTRYPOINT ["sh", "/usr/sbin/bats"]
ENTRYPOINT ["sh", "/git-ignore-line/test1.sh"]
