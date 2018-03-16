#!/bin/bash

if [[ ! -f /ci_runned ]] ; then
  bash /home/upload.sh
fi

# Fixes https://gitlab.com/gitlab-org/gitlab-runner/issues/2339
[[ $CI ]] && touch /ci_runned

exec "$@"