#!/bin/bash

# Utilisateur
USERNAME=$1

# Mot de passe aléatoire
MOTDEPASSE=`mkpasswd.pl --length=20 --special=5 --digit=5`

# Mot de passe aléatoire Mysql
MOTDEPASSE_DB=`mkpasswd.pl --length=20 --special=0 --digit=5`

# Nom de domaine
DNS=$2

# Apache / nginx
TYPE=$3

# Mysql true/false
MYSQL=$4

# Commentaire < Mail
COMMENT=$5

# Fichiers de conf par default
SKEL=/root/skel

# Répertoire web
WEB=/var/www



#####################################
# function aide()
#####################################
# Affiche l'aide
aide() (
	echo "./make_site.sh <utilisateur> <dns> <type> <mysql> <commentaire>"
	echo "Exemples :" 
	echo "Un site sous nginx avec mysql"
	echo -e "\t./make_site.sh yo_www lepage.info nginx true \"Site web principale\""
	echo "Un site sous apache avec mysql et nginx en frontal"
	echo -e  "\t./make_site.sh quentin_www lovepussy.com apache true \"I love pussy\""
)

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
	
	useradd	--home=/			\
		--comment="$3"			\
		--gid="sftponly"		\
		--shell=/usr/lib/sftp-server	\
		--password=$2			\
		$1

	echo -e "${2}\n${2}" | passwd $1

	if [[ $? -ne 0 ]];then
		log "E" "Echec dans la création de l'utilisateur"
		exit 2
	fi
	
	adduser $1 sftponly

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
	mkdir -p -v $3/$1/public_html
	mkdir -p -v $3/$1/logs
	mkdir -p -v $3/$1/tmp
	mkdir -p -v $3/$1/cgi-bin

# FIX Ajout les fichiers de logs
	touch $3/$1/logs/php-slow.log
	touch $3/$1/logs/apache_error.log
	touch $3/$1/logs/apache_access.log
		
	chown	--verbose	\
		--preserve-root	\
		--recursive	\
		$1:www-data $3/$1
	chown root:root $3/$1
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
	if [[ "$5" = "nginx" ]];then
		# NGINX
		sed -e "s%DNS%$DNS%g;" -e "s%WEB%$WEB%g;" -e "s%USERNAME%$USERNAME%g" $1/nginx > /etc/nginx/sites-enabled/$3_$4
	else 
		# NGINX -> APACHE
		sed -e "s/DNS/$DNS/g;" -e "s%WEB%$WEB%g;" -e "s/USERNAME/$USERNAME/g" $1/nginx_apache > /etc/nginx/sites-enabled/apache_$3_$4
		sed -e "s/DNS/$DNS/g;" -e "s%WEB%$WEB%g;" -e "s/USERNAME/$USERNAME/g" $1/apache > /etc/apache2/sites-available/$3_$4
		/usr/sbin/a2ensite $3_$4
		echo "127.0.0.1 $4" >> /etc/hosts
	fi
	
	# Pools PHP
	sed -e "s/DNS/$DNS/;" -e "s%WEB%$WEB%;" -e "s/USERNAME/$USERNAME/" $1/php > /etc/php5/fpm/pool.d/$3_$4
)

#####################################
# function ajout_db()
#####################################
# Creer une BD mysqll
# @param1: user
# @param2: password 
ajout_db() (
	MYSQL=`which mysql`
 
	Q1="CREATE DATABASE IF NOT EXISTS db_$1;"
	Q2="GRANT ALL ON *.* TO '$1'@'localhost' IDENTIFIED BY '$2';"
	Q3="FLUSH PRIVILEGES;"
	SQL="${Q1}${Q2}${Q3}"
	$MYSQL -uroot -p -e "$SQL"
)

if [ $# -ne 5 ]
then 
	aide
	exit 0
fi

ajout_user ${USERNAME} ${MOTDEPASSE} ${COMMENT} || exit 2
ajout_rep ${USERNAME} ${DNS} ${WEB}
copie_skel ${SKEL} ${WEB} ${USERNAME} ${DNS} ${TYPE}

/etc/init.d/apache2 reload
/etc/init.d/nginx reload
/etc/init.d/php5-fpm restart

if [[ "$4" = "true" ]];then
	echo "Création d'une base de donnée"
	echo "MDP mysql root :"
	ajout_db ${USERNAME} ${MOTDEPASSE_DB}
fi


echo "HOST :"
echo "SITE : ${DNS}"
echo "USER : ${USERNAME}"
echo "PASS : ${MOTDEPASSE}"

if [[ "$4" = "true" ]];then
	echo "-----db-----"
	echo "DB NAME : db_${USERNAME}"
	echo "DB USER : ${USERNAME}"
	echo "DB PASS : ${MOTDEPASSE_DB}"
fi
