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

download_modules() {
    TO_INSTALL=""

    for module in "$@"
    do
	if ! [ -d sites/all/modules/${module} ]
	then
	    if [ -z "$TO_INSTALL" ]
	    then
		TO_INSTALL="$module"
	    else
		TO_INSTALL="${TO_INSTALL},${module}"
	    fi
	fi
    done

    if [ -n "$TO_INSTALL" ]
    then
	echo "Downloading modules: ${TO_INSTALL}"
	drush ${ANSWER} dl ${TO_INSTALL} || exit
    fi
}

install_modules() {
    TO_INSTALL=()
    for module in "$@"
    do
	if drush pm-list --status="not installed,disabled" | grep -q "(${module})"
	then
	    TO_INSTALL=( ${TO_INSTALL[@]} $module )
	fi
    done

    if [ -n "$TO_INSTALL" ]
    then
	echo "Installing modules: ${TO_INSTALL[@]}"
	drush ${ANSWER} en ${TO_INSTALL[@]} || exit 1
    fi
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

if ! drush status | grep -q "Drupal bootstrap"
then
    echo "Installing Cakeshow site"
    drush site-install standard ${ANSWER} --db-url=mysql://cakecuba_capc:${PASSWORD}@localhost/cakecuba_capitalc --site-name=CapitalConfectioners --account-name=admin --account-pass=${PASSWORD} || {
	echo "site install failed"
	exit 1
    }
else
    echo "Cakeshow site already installed"
fi

if ! [ -d sites/all/libraries/stripe-php ]
then
    echo "Installing Stripe PHP library"

    mkdir -p sites/all/libraries

    wget -nc https://code.stripe.com/stripe-php-1.7.15.tar.gz || exit 1
    tar xzvf stripe-php-1.7.15.tar.gz || exit 1
    mv stripe-php-1.7.15 sites/all/libraries/stripe-php || exit 1
else
    echo "Stripe PHP already installed"
fi

if ! [ -f sites/all/libraries/chosen/chosen/chosen.jquery.js ]
then
    echo "Installing Chosen jQuery plugin"

    mkdir -p sites/all/libraries

    wget -nc https://github.com/harvesthq/chosen/archive/v0.9.13.zip || exit 1
    unzip v0.9.13.zip -d sites/all/libraries || exit 1
    mv sites/all/libraries/chosen-0.9.13 sites/all/libraries/chosen || exit 1
else
    echo "Chosen jQuery plugin already installed"
fi

download_modules libraries ctools views addressfield rules entity commerce commerce_stripe commerce_extra_panes inline_entity_form views_megarow views_bulk_operations eva commerce_backoffice chosen shiny

# These are the core Drupal Commerce modules; their documentation
# recommends breaking up their installation into these chunks, to aid
# debugging installation failures
install_modules commerce commerce_ui
install_modules commerce_customer commerce_customer_ui
install_modules commerce_price
install_modules commerce_line_item commerce_line_item_ui
install_modules commerce_order commerce_order_ui
install_modules commerce_checkout commerce_payment commerce_product
install_modules commerce_cart commerce_product_pricing
install_modules commerce_product_ui
install_modules commerce_tax_ui

# Extra modules
install_modules commerce_stripe
install_modules commerce_extra_panes
install_modules inline_entity_form views_megarow views_bulk_operations eva
install_modules commerce_backoffice_product commerce_backoffice_order commerce_backoffice_content
install_modules chosen

# Actually an admin theme
install_modules shiny
