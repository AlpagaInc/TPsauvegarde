#! /bin/bash

# On passe le chemin de l'application Nextcloud en variable
NEXTCLOUD="/var/www/html/nextcloud"
BACKUP="root@192.168.33.201"

if ssh $BACKUP'[ ! -d /root/backup/nextcloud_* ]'
then
    echo "Un dossier de backup est nécessaire pour restaurer !" >&2
    exit 1
fi

# Suppression des données de l'application Nextcloud
rm -r $NEXTCLOUD

# Récupération de la dernière backup
BACKUP_DIR=$(ssh $BACKUP "ls -1t /root/backup/ | head -n 1")

# rsync
rsync -avx $BACKUP:/root/backup/$BACKUP_DIR /var/www/html

# Renommage en nextcloud
mv /var/www/html/$BACKUP_DIR /var/www/html/nextcloud

# Mode maintenance -> ON
sudo -u www-data php $NEXTCLOUD/occ maintenance:mode --on

# Drop de la database
mysql -u root -proot -e "DROP DATABASE nextcloud"

# Recréation de la database
mysql -u root -proot -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import des données de la db
mysql -u root -proot nextcloud < $NEXTCLOUD/nextcloud-sqlbkp_*

# Suppression du dump
rm $NEXTCLOUD/nextcloud-sqlbkp_*

# Mode maintenance -> OFF
sudo -u www-data php $NEXTCLOUD/occ maintenance:mode --off

# Mise à jour du data-fingerprint après la restauration
sudo -u www-data php $NEXTCLOUD/occ maintenance:data-fingerprint

