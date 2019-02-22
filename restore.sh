#! /bin/bash

# On passe le chemin de l'application Nextcloud en variable
NEXTCLOUD_DIR="/var/www/html/nextcloud"
BCK_HOST="root@192.168.33.201"

if ssh $BCK_HOST '[ ! -d /root/backup/nextcloud_* ]'
then
    echo "Un dossier de backup est nécessaire pour restaurer !" >&2
    exit 1
fi

# Suppression des données de l'application Nextcloud
rm -r $NEXTCLOUD_DIR

# Récupération de la dernière backup
LAST_DIR=$(ssh $BCK_HOST "ls -td */ /root/backup/ | sed 's#/##' | head -n 1")

# sync
rsync -avx $BCK_HOST:/root/backup/$LAST_DIR /var/www/html

# rename into "nextcloud"
mv /var/www/html/$LAST_DIR /var/www/html/nextcloud

# Turn maintenance mode ON
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

# Drop de la database
mysql -u root -proot -e "DROP DATABASE nextcloud"

# Recréation de la database
mysql -u root -proot -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import data from backup
mysql -u root -proot nextcloud < $NEXTCLOUD_DIR/nextcloud-sqlbkp_*

# Delete dump
rm $NEXTCLOUD_DIR/nextcloud-sqlbkp_*

# Turn maintenance mode OFF
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off

# update the systems data-fingerprint after a backup is restored
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:data-fingerprint

