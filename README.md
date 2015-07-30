streamplan
==========

Bash script for scheduling stream recordings from the command line. 

Requires:

* id3v2
* vlc-nox
* procps

Install: sudo apt-get install id3v2 vlc-nox procps


streamplan.sh
-------------

Usage:

./streamplan.sh

You will be prompted for the station to record, the time and length of the recording, and optionally the title and author to tag with. You can record with cvlc, streamripper or mplayer.

Using cvlc will transcode the recorded stream into the format specified in $TARGET.
For more on transcoding and file formats see https://wiki.videolan.org/Codec/

More inforamtion and research in the related blog posts:

Schedule stream recordings from the command line, Part 1
https://blog.sourcefabric.org/en/news/blog/2076/

Schedule stream recordings from the command line, Part 2
https://blog.sourcefabric.org/en/news/blog/2077/

podcast.php
-----------

Creating podcast xml file on the fly for mp3 files in same folder.

Usage:
* Place script in a folder with mp3 files created by streamplan.sh
* Point browser or app to URL
