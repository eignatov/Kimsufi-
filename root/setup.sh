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

if [[ -n `grep "step_kernel_1" /var/log/setup_step` ]];
then
	log "I" "L'installation du nouveau noyau a déjà été réalisé : $(uname -a)"

	log "I" "Installation des packages de base"
	aptitude -y install ntpdate  lsof libstring-mkpasswd-perl ccze htop zsh screen irssi curl p7zip-full unzip zip sysv-rc-conf imagemagick
	
	log "I" "Installation du client ntp"
	aptitude -y install ntpdate

	log "I" "MAJ de l'heure"
	ntpdate-debian
	
	log "I" "Crontab pour la MAJ de l'heure"
	/usr/bin/crontab -u root /root/crontab/ntp
	if [[ -n `crontab -l | grep ntpdate` ]];
	then
		rm -f /root/crontab_ntp
	else
		log "E" "Echec de l'ajout du crontab ntp"
	fi

	log "I" "Installation de rkhunter pour la recherche de rootkit"
	aptitude -y install rkhunter

	log "I" "Crontab pour la recherche automatique de rootkit"
	/usr/bin/crontab -u root /root/crontab/rootkit
	if [[ -n `crontab -l | grep rootkit` ]];
	then
		rm -f /root/crontab/rootkit
	else
		log "E" "Echec de l'ajout du crontab rootkit"
	fi
	
	log "I" "Crontab pour le backup"
	/usr/bin/crontab -u root /root/crontab/backup
	if [[ -n `crontab -l | grep sql` ]];
	then
		rm -f /root/crontab/backup
	else
		log "E" "Echec de l'ajout du crontab backup"
	fi

	
	log "I" "Installation de Bind"
	aptitude -y install bind9 bind9utils dnsutils
	mkdir /var/log/bind
	touch /var/log/bind/bind.log	
	touch /var/log/bind/querys.log
	chown -R bind:bind /var/log/bind	
	# garder ce paragraphe pour la fin de l'installation
	log "I" "Installation du firewall"
	aptitude -y install iptables
	chmod 500 /etc/init.d/firewall
	/usr/sbin/update-rc.d firewall remove
	/usr/sbin/update-rc.d firewall defaults
	log "I" "Tester le firewall /etc/init.d/firewall"

	log "I" "Installation de logwatch"
	aptitude -y install logwatch	
	
	log "I" "Installation de syslog-ng"
	aptitude -y install syslog-ng
	mkdir /var/lib/syslog-ng
	mkdir /var/log/fw

	touch /var/log/fw/in.log
	touch /var/log/fw/out.log


	log "I" "Installation de fail2ban"
	aptitude -y install fail2ban
	
	log "I" "Installation de divers trucs"
	aptitude -y install strace
	
	log "I" "Création d'un groupe pour les utilisateurs web"
	groupadd sftponly

elif [[ -n `grep "step_kernel_0" /var/log/setup_step` ]];
then
	log "E" "L'installation du kernel n'a pas été finalisé !"
	exit 2
else
	log "I" "Début de l'installation et compilation du noyau"
	echo "step_kernel_0" > /var/log/setup_step

	log "I" "Modification des sources"
	sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list

	log "I" "MAJ du système"
	aptitude update && aptitude -y full-upgrade
	
	log "I" "Installation des outils pour la compilation du noyau"
	aptitude -y install kernel-package libncurses5-dev fakeroot bzip2 build-essential lzma patch make vim-nox vim-scripts

	log "I" "Téléchargement du noyau"
	cd /usr/src
	wget -c http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.39.3.tar.gz
	tar -xzf linux-2.6.39.3.tar.gz
 
	log "I" "Appliquation du patch grsecurity"
	patch -p0 </usr/src/grsecurity-2.2.2-2.6.39.3-201107142110.patch
 
	log "I" "Copie de la config noyau"
	cp /usr/src/.config-2.6.39-perso /usr/src/linux-2.6.39.3/.config

	cd linux-2.6.39.3
	
	log "I" "Vérification des options de compilation"
	make menuconfig
	
	log "I" "Compilation du noyau. Prenez un café."
	make -j4 all
 
	log "I" "Installation des modules"
	make modules_install
 
	log "I" "Création des paquets du noyau"
	fakeroot make-kpkg --initrd --append-to-version=-custom kernel_image kernel_headers
 
	log "I" "Installation du noyau"
	cd /usr/src
	dpkg -i linux-headers-*.
	dpkg -i linux-image-*
 
	log "I" "Redémarrage !! Relancer le script ensuite"
	echo "step_kernel_1" > /var/log/setup_step

	shutdown -r now
fi

