# CMake path
[ -d /opt/cmake/bin ] && export PATH="/opt/cmake/bin${PATH:+:${PATH}}"

# ccache
[ -d /usr/lib/ccache ] && export PATH=/usr/lib/ccache:"$PATH"
[ -d /devel/.ccache ] && ccache -o cache_dir=/devel/.ccache

# completion
[ -f /etc/bash_completion ] && . /etc/bash_completion
[ -f ~/.git-prompt.sh ] || \
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
  > ~/.git-prompt.sh
  . ~/.git-prompt.sh

[ -f ~/.bash_aliases ] && . ~/.bash_aliases
export PS1='sirf:\w$(__git_ps1)\$ '

# Python (virtualenv)
[ -f /opt/pyvenv/bin/activate ] && . /opt/pyvenv/bin/activate

# SIRF env
[ -f /opt/SIRF-SuperBuild/INSTALL/bin/env_ccppetmr.sh ] && \
   . /opt/SIRF-SuperBuild/INSTALL/bin/env_ccppetmr.sh

# shared permissions
# [ $(ls -l / | grep devel | awk '{print $3}') == $(whoami) ] || sudo chown -R $(whoami) /devel
# [ $(ls -l / | grep devel | awk '{print $4}') == $(whoami) ] || sudo chgrp -R $(whoami) /devel
