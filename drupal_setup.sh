#!/bin/bash

INSTALL_ROOT=$1

ANSWER=--yes

if [ $# -lt "2" ]
then
    read -s -p Password: PASSWORD
else
    PASSWORD=$2
fi

echo "Installing Drupal"
drush dl drupal-7.x ${ANSWER} --destination=${INSTALL_ROOT} --drupal-project-rename=capitalconfectioners || {
    echo "Drupal install failed"
    exit 1
}

cd ${INSTALL_ROOT}/capitalconfectioners

echo "Installing Cakeshow site"
drush site-install standard ${ANSWER} --db-url=mysql://cakecuba_capc:${PASSWORD}@localhost/cakecuba_capitalc --site-name=CapitalConfectioners --account-name=admin --account-pass=${PASSWORD} || {
    echo "site install failed"
    exit 1
}

drush ${ANSWER} dl libraries,ctools,views,addressfield,rules,entity,commerce,commerce_stripe,commerce_extra_panes || exit 1

drush ${ANSWER} en commerce commerce_ui || exit 1
drush ${ANSWER} en commerce_customer commerce_customer_ui || exit 1
drush ${ANSWER} en commerce_price || exit 1
drush ${ANSWER} en commerce_line_item commerce_line_item_ui || exit 1
drush ${ANSWER} en commerce_order commerce_order_ui || exit 1
drush ${ANSWER} en commerce_checkout commerce_payment commerce_product || exit 1
drush ${ANSWER} en commerce_cart commerce_product_pricing || exit 1
drush ${ANSWER} en commerce_product_ui || exit 1
drush ${ANSWER} en commerce_tax_ui || exit 1
drush ${ANSWER} en commerce_stripe || exit 1
drush ${ANSWER} en commerce_extra_panes || exit 1
