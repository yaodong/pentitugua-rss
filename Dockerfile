FROM ubuntu:16.04

RUN apt-get update -qq && apt-get install -qq python3 python3-pip git -y

RUN ["git", "config", "--global", "user.name", "newsboy"]
RUN ["git", "config", "--global", "user.email", "newsboy@pentitutgua.com"]

COPY keys /root/.ssh
RUN chmod 0600 /root/.ssh/id_rsa
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ["ssh-agent", "bash", "-c", "ssh-add /root/.ssh/id_rsa"]

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENV UPDATED_AT=1507740121
RUN git clone git@github.com:yaodong/pentitugua-rss.git /srv/pentitugua

WORKDIR /srv/pentitugua

RUN pip3 install -U pip
RUN pip3 --no-cache-dir install -r requirements.txt

CMD ["bash", "scheduled.sh"]
