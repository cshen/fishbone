#!/usr/bin/env fish

source skeleton.fish

set -S QUIET

IO:initialize


IO:alert "hello, world. Alert"
IO:print "hello, world. Print"

set VERBOSE 0
IO:debug "hello, world. Debug"


IO:success "hello, world. Success"
IO:announce "hello, world. Announce"
# IO:progress "xxx ***"
# IO:countdown 2 "hello, world. Countdown"

# IO:confirm 
# IO:ask age 30

set log_file /tmp/log1.txt
IO:log xxxx 

sleep 1
cat /tmp/log1.txt


Os:tempfile tmp
Os:tempfile log
echo $temp_files

Os:import_env

echo xadsds_ńôöòóœ_ | Str:ascii

Str:slugify "Jack, Jull & Clôcccck"

Str:title "Jack, Jull & Clôcccck, xxx, Jack, Jull & Clôcccck"

echo sadsadsadsad | Str:digest 5


echo '-- init ---'

set LOG_DIR /tmp
set TMP_DIR /tmp

Script:initialize
echo '-- init done ---'

Script:meta

Os:follow_link ~/Downloads
Os:follow_link ~/bin

Os:notify "hello, world. CS"

# enable FORCE
set FORCE 0
# Os:require xxx
Os:require 
Os:require wget
Os:require whathehellcommand

# set FORCE -1
Os:require whathehell2

Script:show_required
Script:show_required test.fish



IO:die "I died"

