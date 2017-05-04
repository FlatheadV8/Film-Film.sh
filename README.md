# Film-Film.sh

Mit diesem Skript kann man mehrere Filmteile aneinander reihen.
Allerdings sollte man darauf achten, dass alle Teile zueinander kompatibel
sind, sonst kann es beim abspielen zu Problemen kommen!

Mit diesem Skript kann man gewaltigen Ausschuss produzieren, der auf dem
ersten Blick nicht einmal auffällt!!!
Damit meine ich, dass es (wenn man bestimmte Fehler macht) völlig zufällig
sein kann, ob der Film nachher auf anderen Geräten abgespielt werden kann.
Meistens wird er mit VLC und MPlayer gut laufen aber im Browser, auf dem Handy
oder der MediaBox sowie anderen Geräten u.U. nicht komplett oder
überhaupt nicht!

Ein Film hat im allgemeinen mind. folgende Eigenschaften, die bei allen Teilen
(die man zu einem Film zusammen fügen möchte), identisch sein sollten:
  - Bildauflösung
  - Bildwiederholrate
  - Vollbild oder Zeilensprung (progressiv / interlaced)
  - Video-Codec
  - Audio-Codec
  - Audio-Sample-Rate

Es können aber auch noch mehr sein, mir fall ganz spontan aber nur diese ein.

Die sicherste Methode, mit diesem Skript gute Ergebnisse zu erhalten, ist
z.B. diese:
verwenden Sie zum konvertieren der einzelnen Filmteile, die später mit diesem
Skript aneinander gereiht werden sollen, das Skript Film2MP4.sh
(https://github.com/FlatheadV8/Film2MP4).
Dabei ist unbedingt darauf zu achten, dass Sie für alle Einzelteile jeweils
genau die gleichen Angaben für diese beiden Parameter verwenden:

    -soll_xmaly
    -dar

zum Beispiel würde man für 3 Teile dieses tun:

    ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 1.avi -z 1.mkv
    ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 2.avi -z 2.mkv
    ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 3.avi -z 3.mkv
    ~/bin/Film+Film.sh komplett 1.mkv 2.mkv 3.mkv

Der fertige Film, aus diesem Beispiel, hat am Ende den Namen "komplett.mkv".
Dieses Skript kann nur MKV-Dateien produzieren.

Es ist auch sinnvoll (wie im Beispiel zu sehen), dass man mit dem MKV-Format
arbeitet, andernfalls muss dieses Skript den entsprechenden Film-Teil
vor dem zusammen fügen nocheinmal ins MKV-Format übersetzen.

Es werden folgende Programme von diesem Skript verwendet:
  - ffmpeg
  - mkvmerge (aus dem Paket mkvtoolnix)
