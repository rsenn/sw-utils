#!/bin/sh

unset PATTERNS

pattern()
{
  PATTERNS="${PATTERNS+$PATTERNS|}$1"
}

FILENAME=".*"
DECNUM="[0-9]+"
HEXNUM="[0-9A-Fa-f]+"
LANG="[a-z][a-z]"
ALPHA="[A-Za-z]+"
ALNUM="[0-9A-Za-z]+"
ALNUMS="[-_0-9A-Za-z]+"
UUID="$HEXNUM-$HEXNUM-$HEXNUM-$HEXNUM-$HEXNUM"

pattern "http://rapidshare.com/files/$DECNUM/$FILENAME"
pattern "https://rapidshare.com/files/$DECNUM/$FILENAME"
pattern "http://rapidshare.de/files/$DECNUM/$FILENAME"
pattern "http://freefolder.net/f/$HEXNUM"
pattern "http://uploading.com/files/$ALNUM/$FILENAME.html?.*"
pattern "http://vip-file.com/download/$DECNUM\.$HEXNUM/$FILENAME.html"
pattern "http://sharingmatrix.com/file/$DECNUM/$FILENAME"
pattern "http://depositfiles.com/files/$ALNUM#?.*"
pattern "http://depositfiles.com/$LANG/files/$ALNUM#?"
pattern "http://www.megaupload.com/\?d=$ALNUM"
pattern "http://www.filefactory.com/dlf/f/$ALNUM/$ALNUM/$ALNUM/$ALNUM/$HEXNUM/$ALNUM/$ALNUM/$ALNUM/$FILENAME"
pattern "http://www.filefactory.com/file/$ALNUM/n/$FILENAME"
pattern "http://www.easy-share.com/$DECNUM/$FILENAME"
pattern "http://www.easy-share.com/f/$DECNUM/$FILENAME"
pattern "http://w$DECNUM.easy-share.com/$DECNUM.html"
pattern "http://www.box.net/shared/$ALNUM"
pattern "http://www.mediafire.com/\?$ALNUM"
pattern "http://www.mediafire.com/\?$FILENAME"
pattern "http://www.mediafire.com/download.php\?$ALNUM"
pattern "http://letitbit.net/download/$HEXNUM/$FILENAME.html.*"
pattern "http://letitbit.net/download/$DECNUM\.$HEXNUM/$FILENAME.html"
pattern "http://kewlshare.com/dl/$HEXNUM/$FILENAME.html"
pattern "http://hotfile.com/dl/$DECNUM/$HEXNUM/$FILENAME.*"
pattern "http://mymirror.ir/files/$ALNUM/$FILENAME"
pattern "http://saveqube.com/getfile/$HEXNUM/$FILENAME.html"
pattern "http://sms4file.com/downloadvip/[\.0-9a-z]+/$FILENAME\.html"
pattern "http://slil.ru/$DECNUM"
pattern "http://uploadbox.com/files/$ALNUM"
pattern "http://www.[24]shared.com/file/$DECNUM/$HEXNUM/$FILENAME"
pattern "http://www.4shared.com/get/$ALNUM/$ALNUM.html"
pattern "http://www.uploading.com/files/$ALNUM/$FILENAME.html?.*"
pattern "http://vip-file.com/download/$HEXNUM/$FILENAME.html"
pattern "http://www.mediafire.com/\?$ALNUM"
pattern "http://www.mediafire.com/file/$ALNUM/$FILENAME"
pattern "http://www.megashare.com/$DECNUM"
pattern "http://www.megaupload.com/\?d=$ALNUM.*"
pattern "http://www.ziddu.com/download/$ALNUM/$FILENAME.html"
pattern "http://www.zshare.net/download/$HEXNUM/?.*"
pattern "http://fileegg.com/files/$HEXNUM"
pattern "http://filemashine.com/download/$HEXNUM/$FILENAME.html"
pattern "http://filemashines.ru/download/$HEXNUM/$FILENAME.html"
pattern "http://dump.ru/file_catalog/$DECNUM"
pattern "http://dump.ru/file/$DECNUM/?"
pattern "http://www.badongo.com/file/$DECNUM.*"
pattern "http://www.zippyshare.com/v/$DECNUM/file.html"
pattern "http://www.sendspace.com/file/$ALNUM"
pattern "http://flyupload.com/\?fid=$DECNUM"
pattern "http://www.flyupload.com/\?fid=$DECNUM"
pattern "http://netload.in/datei$ALNUM/$FILENAME.htm"
pattern "http://www.filefactory.com/file/$HEXNUM/n/$FILENAME"
pattern "http://www.filefactory.com/file/$HEXNUM/?"
pattern "http://sharedzilla.com/$ALPHA/get?id=$DECNUM"
pattern "http://www.eatlime.com/download.lc?sid=$UUID"
pattern "http://www.yastorage.com/download.php?id=$DECNUM&key=$HEXNUM"
pattern "http://d$DECNUM.megashares.com/dl/$HEXNUM/$FILENAME"
pattern "http://d$DECNUM.megashares.com/?d$DECNUM=$HEXNUM"
pattern "http://filegetty.com/$DECNUM/?"
pattern "http://dl$DECNUM.filegetty.com:$DECNUM/$DECNUM/$DECNUM/$FILENAME"
pattern "http://www.fileflyer.com/view/$ALNUM"
pattern "http://ezyfile.net/$ALNUM/$FILENAME.html"
pattern "http://uploadbox.com/files/$HEXNUM"
pattern "http://www.qshare.com/get/$DECNUM/$FILENAME.html"
pattern "http://usershare.net/$ALNUM"
pattern "http://usershare.net/$DECNUM/$ALNUM"
pattern "http://www.usaupload.net/d/$ALNUM"
pattern "http://uploadbox.com/files/$ALNUM"
pattern "http://upit.to/file:$HEXNUM/$FILENAME"
pattern "http://bluehost.to/file/$ALNUM/$FILENAME"
pattern "http://www.load.to/$ALNUM/$FILENAME"
pattern "http://load.to/$ALNUM/$FILENAME"
pattern "http://www.egoshare.com/download.php?id=$ALNUM"
pattern "http://www.share-online.biz/download.php?id=$ALNUM"
pattern "http://www.storage.to/get/$ALNUM/$FILENAME"
pattern "http://ifile.it/$ALNUM/$FILENAME"
pattern "http://ifile.it/$ALNUM"
pattern "http://mihd.net/$ALNUM"
pattern "http://www.paid4share.com/file/$DECNUM/$FILENAME.html"
pattern "http://paid4share.com/file/$DECNUM/$FILENAME.html"
pattern "http://www.paid4share.net/file/$DECNUM/$FILENAME.html"
pattern "http://paid4share.net/file/$DECNUM/$FILENAME.html"
pattern "http://www.turboupload.com/files/get/$ALNUMS/$FILENAME"
pattern "http://[Ff]ast[Ff]ree[Ff]ile[Hh]osting.com/file/$DECNUM/$FILENAME.html"
pattern "http://www.uploadmachine.com/file/$DECNUM/$FILENAME.html"
pattern "http://onefile.net/f/$HEXNUM"
pattern "http://creafile.com/download/$HEXNUM.html"
pattern "http://linkstofile.com/\?$DECNUM"
pattern "http://turbobit.ru/$ALNUM.html"
pattern "http://maxishare.net/$ALPHA/file/$DECNUM/$FILENAME.html"
pattern "http://mirrorcreator.com/files/$ALNUM/${FILENAME}_mirrors"
pattern "http://netload.in/datei$ALNUM.htm"
pattern "http://$ALNUM.ifolder.ru/$DECNUM"
pattern "http://qubefiles.com/\?file=/getfile/$HEXNUM/$FILENAME.html"
pattern "http://turbobit.net/$ALNUM.html"
pattern "http://ul.to/$ALNUM"
pattern "http://ul.to/$ALNUM/$FILENAME"
pattern "http://up-file.com/download/$HEXNUM"
pattern "http://uploadcell.com/$ALNUM/$FILENAME"
pattern "http://uploading.com/files/$ALNUM/$FILENAME.html"
pattern "http://www.anyfiles.net/download/$HEXNUM/$FILENAME.html"
pattern "http://www.badongo.com/$ALPHA/file/$DECNUM"
pattern "http://www.badongo.com/file/$DECNUM"
pattern "http://www.damipan.com/file/$ALNUM.html"
pattern "http://www.esnips.com/$ALNUM/$UUID/$FILENAME"
pattern "http://www.file-rack.com/files/$ALNUM/$FILENAME.html"
pattern "http://www.filehunt.co.za/dll/\?code=$DECNUM/$FILENAME.html"
pattern "http://www.namipan.com/d/$HEXNUM"
pattern "http://www.qooy.com/files/$ALNUM/$FILENAME"
pattern "http://www.rayfile.com/files/$UUID/?"
pattern "http://bitroad.net/download/$HEXNUM/$FILENAME.html"
pattern "http://sharebee.com/$HEXNUM"
pattern "http://speedshare.org/download.php\?id=$HEXNUM"
pattern "http://linkcrypt.ws/dir/$ALNUM"
pattern "http://www.relink.us/f/$ALNUM"
pattern "http://share-links.biz/_$ALNUM"
pattern "http://linksave.in/$HEXNUM"
pattern "http://bitshare.com/files/$ALNUM/$FILENAME.html"
pattern "http://crypt.to/fid,$ALNUM" 
pattern "http://freakshare.com/files/$ALNUM/$FILENAME.html"
pattern "http://uploaded.net/file/$ALNUM"
pattern "http://www.hoerbuch.in/protection/folder_$ALNUM.html"
pattern "http://oron.com/$ALNUM"
pattern "https://mega.co.nz/..$ALNUM"
pattern "http://extabit.com/file/$FILENAME"
pattern "http://www.crocko.com/$HEXNUM/$FILENAME"
pattern "http://4fastfile.com/$ALNUM/$DECNUM/$DECNUM/$DECNUM/$FILENAME"
pattern "http://hitfile.net/$ALNUM/$FILENAME"
pattern "http://filepost.com/files/$ALNUM/$FILENAME"
pattern "http://www.scribd.com/doc/$DECNUM/$FILENAME"
pattern "http://rapidgator.net/file/$HEXNUM"
pattern "http://www.secureupload.eu/$ALNUM"
pattern "http://www.hulkshare.com/$ALNUM"
pattern "http://filesflash.com/$ALNUM"
pattern "http://putlocker.com/file/$HEXNUM"
pattern "http://www.sockshare.com/file/$HEXNUM"
pattern "http://shareflare.net/download/$ALNUM.$HEXNUM/$FILENAME.html"
pattern "http://bayfiles.net/file/$ALNUM/$ALNUM/$FILENAME"
pattern "http://fileom.com/$ALNUM"
pattern "http://lumfile.com/$ALNUM/$FILENAME.html"
pattern "http://filescroptube.com/file/$FILENAME"
pattern "http://k2s.cc/file/$FILENAME"
pattern "http://putlocker.com/file/$FILENAME"
pattern "http://rapidgator.net/file/$FILENAME"
pattern "http://uploaded.net/file/$FILENAME"
pattern "http://www.4shared.com/file/$FILENAME"
pattern "http://www.filefactory.com/file/$FILENAME"
pattern "http://www.filesmap.com/file/$FILENAME"
pattern "http://www.filesonic.com/file/$FILENAME"
pattern "http://oron.com/$ALNUM/$FILENAME"
pattern "http://letitbit.net/download/$FILENAME.html"
pattern "http://freakshare.com/files/$ALNUM/$FILENAME"
pattern "http://keep2share.cc/file/$HEXNUM/$FILENAME"
pattern "http://rapidshare.com/files/$FILENAME"
pattern "http://uploading.com/files/$HEXNUM/$FILENAME/"

exec egrep "^($PATTERNS)\$" "$@"
