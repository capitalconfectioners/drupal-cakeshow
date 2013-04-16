#!/bin/bash

INSTALL_ROOT=$1
INSTALL_DIR=${INSTALL_ROOT}/capitalconfectioners

if [ -t 0 ]
then
    ANSWER=
else
    ANSWER=--yes
fi

if [ $# -lt "2" ]
then
    read -s -p Password: PASSWORD
    echo
else
    PASSWORD=$2
fi

drupal_installed() {
    if [ -d $INSTALL_DIR ]
    then
	pushd $INSTALL_DIR
	drush status | grep -q "Drupal version"
	INSTALLED=$?
	popd
	return $INSTALLED
    else
	return 1
    fi
}

install_modules() {
    TO_INSTALL=()
    for module in "$@"
    do
	echo "(${module})"
	if drush pm-list --status="not installed" | grep -q "(${module})"
	then
	    echo "${module} not installed"
	    TO_INSTALL=( ${TO_INSTALL[@]} $module )
	fi
    done

    echo ${TO_INSTALL[@]}

    drush ${ANSWER} en ${TO_INSTALL[@]} || exit 1
}

echo "Checking for drupal"

if ! drupal_installed
then
    echo "Installing Drupal"
    drush dl drupal-7.x ${ANSWER} --destination=${INSTALL_ROOT} --drupal-project-rename=capitalconfectioners || {
	echo "Drupal install failed"
	exit 1
    }
else
    echo "Drupal already installed"
fi

cd ${INSTALL_DIR}

if ! drush status | grep -q "Drupal boostrap"
then
    echo "Installing Cakeshow site"
    drush site-install standard ${ANSWER} --db-url=mysql://cakecuba_capc:${PASSWORD}@localhost/cakecuba_capitalc --site-name=CapitalConfectioners --account-name=admin --account-pass=${PASSWORD} || {
	echo "site install failed"
	exit 1
    }
else
    echo "Cakeshow site already installed"
fi

drush ${ANSWER} dl libraries,ctools,views,addressfield,rules,entity,commerce,commerce_stripe,commerce_extra_panes || exit 1

install_modules commerce commerce_ui
install_modules commerce_customer commerce_customer_ui
install_modules commerce_price
install_modules commerce_line_item commerce_line_item_ui
install_modules commerce_order commerce_order_ui
install_modules commerce_checkout commerce_payment commerce_product
install_modules commerce_cart commerce_product_pricing
install_modules commerce_product_ui
install_modules commerce_tax_ui
install_modules commerce_stripe
install_modules commerce_extra_panes
