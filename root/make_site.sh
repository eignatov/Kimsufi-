#!/bin/bash

set -x
# Nom d'utilisateur
USERNAME=$1
MOTDEPASSE=`mkpasswd.pl --length=20 --special=5 --digit=3`

# Nom de domaine
DNS=$2

# Apache / nginx
TYPE=$3

# Mysql true/false
MYSQL=$4

# Commentaire
COMMENT=$3

# Fichiers de conf par default
SKEL=/root/skel

# Répertoire web
WEB=/var/www

#####################################
# function log()
#####################################
# write in /var/log/make_site.log
# @param1: type '+' or 'E' or 'I'
# @param2: 'message' 
log() (
	echo $1": $(date +%D' '%R':'%S) "$2 >> /var/log/make_site.log
	echo $1": $(date +%D' '%R':'%S) "$2 > /dev/stdout
)

#####################################
# function ajout_user()
#####################################
# Ajoute un utilisateur
# @param1: Utilisateur
# @param2: Mot de passe
# @param3: Commentaire
ajout_user() (
	if [[ -n `grep "^$1:" /etc/passwd` ]];then
		log "E" "L'utilisateur existe déjà"
		exit 2
	fi
	
	useradd	--base-dir=/var/www/$1		\
		--comment="$3"			\
		--no-user-group			\
		--shell=/usr/lib/sftp-server	\
		--password=$2			\
		$1
	
	if [[ $? -ne 0 ]];then
		log "E" "Echec dans la création de l'utilisateur"
		exit 2
	fi
	
	log "I" "Création de l'utilisateur ${USERNAME}"
	exit 0
)

#####################################
# function ajout_rep()
#####################################
# Créer un répertoire
# @param1 user
# @param2 Site web
# @param3 racine des sites
ajout_rep() (
	mkdir -p -v $3/$1/$2/public_html
	mkdir -p -v $3/$1/$2/logs
	mkdir -p -v $3/$1/$2/tmp
		
	chown	--verbose	\
		--preserve-root	\
		--recursive	\
		$1:www-data $3/$1
)


#####################################
# function copie_skel()
#####################################
# Copie les fichiers de conf
# @param1 fichiers d'origines skel
# @param2 Dossier web
# @param3 user
# @param4 Site web 
# @param5 Conf nginx/apache

copie_skel() (
	if [[ "$" = "nginx" ]];then
		# NGINX
		sed -e "s%DNS%$DNS%; s%WEB%$WEB%; s%USERNAME%$USERNAME%" $1/nginx > /etc/nginx/sites-enabled/$4_$5
	else 
		# NGINX -> APACHE
		sed -e "s/DNS/$DNS/; s/WEB/$WEB/; s/USERNAME/$USERNAME/" $1/nginx_apache > /etc/nginx/sites-enabled/apache_$4_$5
		sed -e "s/DNS/$DNS/; s/WEB/$WEB/; s/USERNAME/$USERNAME/" $1/apache > /etc/apache2/sites-available/$4_$5
		/usr/sbin/a2ensite $4_$5
	fi
	
	# Pools PHP
	sed -e "s/DNS/$DNS/; s/WEB/$WEB/; s/USERNAME/$USERNAME/" $1/php > /etc/php5/fpm/pool.d/$4_$5
)

ajout_user ${USERNAME} ${MOTDEPASSE} ${COMMENT} || exit 2
ajout_rep ${USERNAME} ${DNS} ${WEB}
copie_skel ${SKEL} ${WEB} ${TYPE} ${USERNAME} ${DNS} 

echo "Mot de passe : ${MOTDEPASSE}"

#touch /etc/php5/fpm/pool.d/$1.conf


