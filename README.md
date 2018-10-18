# illumination
Blacklight customizations for UC Berkeley museum portals.

Just exactly the files needed to deploy into an existing vanilla BL installation to make it work for the various UCB "museum portals".

The document shows the steps for deploying the PAHMA Blacklight app ("pahma"), but you should be able to substitute whatever institution key you like and it will work.

_Caveat utilizator!_ This is all fresh and wet behind the gills!

## Prerequisites

First, you must have have installed all the RoR prerequisites (and if using a local Solr server which you should 
for testing, those prerequisites, too). Probably it is easiest to first
install and run a "vanilla" Blacklight deployment, then try the ```illumination``` code described below.

See the Blacklight documentation:

https://github.com/projectblacklight/blacklight/wiki/Quickstart

http://projectblacklight.org/

## Initial Installation (i.e. on a new server)

To install the rickety PAHMA customizations:

_NB: you'll need to be inside the Berkeley firewall or have access via the VPN (the Solr server for the 
PAHMA Public Portal is not available to the outside world). So, start your VPN client up if needed._

```
cd <where_you_want_to_install_blacklight> # for UCB deployments on RTL servers, this is ~/projects
```

1. Get the two repos you’ll need...

```
git clone https://github.com/cspace-deployment/illumination.git
git clone https://github.com/cspace-deployment/django_example_config.git
```

NB: this step is only needed when doing a "clean install" on a new server. Once the repos are there
the only thing you'll need to do is update them (i.e. "```git pull -v```")

2. Run the script to install BL and customize for e.g. PAHMA

The install script takes 4 arguments:

```
./illumination/install.sh tenant app_name absolute_path_to_portal_config_file version
```

e.g. on your "local system", where the "home directory" for Blacklight is, say, ```~```:

```
./illumination/install.sh pahma s20180927 ~/django_example_config/pahma/config/pahmapublicparms.csv 1.1.0

[...]
********************************************************************
new blacklight app (version 1.1.0) customized for pahma created in /Users/myhome/s20180927.
to start it up in development:

    cd s20180927
    rails s

    or

    passenger start

then visit https://localhost:3000 to test
********************************************************************
```

This will install version 1.1.0 in the ~/s2018097 directory.

3. To run "locally", using the development server, do as it says.

  _NB: make sure you either are inside the UCB firewall (VPN, etc.)
        or that a proper Solr server is configured in the development section
        in config/blacklight.yml_

```
cd s2018097
rails s
=> Booting Puma
=> Rails 5.1.4 application starting in development 
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.11.0 (ruby 2.4.2-p198), codename: Love Song
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0.0.0.0:3000
Use Ctrl-C to stop
```

Now see if you get a search page:

e.g.:

http://localhost:3000

or

http://localhost:3000/?utf8=%E2%9C%93&search_field=objmusno_s&q=%221-1000%22

If you are deploying on an RTL server (in either the Dev or Prod environments), read the following section.

## Deploying an update on the RTL server (either Production or Development)

* On RTL servers  the "home directory" for Blacklight is ```~/projects```.
* The Passenger / Apache configuration points to a fixed directory which is symlinked to the deployment directory.
* The dialog below assumes you are deploying the 'pahma' Portal.
* You'll need to have the version number you wish to deploy (e.g. "1.1.0" is shown in the example below) before you start.
* You can check the tags in the repo (e.g. ```git tag```) to find what versions are available.

```
$ ssh blacklight-prod.ets.berkeley.edu

jblowe@blacklight-prod:~$ sudo su - blacklight

# the rails apps and their various versions are all deployed in the ~/projects directory

# first, get the latest code
cd ~/projects/illumination ; git pull -v
cd ~/projects/django_example_config ; git pull -v

# deploy the desired version of the Blacklight RoR app in a new directory (we've been
# using directory names of the form sYYYYMMDD; but do as you like!)
./illumination/install.sh pahma s20181015 ~/projects/django_example_config/pahma/config/pahmapublicparms.csv 1.2.0 development &

# remake the two symlinks...(prod only. you can skip this on dev)
# link the log dir to the "permanent" log dir
rm -rf log/
ln -s /var/log/blacklight/pahma log
# link the db directory to the "permanent" db directory
rm -rf db
ln -s /var/blacklight-db/pahma db

# we need to do the migration...
export RAILS_ENV=production
rake db:migrate

# remake the symlink between the actual directory and the directory passenger expects (e.g. 'search_pahma')
./illumination/relink.sh s20181015 pahma production

# you'll need to restart apache. the blacklight sudo user can't do that, so you'll need to:
exit
sudo apache2ctl restart
```

NB: if for some reason you need to check or change some of the secret keys...

```
# to check that it is indeed set in the environment
printenv | grep SECRET_KEY
SECRET_KEY_BASE=xxxxxxxxxxxxxxxxxxxxxx...
# here's where it is accessed:
vi config/secrets.yml 
# and here (devise CAN have its own, if you really wanted to...)
vi config/initializers/devise.rb
# you need to re-apply migrations if you change anything
rake db:migrate
```


Here's what we have for ~/.profile now (need to setup RVM and SECRET_KEY_BASE)

```
blacklight@blacklight-dev:~$ cat .profile
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Blacklight / RoR needs this in the environment
export SECRET_KEY_BASE=yougottaputsomethingsuitablehere
```

Backing up database..
other maintenance..

## Running under Passenger or Rails development server

On the RTL cloud server (```blacklight-(dev,prod).ets.berkeley.edu```), the RoR service
is being running using Passenger under Apache.

The Passenger gem is now required and one can start the server in at least the following ways:

```bash
export RAILS_ENV=development
passenger start
```
or

```bash
export RAILS_ENV=production
rails s
```

Then you should be able to visit the app at [http://portal-dev.hearstmuseum.berkeley.edu]

## About the production parameters

There's still something odd in the production parameters. For production ```eager_load``` should be true, but
at the moment the app won't run with that.

e.g.

```
diff config/environments/production.rb ~/production.rb 

11c11
<   config.eager_load = false
---
>   config.eager_load = true
31c31
<   config.assets.compile = true
---
>   config.assets.compile = false
```

## Important Caveats

* The current implementation expects to run Rails under Passenger with Apache. The steps to get all that set up are not described here and are dependent on OS details.

* This deployment expects to be able to access the public PAHMA Solr server at:

  https://webapps-dev.cspace.berkeley.edu/solr/pahma-public

  This service _is_ available inside the UCB firewall. If you are outside, you'll need to install your own (local) Solr server with this core.

* If you are doing development that requires a different Solr server, you'll need to update that in ```config/blacklight.yml```.

## Installing a local Solr5 server

At the moment, the deployment assumes you'll use either the Production or Development version of the museums
public Solr core. These are configured in ```blacklight.yml```.  You can set which Solr server is used
using the ```RAILS_ENV``` environment variable and the ```rake migrate``` task (see below).

If you want your own Solr server, with your own data, running on localhost, read on.

To do this, you'll need to:

1. Install Solr (we are using Solr5 at the moment, alas.)
2. Configure a Solr core, e.g. for  ```pahma-public``` (see below for how to do this).
3. Start it up.
4. Load some test data. (Some or all of the PAHMA public data extract, contact jblowe@berkeley.edu to get this file.)

* Caveat Utilizator: many BL and other features are not working correctly at the moment; see the UCB JIRAs for details.

The Solr servers used for the UCB BL deployments:

Development (only available to .berkeley.edu within the UCB Firewall (VPN, AirBears2, direct connect):

https://webapps-dev.cspace.berkeley.edu/solr/#TENANT#-public

Production:

https://webapps.cspace.berkeley.edu/solr/#TENANT#-public

\#TENANT# is one of (bampfa, botgarden, pahma, ucjeps)

## Google Analytics and robots.txt

Google Analytics ("UA") is automatically enabled for production deployments. See e.g.

```blacklight.html.erb``` (where the tracking ID is hardcoded)

and

```app/assets/javascripts/google_analytics.js.coffee```

Yes, it is a bit complicated to get UA working in a Rails 5 app!

By default, ```public/robots.txt``` block _all_ crawlers. For deployments where you want to admit
crawlers (e.g. production deployments) you may wish to change this. See, e.g.:

https://issues.collectionspace.org/browse/DJAN-98

You may wish to preserve the ```robots.txt``` that was being used already.

To allow all comers, simply remove the file.

## Monitoring with god

On EC2, the RoR services had been monitored using ```god```.

In this repo there is a file called ```howto-ec2.txt``` which shows how
to configure an EC2 instance with the UCB demo portals and ```god```.

Note that while this description pertains to a server serving all 5 UCB portals, 
it currently focuses on the PAHMA deployment.

Please refer to this file for the basics on how to set things up.
