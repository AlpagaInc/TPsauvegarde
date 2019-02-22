# TP Sauvegarde Cloud

## Description du travail à effectuer
Vous devez mettre en place la sauvegarde de cette application de la
manière la plus efficace possible en considérant que le volume de
données peut devenir très important.  De plus, vous devrez permettre
une historisation de ces sauvegardes avec une durée de rétention de 30
jours.  Vous sauvegarderez bien évidemment les fichiers aussi bien que
la base de données de manière à ce qu’une restauration soit
parfaitement possible.  Vous planifierez cette sauvegarde de manière à
ce qu’elle s’effectue de manière totalement automatique, le plus
fréquemment possible et en mettent en application les bonnes pratiques
étudiées en cours.

## Notes concernant l'installation
Le sujet du TP ne concernant les éventuelles modifications des
machines virtuelles fournies, nous nous contenteront d'expliquer la
démarche à suivre pour utiliser le(s) script(s) (cela à défaut de
fournir un script supplémentaire d'installation).

Le script utilise rsync pour synchroniser les données d'une machine à
l'autre, aussi pour ne pas avoir à entrer le mot de passe à chaque
appel de cette commande il est nécessaire d'utiliser une paire de
clés ssh. De plus, la connection entre les deux machines est effectuée
en root (bien que cela ne soit pas recommandé cela nous a paru
acceptable dans le cadre de l'exercice).

### Mise en place du script
_root@nextcloud$ git clone https://github.com/BasicAcid/sauvegarde_

Il faut ensuite éditer la macro "BCK_HOST" des scripts respectifs et remplacer la valeur par l'utilisateur et l'ip du serveur de backup, ex: root@192.168.33.201 (ou par le nom d'hote si un sshconfig est utilisé).

## Fonctionnement
### Backup
Le script de backup fonctionne de telle sorte que seules les données
modifiées ou ajoutées sont synchronisées, cela implique qu'une
sauvegarde complète sera effectuée lors de son premier lancement (ou
lors d'un chagement de semaine).

Nous utilisons la commande "date" pour récupérer une valeur unique se
rapportant à la semaine courante (numéro de la semaine dans l'année).

#### Automatisation
Étant donné que le nom de backup change en fonction des semaine, il
suffit de mettre en place une tache cron tous les jours pour répondre
à la problématique, car une sauvegarde complète sera effectuée à
chaque nouvelle semaine:

0 0 * * * backup.sh

Il faut ensuite utiliser une seconde tâche pour supprimer la dernière
backup à la fin de chaque mois:

0 0 31 * * remove_old.sh

# Restauration
Le script de restauration commence par supprimer toutes les données
relatives à l'instance, des fichiers à la base de donnée.

Il va ensuite transvaser via rsync la backup la plus récente, puis
créer une nouvelle database vide, et enfin importer le dump.

Des commandes occ de scan et de checks supplémentaires sont ensuite
lancées.
