#!/bin/bash
# Script de configuration initial du serveur


# http://www.debian.org/doc/manuals/securing-debian-howto/ch-sec-services.fr.html
cd /etc/init.d/
# firewall < nom du script
# start < démarrage 
# 40 < Numéro pour le lancement 
# S < démarre le service
# . < ?? 
# stop < arrêt du script
# 89 < Numéro d'arrêt
# 0 < halt 
# 6 < reboot
# . < 
update-rc.d firewall start 40 S . stop 89 0 6 .
