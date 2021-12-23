# KeypadRemote
Il s'agit d'un commande à distance pour Hotspot RRF avec un clavier numérique USB ou Bluetooth.

Une description complète du projet est disponible sur [mon blog F8ASB.COM]( http://blog.f8asb.com/2021/11/06/keypadremote-le-…r-les-malvoyants/):

![](http://blog.f8asb.com/wp-content/uploads/2021/11/keypadremote01-1.jpg)

Reprendre l'ensemble des fichiers sons RRF sur le lien suivant:
[https://github.com/F8ASB/fr_FR_Agnes/tree/fr_FR_Agnes/RRF](https://github.com/F8ASB/fr_FR_Agnes/tree/fr_FR_Agnes/RRF)

et les mettres selon le chemin suivant du hotspot:
`/usr/share/svxlink/sounds/fr_FR/RRF`

Pour ne pas s'embêter vous pour reprendre l'ensemble des fichiers vocaux disponibles.

Se rendre dans le repertoirre concerné avec la commande:
**`cd /usr/share/svxlink/sounds/`**

copier les fichiers sons

**`git clone https://github.com/F8ASB/fr_FR_Agnes.git`**

Renommer le dossier d'origine
**`mv fr_FR fr_FR_Old`**

Renommer le dossier avec les nouveaux sons:
**`mv fr_FR_Agnes fr_FR`**

Installer la dependance Keyboard necessaire pour le clavier USB:
**`pip3 install keyboard`**

Se connecter en SSH et aller dans le dossier Spotnik
`cd /opt/spotnik/`

Copier les fichiers du projet

`git clone https://github.com/F8ASB/KeypadRemote.git`

Dans le fichier /etc/spotnik/svxlink.cfg accéssible depuis le menu spot
dans la partie simplexLogic aller dans les parametre `FX_GAIN_LOW=` et mettre la valeur `10`.
Cela permettra de ne pas baisser la modulation voir de l'amplifier un peu si il y a un QSO dans le salon en cours afin de permettre de bien entendre les commandes vocales.

Editer le fichier `/usr/share/svxlink/events.d/local/Logic.tcl` , insérer le code dtmfs.tcl en faisant un copier/coller.
Dans ce fichier vous retrouverez tous les codes gérer par svxlink.

Tous les prérequis sont présent, dependance, fichiers sons,modification du fichier Logic.tcl, script installé. 

Il sera necessaire d'editer le fichier settings.py afin de parametre les fonctions selon les touches du clavier. Un utilitaire qui s'appelle testKey.py permet de voir comment les touches sont reconnues par linux. 

![](http://blog.f8asb.com/wp-content/uploads/2021/11/testKey.png)

Il suffira de mettre la bonne touche par rapport au QSY souhaité.

Vous pouvez tester le bon fonctionnement du script en utilisant la commande:

`python3 /opt/spotnik/KeypadRemote/keypadremote.py`

Si tout est fonctionnel, vous pouvez maintenant le mettre au demarrage du hotspot.

Editer le fichier `/etc/rc.local` pour insérer la ligne de commande qui lancera le script au demarrage.

`python3 /opt/spotnik/KeypadRemote/keypadremote.py &`
