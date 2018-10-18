#!/usr/bin/env bash
set -e
if [ $# -ne 3 ]; then
    echo
    echo "    Usage: $0 install_dir link_dir prod|dev"
    echo
    echo "    e.g.   $0 s20180929 pahma prod"
    echo
    exit 0
fi

if [ ! -d $1 ] ; then echo "$1 does not exist... exiting" ; exit 1 ; fi
if [ -d search_$2 -a ! -L search_$2 ] ; then echo "search_$2 exists and is not a symlink ... cowardly refusal to rm it and relink it" ; exit 1 ; fi
rm -f search_$2
ln -s $1 search_$2
if [ "$3" == "prod" ]; then
  echo "remaking links to db and log for production deployment"
  cd $1
  # link the log dir to the "permanent" log dir
  rm -f log/
  ln -s /var/log/blacklight/$2 log
  # link the db directory to the "permanent" db directory
  rm -f db/
  ln -s /var/blacklight-db/$2 db
  export RAILS_ENV=production
  rake db:migrate
else
  echo "leaving db and log as is for dev deployment"
  cd $1
  # nb: right now, only the production migration works, for some reason...
  export RAILS_ENV=production
  rake db:migrate
fi
echo relinking and migrating done. now restart apache...
