FROM hugmanrique/playpen:latest
LABEL version="1.1"
LABEL author="Hugo Manrique <docker@hugmanrique.me>"

ENV LFS_VERSION 2.3.4
ENV GITLAB_HOST gitlab.example.com

# Install git
RUN apk add --update bash git openssh
RUN apk --no-cache add openssl git curl && \
  curl -sLO https://github.com/github/git-lfs/releases/download/v${LFS_VERSION}/git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
  tar zxvf git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
  mv git-lfs-${LFS_VERSION}/git-lfs /usr/bin/ && \
  git lfs install && \
  rm -rf git-lfs-${LFS_VERSION} && \
  rm -rf git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
  rm -rf /var/cache/apk/*

# Setup ssh to get access to the packages repo on GitLab
ADD id_rsa /root/.ssh/id_rsa

RUN \
  chmod 600 /root/.ssh/id_rsa && \
  eval $(ssh-agent) && \
  echo -e "Host ${GITLAB_HOST}\n\tStrictHostKeyChecking no\n" >> /etc/ssh/ssh_config && \
  ssh-add /root/.ssh/id_rsa

# Install packages
RUN git clone -b runner git@${GITLAB_HOST}:CHANGE_ME_org_name/playpen-packages.git /home/packages

COPY default/ /home/playpen/
COPY entry.sh upload.sh /home/

# Give access to CI runner user
RUN chmod -R 700 /home/