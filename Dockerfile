FROM ubuntu:16.04

RUN apt-get update -qq && apt-get install -qq python3 python3-pip git -y
RUN pip3 install -U pip

RUN ["git", "config", "--global", "user.name", "newsboy"]
RUN ["git", "config", "--global", "user.email", "newsboy@pentitutgua.com"]

COPY keys /root/.ssh
RUN chmod 0600 /root/.ssh/id_rsa
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ["ssh-agent", "bash", "-c", "ssh-add /root/.ssh/id_rsa"]

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ADD https://raw.githubusercontent.com/yaodong/pentitugua-rss/master/scheduled.sh /root/scheduled.sh

CMD ["bash", "/root/scheduled.sh"]
