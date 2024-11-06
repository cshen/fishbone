

################### CS:  6 Nov 2024 13:16 ###########################
################### DO NOT MODIFY BELOW THIS LINE ###################
#####################################################################
set action ''
set error_prefix ''
set git_repo_remote ''
set git_repo_root ''
set install_package ''
set os_kernel ''
set os_machine ''
set os_name ''
set os_version ''
set script_basename ''
set script_hash '?'
set script_lines '?'
set script_prefix ''
set shell_brand ''
set shell_version ''
set temp_files ''
set sourced ''


# NB: CS:  5 Nov 2024 22:45 
# 0 ---> enabled, true
# 1 ---> disabled, false

set IFS '\\n\\t'
set FORCE 1
set help 1

#to enable VERBOSE even before option parsing
set VERBOSE 1
if test ( count argv ) -gt 0;
    and test "$argv[1]" = "-v"
    set VERBOSE 0
end

#to enable QUIET even before option parsing
set QUIET 1
if test (count argv) -gt 0;
    and test "$argv[1]" = "-q"
    set QUIET 0
end

set txtReset ''
set txtError ''
set txtInfo ''
set txtInfo ''
set txtWarn ''
set txtBold ''
set txtItalic ''
set txtUnderline ''
set char_succes 'OK '
set char_fail '!! '
set char_alert '?? '
set char_wait '...'
set info_icon '(i)'
set config_icon '[c]'
set clean_icon '[c]'
set require_icon '[r]'

### stdIO:print/stderr output
function IO:initialize
    set script_started_at (Tool:time | string collect; or echo)
    IO:debug 'script '"$script_basename"' started at '"$script_started_at"

    # https://superuser.com/questions/943468/can-a-fish-script-distinguish-between-being-sourced-and-executed
    if test "$_" != source -a "$_" != "."
        # Not sourced
        set sourced 1
    else
        # was sourced 
        set sourced 0
    end

    # detect if output is piped
    # https://stackoverflow.com/questions/911168/how-can-i-detect-if-my-shell-script-is-running-through-a-pipe
    # 1 --> terminal, thus NOT piped
    # 0 --> piped to cat, thus piped
    test -t 1 && set piped 1 || set piped 0

    if test "$piped" -eq 1 && test -n "$TERM"
        set txtReset (tput sgr0 | string collect; or echo)
        set txtError (tput setaf 160 | string collect; or echo)
        set txtInfo (tput setaf 2 | string collect; or echo)
        set txtWarn (tput setaf 214 | string collect; or echo)
        set txtBold (tput bold | string collect; or echo)
        set txtItalic (tput sitm | string collect; or echo)
        set txtUnderline (tput smul | string collect; or echo)
    end

    # detect if unicode is supported
    test (echo -e '\\xe2\\x82\\xac' | string collect; or echo) = '€' && set unicode 0 || set unicode 1
    if test "$unicode" -eq 0
        set char_succes '✅'
        set char_fail '⛔'
        set char_alert '✴️'
        set char_wait '⏳'
        set info_icon '🌼'
        set config_icon '🌱'
        set clean_icon '🧽'
        set require_icon '🔌'
    end
    set error_prefix "$txtError"'>'"$txtReset"
end


function IO:print
    test "$QUIET" && true || printf '%b\\n' "$argv"
end

function IO:debug
    test "$VERBOSE" = 0 && IO:print "$txtInfo"'# '"$argv"' '"$txtReset" >&2
    true
end

function IO:die
    IO:print "$txtError""$char_fail"' '"$script_basename""$txtReset"': '"$argv" >&2
    #  Os:beep
    Script:exit
end

function IO:alert
    IO:print "$txtWarn""$char_alert""$txtReset"': '"$txtUnderline""$argv""$txtReset" >&2
end

function IO:success
    IO:print "$txtInfo""$char_succes""$txtReset"'  '"$txtBold""$argv""$txtReset"
end

function IO:announce
    IO:print "$txtInfo""$char_wait""$txtReset"'  '"$txtItalic""$argv""$txtReset"
    sleep 1
end



function IO:progress

    if not test "$QUIET"
        set -l screen_width (tput cols 2>/dev/null || echo 80)
        set -l rest_of_line ( math "$screen_width - 5" )

        if test "$piped" != 0
            IO:print \'... \'"$argv" >&2
        else
            printf \'... %-\'"$rest_of_line"\'b\\\\r\' "$argv"\' \' >&2
        end
    end
end


function IO:countdown
    set -l seconds $argv[1]
    set -l message $argv[2]

    if test "$piped" -eq 0
        IO:print "$message"' '"$seconds"' seconds'
    else
        for i in ( seq 0  (math "$seconds -1" ) )
            IO:progress "$txtInfo$message ((math "$seconds - $i")) seconds $txtReset"
            sleep 1
        end

        IO:print '                         '
    end
end


### interactive
function IO:confirm
    test "$FORCE" -eq 0 && return 0
    echo -n "Confirm: [y/N] default is No: "
    read -n 1 REPLY

    if test "$REPLY" = y; or test "$REPLY" = Y
        return 0
    else
        return 1
    end
end


function IO:question
    set -l DEFAULT $argv[2]
    read -r -p $argv[1]' '"$DEFAULT"' > ' ANSWER
    test -z "$ANSWER" && echo "$DEFAULT" || echo "$ANSWER"
end


function IO:log
    # test -n to check if a variable is NOT empty
    if test -n "$log_file"
        echo (date '+%H:%M:%S' | string collect; or echo)' | '"$argv" >>"$log_file"
    end
end

# fish math works the same way
function Tool:calc
    awk 'BEGIN {print '"$argv"'} ; '
end

function Tool:round
    set -l number $argv[1]
    set -l decimals $argv[2]
    awk 'BEGIN {print sprintf( "%.'"$decimals"'f" , '"$number"' )};'
end



# G
function Tool:time
    if test (command -v perl | string collect; or echo)
        perl -MTime::HiRes=time -e 'printf "%f\\n", time'
    else if test (command -v php | string collect; or echo)
        php -r 'printf("%f\\n",microtime(true));'
    else if test (command -v python | string collect; or echo)
        python -c 'import time; print(time.time()) '
    else if test (command -v python3 | string collect; or echo)
        python3 -c 'import time; print(time.time()) '
    else if test (command -v node | string collect; or echo)
        node -e 'console.log(+new Date() / 1000)'
    else if test (command -v ruby | string collect; or echo)
        ruby -e 'STDOUT.puts(Time.now.to_f)'
    else
        date '+%s.000'
    end
end

function Os:tempfile
    if test "$argv[1]" = ""
        set extension txt
    else
        set extension $argv[1]
    end

    set -l execution_day (date "+%Y-%m-%d")
    set -l file (test -n "$TMP_DIR" && echo "$TMP_DIR" || echo '/tmp')'/'"$execution_day"'.'"$RANDOM"'.'"$extension"

    IO:debug "$config_icon"' tmp_file: '"$file"
    set -a temp_files "$file"
    echo "$file"
end

# x
function Os:import_env

    if test (pwd | string collect; or echo) = "$script_install_folder"
        set env_files "$script_install_folder"'/.env' "$script_install_folder"'/.'"$script_prefix"'.env' "$script_install_folder"'/'"$script_prefix"'.env'
    else
        set env_files "$script_install_folder"'/.env' "$script_install_folder"'/.'"$script_prefix"'.env' "$script_install_folder"'/'"$script_prefix"'.env' './.env' './.'"$script_prefix"'.env' './'"$script_prefix"'.env'
    end

    for env_file in $env_files
        if test -f "$env_file"
            IO:debug "$config_icon"' Read  dotenv: ['"$env_file"']'
            source "$env_file"
        end
    end
end





### string processing

function Str:trim
    if isatty stdin # not a pipe or redirection
        string trim $argv
    else
        cat | string trim
    end
end

function Str:lower
    isatty stdin && string lower $argv || cat | string lower
end

function Str:upper
    isatty stdin && string upper $argv || cat | string upper
end


function Str:ascii
    # remove all characters with accents/diacritics to latin alphabet
    sed 'y/àáâäæãåāǎçćčèéêëēėęěîïííīįìǐłñńôöòóœøōǒõßśšûüǔùǖǘǚǜúūÿžźżÀÁÂÄÆÃÅĀǍÇĆČÈÉÊËĒĖĘĚÎÏÍÍĪĮÌǏŁÑŃÔÖÒÓŒØŌǑÕẞŚŠÛÜǓÙǕǗǙǛÚŪŸŽŹŻ/aaaaaaaaaccceeeeeeeeiiiiiiiilnnooooooooosssuuuuuuuuuuyzzzAAAAAAAAACCCEEEEEEEEIIIIIIIILNNOOOOOOOOOSSSUUUUUUUUUUYZZZ/'

end

function Str:slugify
    # Str:slugify <input> <separator>
    # Str:slugify "Jack, Jill & Clémence LTD"      => jack-jill-clemence-ltd
    # Str:slugify "Jack, Jill & Clémence LTD" "_"  => jack_jill_clemence_ltd
    set separator "argv[2]"
    test -z "$separator" && set separator _

    string lower "$argv[1]" | Str:ascii | awk '{
    gsub(/[\[\]@#$%^&*;,.:()<>!?\/+=_]/," ",$0);
    gsub(/^  */,"",$0);
    gsub(/  *$/,"",$0);
    gsub(/  */,"-",$0);
    gsub(/[^a-z0-9\-]/,"");
    print;
    }' | sed "s/-/$separator/g"
end

# -----------------------------------------
function Str:title -d "Remove non-standard chars from a string"
    # Str:title <input> <separator>
    # Str:title "Jack, Jill & Clémence LTD"     => JackJillClemenceLtd # CS:  6 Nov 2024 00:59 by default using _
    # Str:title "Jack, Jill & Clémence LTD" "_" => Jack_Jill_Clemence_Ltd
    set separator "$argv[2]"
    test -z "$separator" && set separator _

    string lower "$argv[1]" | tr àáâäæãåāçćčèéêëēėęîïííīįìłñńôöòóœøōõßśšûüùúūÿžźż aaaaaaaaccceeeeeeeiiiiiiilnnoooooooosssuuuuuyzzz | awk '{ gsub(/[\[\]@#$%^&*;,.:()<>!?\/+=_-]/," ",$0); print $0; }' | awk '{
    for (i=1; i<=NF; ++i) {
        $i = toupper(substr($i,1,1)) tolower(substr($i,2))
        };
        print $0;
        }' | sed "s/ /$separator/g" | cut -c1-50
end


function Str:digest

    set length $argv[1]

    if command -v md5sum
        # regular linux
        md5sum | cut -c1-"$length"
    else
        # macos
        md5 | cut -c1-"$length"
    end
end

# -----------------------------------------
# Input string must be piped
# echo a b c | Str:column 2 --> b
function Str:column --argument number F

    if test "$F" = ""
        awk '{ print  $'$number' }'
    else
        awk -F$F '{ print  $'$number' }'
    end
end


function Str:row --argument index
    sed -n "$index p"
end



function Script:exit

    for temp_file in $temp_files
        test -f "$temp_file" && fish -c 'IO:debug \'Delete temp file [\'"$temp_file"\']\'; rm -f "$temp_file"'
    end

    trap - INT TERM EXIT
    IO:debug "$script_basename"' finished after '"$SECONDS"' seconds'
    exit 0
end


function Script:check_version

    pushd "$script_install_folder" &>/dev/null

    if test -d '.git'

        set remote (git remote -v | grep fetch | awk 'NR == 1 {print $2}' | string collect; or echo)
        IO:progress 'Check for updates - '"$remote"

        git remote update &>/dev/null

        if test (git rev-list --count 'HEAD...HEAD@{upstream}' 2>/dev/null | string collect; or echo) -gt 0
            IO:print 'There is a more recent update of this script - run <<'"$script_prefix"' update>> to update'
        else
            IO:progress '                                         '
        end
    end

    popd &>/dev/null

end



function Script:meta

    set script_install_path (realpath (status current-filename))
    set script_basename (basename (realpath (status current-filename)))

    set script_extension (path extension $script_basename)
    set script_prefix (basename script_basename $script_extension)

    set execution_day (date '+%Y-%m-%d' | string collect; or echo)

    IO:debug "$info_icon"' Script path: '"$script_install_path"

    set script_install_path (Os:follow_link "$script_install_path" | string collect; or echo)
    IO:debug "$info_icon"' Linked path: '"$script_install_path"

    set script_install_folder (command cd -P (dirname "$script_install_path" | string collect; or echo) && pwd | string collect; or echo)

    IO:debug "$info_icon"' In folder  : '"$script_install_folder"

    if test -f "$script_install_path"
        set script_hash (Str:digest 8 <"$script_install_path" | string collect; or echo)
        set script_lines (awk 'END {print NR}' <"$script_install_path" | string collect; or echo)
    end

    # get shell/operating system/versions
    set shell_brand sh
    set shell_version '?'
    test -n "$ZSH_VERSION" && set shell_brand zsh && set shell_version "$ZSH_VERSION"
    test -n "$BASH_VERSION" && set shell_brand bash && set shell_version "$BASH_VERSION"
    test -n "$KSH_VERSION" && set shell_brand ksh && set shell_version "$KSH_VERSION"

    test -n "$FISH_VERSION" && set shell_brand fish && set shell_version "$FISH_VERSION"
    IO:debug "$info_icon"' Shell type : '"$shell_brand"' - version '"$shell_version"

    if not test "$shell_brand" = fish
        IO:die 'Fish is required'
    end

    set os_kernel (uname -s | string collect; or echo)
    set os_version (uname -r | string collect; or echo)
    set os_machine (uname -m | string collect; or echo)
    set install_package ''
    switch "$os_kernel"
        case 'CYGWIN*' 'MSYS*' 'MINGW*'
            set os_name Windows

        case Darwin
            # macOS
            set os_name (sw_vers -productName | string collect; or echo)
            # 11.1
            set os_version (sw_vers -productVersion | string collect; or echo)
            set install_package 'brew install'

        case Linux 'GNU*'
            if test (command -v lsb_release | string collect; or echo)
                # 'normal' Linux distributions
                # Ubuntu/Raspbian
                set os_name (lsb_release -i | awk -F: '{$1=""; gsub(/^[\\s\\t]+/,"",$2); gsub(/[\\s\\t]+$/,"",$2); print $2}' | string collect; or echo)
                # 20.04
                set os_version (lsb_release -r | awk -F: '{$1=""; gsub(/^[\\s\\t]+/,"",$2); gsub(/[\\s\\t]+$/,"",$2); print $2}' | string collect; or echo)
            else
                # Synology, QNAP,
                set os_name Linux
            end

            # Cygwin
            test -x /bin/apt-cyg && set install_package 'apt-cyg install'
            # Synology
            test -x /bin/dpkg && set install_package 'dpkg -i'
            # Synology
            test -x /opt/bin/ipkg && set install_package 'ipkg install'
            # BSD
            test -x /usr/sbin/pkg && set install_package 'pkg install'
            # Arch Linux
            test -x /usr/bin/pacman && set install_package 'pacman -S'
            # Suse Linux
            test -x /usr/bin/zypper && set install_package 'zypper install'
            # Gentoo
            test -x /usr/bin/emerge && set install_package emerge
            # RedHat RHEL/CentOS/Fedora
            test -x /usr/bin/yum && set install_package 'yum install'
            # Alpine
            test -x /usr/bin/apk && set install_package 'apk add'
            # Debian
            test -x /usr/bin/apt-get && set install_package 'apt-get install'
            # Ubuntu
            test -x /usr/bin/apt && set install_package 'apt install'
    end

    IO:debug "$info_icon"' System OS  : '"$os_name"' ('"$os_kernel"') '"$os_version"' on '"$os_machine"
    IO:debug "$info_icon"' Package mgt: '"$install_package"

    # get last modified date of this script
    set script_modified '??'
    # generic linux
    test "$os_kernel" = Linux && set script_modified (stat -c %y "$script_install_path" 2>/dev/null | cut -c1-16 | string collect; or echo)
    # for MacOS

    test "$os_kernel" = Darwin && set script_modified (stat -f '%Sm' "$script_install_path" 2>/dev/null | string collect; or echo)
    IO:debug "$info_icon"' Version  : '"$script_version"
    IO:debug "$info_icon"' Created  : '"$script_created"
    IO:debug "$info_icon"' Modified : '"$script_modified"
    IO:debug "$info_icon"' Lines    : '"$script_lines"' lines / md5: '"$script_hash"
    IO:debug "$info_icon"' User     : '"$USER"'@'"$hostname"

    # if run inside a git repo, detect for which remote repo it is
    if git status &>/dev/null
        set git_repo_remote (git remote -v | awk '/(fetch)/ {print $2}' | string collect; or echo)
        IO:debug "$info_icon"' git remote : '"$git_repo_remote"
        set git_repo_root (git rev-parse --show-toplevel | string collect; or echo)
        IO:debug "$info_icon"' git folder : '"$git_repo_root"
    end

    # get script version from VERSION.md file - which is automatically updated by pforret/setver
    test -f "$script_install_folder"'/VERSION.md' && set script_version (cat "$script_install_folder"'/VERSION.md' | string collect; or echo)

    # get script version from git tag file - which is automatically updated by pforret/setver
    set -l _git_tag ( git tag &>/dev/null )
    if test -n $git_repo_root; and test -n $_git_tag
        set script_version (git tag --sort=version:refname | tail -1)
    end

end




function Script:initialize
    set log_file ""
    if test -n "$TMP_DIR"
        # clean up TMP folder after 1 day
        Os:folder "$TMP_DIR" 1
    end

    if test -n "$LOG_DIR"
        # clean up LOG folder after 1 month
        Os:folder "$LOG_DIR" 30
        set "log_file $LOG_DIR/$script_prefix.$execution_day.log"
        IO:debug "$config_icon log_file: $log_file"
    end
end


function Os:folder
    if test -n $argv[1]
        set -l folder $argv[1]

        # CS:  6 Nov 2024 11:32 
        # to prevent disaster rm, force the folder name must contain log/temp/tmp
        if echo $folder | grep -i -q -E "log|temp|tmp"
            # continue
        else
            # stop
            echo Folder name must contain log/temp/tmp as part of the folder name
            return 1
        end

        set -l max_days ( test -n $argv[2] && echo $argv[2] || echo 365 )

        if test ! -d "$folder"
            IO:debug "$clean_icon"' Create folder : ['"$folder"']'
            mkdir -p "$folder"
        else
            IO:debug "$clean_icon"' Cleanup folder: ['"$folder"'] - delete files older than '"$max_days"' day(s)'
            find "$folder" -mtime '+'"$max_days" -type f -exec rm -i {} \;
        end
    end
end




function Os:follow_link
    ## if it's not a symbolic link, return immediately
    test ! -L $argv[1] && echo $argv[1] && return 0

    ## check if file has absolute/relative/no path
    set file_folder (dirname $argv[1] | string collect; or echo)

    # first char is / or not
    set first $( echo $file_folder  | string trim | string sub -s 1 -e 1 )
    test "$first" != / && set file_folder (cd -P "$file_folder" &>/dev/null && pwd)


    ## a relative path was given, resolve it; follow the link
    set symlink (readlink $argv[1] | string collect; or echo)

    ## check if link has absolute/relative/no path
    set link_folder (dirname "$symlink" | string collect; or echo)

    ## if no link path, stay in same folder
    test -z "$link_folder" && set link_folder "$file_folder"

    set first $( echo $link_folder  | string trim | string sub -s 1 -e 1 )
    # ./......., check if the first char is .
    test "$first" = "." && set link_folder (cd -P "$file_folder" && cd -P "$link_folder" &>/dev/null && pwd)

    ## a relative  link path was given, resolve it
    set link_name (basename "$symlink" | string collect; or echo)
    IO:debug "$info_icon"' Symbolic ln: '$argv[1]' -> ['"$link_folder"'/'"$link_name"']'

    ## recurse
    Os:follow_link "$link_folder"'/'"$link_name"
end


function Os:notify
    # cf https://levelup.gitconnected.com/5-modern-bash-scripting-techniques-that-only-a-few-programmers-know-4abb58ddadad
    set -l message $argv[1]
    set -l source ( test -n $argv[2] && echo $argv[2] || echo $script_basename )

    # for Linux
    test -n (command -v notify-send | string collect; or echo) && notify-send "$source" "$message"

    # for MacOS
    test -n (command -v osascript | string collect; or echo) && osascript -e 'display notification "'"$message"'" with title "'"$source"'"'
end


function Os:busy
    # show spinner as long as process $pid is running
    set -l pid $argv[1]
    set -l message "$argv[2]"

    # https://stackoverflow.com/questions/3043978/how-to-check-if-a-process-id-pid-exists 
    while ps -p "$pid" &>/dev/null
        for frame in "|" "/" "-" "\\"
            printf "\r[ $frame ] %s..." "$message"
            sleep 0.5
        end
    end

    printf "\n"

end


function Os:require

    set -l install_instructions $install_instructions
    set -l binary $binary
    set -l words $words
    set -l path_binary $path_binary
    # $1 = binary that is required

    set binary $argv[1]
    set path_binary (command -v "$binary" 2>/dev/null | string collect; or echo)
    test -n "$path_binary" && IO:debug '️'"$require_icon"' required ['"$binary"'] -> '"$path_binary" && return 0

    # $2 = how to install it
    IO:alert "$script_basename"' needs ['"$binary"'] but it cannot be found'

    set words (echo $argv[2] | wc -w | string collect; or echo)
    set install_instructions "$install_package"' '$argv[1]

    test "$words" -eq 1 && set install_instructions "$install_package"' '$argv[2]
    test "$words" -gt 1 && set install_instructions $argv[2]

    if test "$FORCE" != 0
        IO:announce 'Installing ['$argv[1]'] ...'
        eval "$install_instructions"
    else
        IO:alert '1) install package  : '"$install_instructions"
        IO:alert '2) check path       : export PATH="[path of your binary]:$PATH"'
        IO:die 'Missing program/script ['"$binary"']'
    end
end


function Script:show_required
    grep 'Os:require' "$script_install_path" | grep -v -E '\(\)| grep|# Os:require' | awk -v install="# $install_package" ' 
    function ltrim(s) { sub(/^[ "\\t\\r\\n]+/, "", s); return s }
    function rtrim(s) { sub(/[ "\\t\\r\\n]+$/, "", s); return s }
    function trim(s) { return rtrim(ltrim(s)); }
    NF == 2 {print install trim($2); }
    NF == 3 {print install trim($3); }
    NF > 3  {$1=""; $2=""; $0=trim($0); print "# " trim($0);}
  ' | sort -u
end


function Option:filter
    Option:config | grep "$1|" | cut -d'|' -f3 | sort | grep -v '^\s*$'
end



