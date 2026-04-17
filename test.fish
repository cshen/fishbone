#!/usr/bin/env fish

source skeleton.fish

set -S QUIET

io:init


io:alert "hello, world. Alert"
io:print "hello, world. Print"

set VERBOSE 0
io:debug "hello, world. Debug"


io:success "hello, world. Success"
io:announce "hello, world. Announce"
# io:progress "xxx ***"
# io:countdown 2 "hello, world. Countdown"

# io:confirm
# io:ask age 30

set log_file /tmp/log1.txt
io:log xxxx

sleep 1
cat /tmp/log1.txt


system:tempfile tmp
system:tempfile log
echo $temp_files

system:load_env

echo xadsds_ńôöòóœ_ | str:ascii

str:slugify "Jack, Jull & Clôcccck"

str:title "Jack, Jull & Clôcccck, xxx, Jack, Jull & Clôcccck"

echo sadsadsadsad | str:md5 5


echo '-- init ---'

set LOG_DIR /tmp
set TMP_DIR /tmp

script:initialize
echo '-- init done ---'

script:meta

system:follow_link ~/Downloads
system:follow_link ~/bin

system:notify "hello, world. CS"

# enable FORCE
set FORCE 0
# system:require xxx
system:require
system:require wget
system:require whathehellcommand

# set FORCE -1
system:require whathehell2

script:show_required
script:show_required test.fish



io:die "I died"

