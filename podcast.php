<?php
/*
    @license    http://www.gnu.org/licenses/agpl.txt
    @copyright  2014 Sourcefabric o.p.s.
    @link       http://www.sourcefabric.org
    @author     Micz Flor <micz.flor@sourcefabric.org>
    
    This php script will create a podcast XML on the fly
    listing all mp3 files in the same directory.
*/

$channeltitle   = "Streamplan files";
$channelauthor  = "Various";
/* $sortby sets the order in which tracks are listed. 
   Options: 
   "newest" = newest on top
   "oldest" = oldest on top
   "filedesc" = alphabetically descending
   "fileasc" = alphabetically ascending
   default: "filedesc" (== how streamplan.sh works)
*/
$sortby = "filedesc"; 

$dir = "http://".$_SERVER['SERVER_NAME'];
$parts = explode('/',$_SERVER['REQUEST_URI']);
for ($i = 0; $i < count($parts) - 1; $i++) {
  $dir .= $parts[$i] . "/";
}

header('Content-type: text/xml', true);

print"<?xml version='1.0' encoding='UTF-8'?>
<rss xmlns:itunes='http://www.itunes.com/DTDs/Podcast-1.0.dtd' version='2.0'>
<channel>
  <title>$channeltitle</title>
  <link>$dir</link>
  <itunes:author>$channelauthor</itunes:author>
";
/**/
// read all mp3 files in the directory
$temp = glob("*.mp3");
// create array with timestamp.filename as key
foreach ($temp as $filename) {
  $mp3files[filemtime($filename).$filename] = $filename;
}
// change the order of the list according to $sortby set above
switch ($sortby) {
  case "newest":
    krsort($mp3files);
    break;
  case "oldest":
    ksort($mp3files);
    break;
  case "fileasc":
    natcasesort($mp3files);
    break;
  default:
    // filedesc 
    natcasesort($mp3files);
    $mp3files = array_reverse($mp3files);
    break;
}
// go through files and create <item> for podcast
foreach ($mp3files as $filename) {
  // set empty array for metadata
  $iteminfo = array(
    "TPE1" => "",
    "TIT2" => "",
    "WOAF" => "",
    "Filename" => ""
  );
  // read id3 from shell command
  $idtag = explode("\n",shell_exec("id3v2 -R $filename"));
  foreach($idtag as $line) {
    // to to match key => value from each line
    preg_match("/((\w+): (.*))/", $line, $results);
    // if ID3 tag found, results will return four values
    if(count($results) == 4) {
      $iteminfo[$results[2]] = $results[3];
    }
  }
  // if title too short, use filename as title
  if (strlen($iteminfo['TIT2']) < 2) {
    $iteminfo['TIT2'] = $filename;
  }
  print "
  <item>
    <title>".$iteminfo['TIT2']."</title>
    <itunes:author>".$iteminfo['TPE1']."</itunes:author>
    <itunes:subtitle>".$iteminfo['WOAF']."</itunes:subtitle>
    <description>".$iteminfo['TIT2']." by ".$iteminfo['TPE1'].". ".$iteminfo['COMM']." Recorded on ".date ("r", filemtime($filename))." from stream URL: ".$iteminfo['WOAF']."</description>
    <enclosure url=\"".$dir.$filename."\" length=\"".filesize($filename)."\" type=\"audio/mpeg\"/>
    <guid>".$dir.$filename."</guid>
    <pubDate>".date ("r", filemtime($filename))."</pubDate>
  </item>";
}
print"
</channel>
</rss>";
?>
