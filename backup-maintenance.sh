#! /bin/bash


NEXTCLOUD="/var/www/html/nextcloud"
BACKUP="root@192.168.33.201"

if ssh $BACKUP '[ ! -d /root/backup ]'
then
    ssh $BACKUP "mkdir /root/backup"
fi


# Recopie des données dans un répertoire avec les paramêtres de date
sudo rsync -Aavxziptgo $NEXTCLOUD/ $BACKUP:/root/backup/nextcloud_`date +%Y-%m-%W`/

# Dump de la database avec les paramêtres de date dans le nom du fichier
sudo mysqldump --single-transaction -u root -proot nextcloud > /root/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

# Recopie du dump dans le répertoire du backup
sudo rsync -Aavxziptgo /root/*.bak $BACKUP/root/backup/nextcloud_`date +%Y-%m-%W`/

# # Suppression du dump sur la machine NEXTCLOUD
rm /root/*.bak


