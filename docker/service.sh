#!/usr/bin/env bash

## Usage:
# test.sh [<DEBUG_LEVEL> [<JUPYTER_PORT>]]
#
# Arguments:
#   <DEBUG_LEVEL>  : [default: 0]
#   <JUPYTER_PORT>  : [default: 8888]
##

[ -f .bashrc ] && . .bashrc
DEBUG="${1:-0}"
JUPYTER_PORT="${2:-8888}"

stop_service()
{
  echo "stopping jobs"
  for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null

  if [ "$DEBUG" != 0 ]; then
    if [ -f gadgetron.log ]; then
      echo "----------- Last 70 lines of gadgetron.log"
      tail -n 70 gadgetron.log
    fi
  fi

  exit 0
}

pushd $SIRF_PATH/../..

# start gadgetron
GCONFIG=./INSTALL/share/gadgetron/config/gadgetron.xml
[ -f "$GCONFIG" ] || cp "$GCONFIG".example "$GCONFIG"
[ -f ./INSTALL/bin/gadgetron ] && ./INSTALL/bin/gadgetron >& gadgetron.log&

# start jupyter
if [ ! -f ~/.jupyter/jupyter_notebook_config.py ]; then
  jupyter notebook --generate-config
  echo "c.NotebookApp.password = u'sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c'" \
  >> ~/.jupyter/jupyter_notebook_config.py
fi
pushd /devel
[ -d SIRF-Exercises ] || cp -a $SIRF_PATH/../../../SIRF-Exercises .
jupyter notebook --ip 0.0.0.0 --port $JUPYTER_PORT --no-browser &
popd

popd

trap "stop_service" SIGTERM
trap "stop_service" SIGINT
wait