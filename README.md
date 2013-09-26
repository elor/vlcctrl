vlcctrl
=======

Simple vlc control for a raspberry pi operated radio.
vlc runs as a subprocess of a python daemon and can be controlled using a bash script.
Different playlists are read from a playlist file.

INSTALLATION
------------

Just put whereever you want and use the scripts.
Make sure to change the directories (home and dir variables) and playlist file location in control.sh.

required software:
python (tested with 2.7)
vlc (tested with 2.0.8)

USAGE
-----

Just run _control.sh start_ on system startup.

The current playlist is then read from a line of the playlists file.
use the control.sh script to interface with vlc (next track, previous track, next playlist, previous playlist, pause, stop).

My setup is a raspberry pi, i3wm for mapping the media keys and btsync for audio synchronisation.

