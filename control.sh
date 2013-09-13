#!/bin/bash
#
# This script manages music

currentfile='/home/pi/current.txt'
playlistfile='/home/pi/synced/audio/playlists.txt'
pipe='/home/pi/code/vlcctrl/pipe.fifo'
pidfile='/home/pi/code/vlcctrl/pid.pid'
daemoncmd='/home/pi/code/vlcctrl/daemon.py'

get_current(){
  if [ -f "$currentfile" ];then
    cat "$currentfile"
  else
    echo 1
  fi
}

save_current(){
  echo $1 > $currentfile
}

crop_current(){
  line=$1
  if (( $line <= 0 )); then
    line=`cat "$playlistfile" | wc -l`
  fi
  if (( $line > `cat "$playlistfile" | wc -l` )); then
    line=1
  fi
}

get_playlist(){
  local line=$1
  if [ -z "$line" ];then
    line=`get_current`
  fi

  sed "$line q;d" "$playlistfile"
}

daemon_running(){
	if [ -f "$pidfile" ];then
		pid=`echo $(cat "$pidfile")`

		proc=`ps h $pid`

		if [ -n "$proc" ]; then
			return 0 # running
		fi
	fi

	return 1 # not running
}

stop_daemon(){
	daemon_running && kill `echo $(cat "$pidfile")`
	sleep 1
	if daemon_running ; then
		echo "attempting hardkill"
		kill -KILL `echo $(cat "$pidfile")`
	else
		echo "killed"
	fi
	rm "$pidfile"
	rm "$pipe"
}

start_daemon(){
	daemon_running && stop_daemon

	pipecheck

	$daemoncmd -p "$pipe" &
	echo $! > "$pidfile"

	echo "started with pid $!"
}

pipecheck(){
	mkfifo "$pipe" >/dev/null 2>/dev/null
}

send(){
	echo "$1"
	echo "$1" >> "$pipe"
}

set_playlist(){
	send "clear"
	send "random on"
	send "loop on"
	send "add $1"
}

next(){
	send "next"
}

prev(){
	send "prev"
}

pause(){
	send "pause"
}

case $1 in
	right)
		daemon_running || echo "daemon not running" >&2
		next
		;;
	left)
		daemon_running || echo "daemon not running" >&2
		prev
		;;
	center)
		daemon_running || echo "daemon not running" >&2
		pause
		;;
  up)
		daemon_running || echo "daemon not running" >&2
    line=`get_current`
    let line++
    crop_current $line
    save_current $line
		set_playlist "$(get_playlist $(get_current))"
    ;;
  down)
		daemon_running || echo "daemon not running" >&2
    line=`get_current`
    let line--
    crop_current $line
    save_current $line
		set_playlist "$(get_playlist $(get_current))"
    ;;
  start)
		start_daemon
		set_playlist "$(get_playlist $(get_current))"
    ;;
  stop)
		stop_daemon
    ;;
	status)
		if daemon_running ; then
			echo "daemon running with pid `echo $(cat "$pidfile")`"
		else
			echo "daemon not running"
		fi
		;;
  *)
    echo "usage: $0 left|right|up|down|center|start|stop|status"
    exit 1
    ;;
esac
