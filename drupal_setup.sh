#!/bin/bash

INSTALL_ROOT=$1

if [ $# -lt "2" ]
then
    read -s -p Password: PASSWORD
else
    PASSWORD=$2
fi

echo "Installing Drupal"
drush dl drupal-7.x --yes --destination=${INSTALL_ROOT} --drupal-project-rename=capitalconfectioners || {
    echo "Drupal install failed"
    exit 1
}

drush vset clean_url 1 --yes

cd ${INSTALL_ROOT}/capitalconfectioners

echo "Installing Cakeshow site"
drush site-install standard --yes --db-url=mysql://cakecuba_capc:${PASSWORD}@localhost/cakecuba_capitalc --site-name=CapitalConfectioners || {
    echo "site install failed"
    exit 1
}

