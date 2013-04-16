drupal-cakeshow
===============

Drupal installation, and any plugins that need to be written.

Vagrant
----------

Simply install Vagrant (http://vagrantup.com) and run `vagrant
up`. The SQL and Drupal admin passwords for vagrant instances are in
the puppet module, but should, obviously, not be used for publically
accessible machines.

Because the `drupal_setup.sh` script is not idempotent, any changes
you make to the Drupal installation will be wiped every time you
`vagrant up`

Drupal Installation
----------

The `drupal_setup.sh` script can be used to install Drupal, plus any
dependent modules. If we need to add more modules, we should add them
to that script.

**The script is not currently idempotent, so running it again will wipe
out your existing Drupal installation, and all your data!**


