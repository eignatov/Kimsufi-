#!/bin/bash
# Script de configuration initial du serveur



#####################################
# function log()
#####################################
# write in /var/log/setup.log
# @param1: type '+' or 'E' or 'I'
# @param2: 'message' 
log() (
	echo $1": $(date +%D' '%R':'%S) "$2 >> /var/log/setup.log
	echo $1": $(date +%D' '%R':'%S) "$2 > /dev/stdout
)


log "I" "Démarrage de l'installation"

if [[ -n `grep "step_kernel" /var/log/setup_step` ]];
then
	log "I" "L'installation du nouveau noyau a déjà été réalisé"
	
else
	log "I" "Début de l'installation et compilation du noyau"
	echo "step_kernel_0" > /var/log/setup_step

	log "I" "Modification des sources"
	sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list

	log "I" "MAJ du système"
	aptitude update && aptitude -y full-upgrade
	
	log "I" "Installation des outils pour la compilation du noyau"
	aptitude -y install kernel-package libncurses5-dev fakeroot bzip2 build-essential lzma patch make vim-nox


	log "I" "Téléchargement du noyau"
	cd /usr/src
	wget -c http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.39.1.tar.gz
	tar -xzf linux-2.6.39.1.tar.gz
 
	log "I" "Télécharger le patch grsecurity pour la bonne version"
	wget -c http://grsecurity.net/test/grsecurity-2.2.2-2.6.39.1-201106132135.patch

	log "I" "Appliquation du patch grsecurity"
	patch -p0 </usr/src/grsecurity-2.2.2-2.6.39.1-201106132135.patch
 
	log "I" "Copie de la config noyau"
	cp /usr/src/.config-2.6.39-perso /usr/src/linux-2.6.39.1.config

	cd linux-2.6.39.1
	# On choisit les options de compilation 
	# un peut d'aide sur http://www.grsecurity.net/confighelp.php

	make menuconfig
	
	# Activer "[*] Enable loadable module support"
 
	make -j4 all
 
	make modules_install
 
	fakeroot make-kpkg --initrd --append-to-version=-custom kernel_image kernel_headers
 

	# Installation du noyau et des headers 
	
	cd /usr/src
	ls -ail

	dpkg -i linux-headers-*.
	dpkg -i linux-image-*
 
	shutdown -r now

fi



 
 


#
aptitude -y install ntpdate ccze ssh lsof libstring-mkpasswd-perl ccze




 
echo '/usr/lib/sftp-server' >> /etc/shells
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
