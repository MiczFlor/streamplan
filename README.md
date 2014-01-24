streamplan
==========

Bash script for scheduling stream recordings from the command line. 

Usage:

./streamplan.sh

You will be prompted for the station to record, the time and length of the recording, and optionally the title and author to tag with. You can record with cvlc, streamripper or mplayer.

Using cvlc will transcode the recorded stream into the format specified in $TARGET
For more on transcoding and file formats see https://wiki.videolan.org/Codec/
