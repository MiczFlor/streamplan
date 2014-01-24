#!/bin/bash

#    @license    http://www.gnu.org/licenses/agpl.txt
#    @copyright  2014 Sourcefabric o.p.s.
#    @link       http://www.sourcefabric.org
#    @author     Micz Flor <micz.flor@sourcefabric.org>

clear

# folder to store in, no trailing slash
SAVETO=/home/micz/streamplan

# the default format of the recorded streams
TARGET=mp3

echo "** Select radio station:"
STREAMS=("DLF" "Dradio Kultur" "NPR" "BBC5")
select OPT in "${STREAMS[@]}"
do
    case $OPT in
        "DLF")
            # ogg stream with variable bitrate
            STREAM=http://www.dradio.de/streaming/dlf_hq_ogg.m3u
            break
            ;;
        "Dradio Kultur")
            # mp3 stream with variable bitrate
            STREAM=http://www.deutschlandradio.de/streaming/dkultur.m3u
            break
            ;;
        "NPR")
            # mp3 stream
            STREAM=http://www.npr.org/streams/mp3/nprlive24.pls
            break
            ;;
        "BBC5")
            # windows media stream 48kbit
            STREAM=http://bbc.co.uk/radio/listen/live/r5l.asx
            break
            ;;
        *) echo "Invalid selection";;
    esac
done
echo "Your choice: "
echo $OPT - $STREAM

DATE=`date +"%Y-%m-%d"`
echo "** Specify date (format YYYY-MM-DD)"
echo "Enter = $DATE"
read INPUT
if [ "$INPUT" != "" ]; then
	DATE=$INPUT
fi

echo "** Specify start time (format hh:mm)"
read TIME

echo "** Length in minutes (enter = 60 minutes)"
read LENGTH
if [ "$LENGTH" = "" ]; then
	$LENGTH=60
fi

echo "** Title (optional)"
read TITLE
echo "** Author (optional)"
read AUTHOR

FILENAME=$DATE-$TIME-$OPT-$TITLE-$AUTHOR.$TARGET

echo "** Select stream recorder:"
# Don't prompt for the recorder if you know what you want: just assign e.g. RECORDER=vlc and the matching RECSTRING=
RECORDERS=("vlc" "streamripper" "mplayer")
select RECORDER in "${RECORDERS[@]}"
do
    case $RECORDER in
        "vlc")
            RECSTRING="cvlc --sout \"#transcode{acodec=$TARGET,ab=128,channels=2,samplerate=44100}:std{access=file,mux=$TARGET,dst=$SAVETO/${FILENAME// /_}}\" $STREAM"
            break
            ;;
        "streamripper")
            RECSTRING="streamripper $STREAM -d $SAVETO/ -a ${FILENAME// /_} -s -l $[(LENGTH*62)+180]"
            break
            ;;
        "mplayer")
            RECSTRING="mplayer -dumpstream -dumpfile \"$SAVETO/${FILENAME// /_}\" -playlist \"$STREAM\""
            break
            ;;
        *) echo "Invalid selection";;
    esac
done
echo "Your choice:"
echo $RECSTRING

# this will stop the recording and change the ID3 tags in the recorded file
STOPSTRING="sleep $[LENGTH*60]; pkill $RECORDER; id3v2 --TPE1 \"$AUTHOR\" --TIT2 \"$TITLE\" --WOAF \"$STREAM\" $SAVETO/${FILENAME// /_}"

# write log file
echo "*** Start $DATE $TIME ***" >> $SAVETO/log.txt

# schedule the recording command with time format hh:mm YYYY-MM-DD
echo $RECSTRING | at $TIME $DATE

# the kill process for the same time which will sleep for the duration of the show
echo $STOPSTRING | at $TIME $DATE

# write log file
echo $RECSTRING >> $SAVETO/log.txt
echo $STOPSTRING >> $SAVETO/log.txt
