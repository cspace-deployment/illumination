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

## Installation

To install the rickety PAHMA customizations:

_NB: you'll need to be inside the Berkeley firewall or have access via the VPN (the Solr server for the 
PAHMA Public Portal is not available to the outside world). So, start your VPN client up if needed._

```
cd <where_you_want_to_install_blacklight> # for UCB deployments on ETS servers, this is ~/projects
```

1. Get the two repos you’ll need...

```
git clone https://github.com/cspace-deployment/illumination.git
git clone https://github.com/cspace-deployment/django_example_config.git
```

2. Run the script to install BL and customize for PAHMA

_**A couple remarks before you kick off the install script:**_ 

a. you may be asked in the middle of this to resolve one or more conflicts:

```
   conflict  app/controllers/search_history_controller.rb
Overwrite /Users/jblowe/search_pahma/app/controllers/search_history_controller.rb? (enter "h" for help) [Ynaqdh] 
```

(just hit return -- i.e. take the default Y...)

b. You’ll be asked about installing a local search form. Say y.

```
Install local search form with advanced link? (y/N) y
```

OK, now do the install. The install script takes 3 arguments: 

```
./illumination/install.sh tenant app_name absolute_path_to_portal_config_file
```

e.g.

```
./illumination/install.sh pahma search_pahma ~/projects/django_example_config/pahma/config/pahmapublicparms.csv 

[...]
********************************************************************
new blacklight app customized for pahma created in ~/search_pahma.
to start it up in development:

    cd search_pahma
    rails s

then visit https://localhost:3000 to test
********************************************************************
```
3. Do as it says:

```
cd search_pahma
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

## Important Caveats

* The current implementation expects to run Rails under Passenger with Apache. The steps to get all that set up are not described here and are dependent on OS details.

* This deployment expects to be able to access the public PAHMA Solr server at:

  https://webapps-dev.cspace.berkeley.edu/solr/pahma-public
  
  This service _is_ available inside the UCB firewall. If you are outside, you'll need to install your own (local) Solr server with this core.

* If you are doing development that requires a different Solr server, you'll need to update that in ```config/blacklight.yml```.

## Install a local Solr5 server

Typically, you'll want your own Solr server, with your own data, running on localhost.

To do this, you'll need to:

1. Install Solr (we are using Solr5 at the moment, alas.)
2. Configure Solr for the ```pahma-public``` core (see below for how to do this).
3. Start it up.
4. Load some test data. (Some or all of the PAHMA public data extract, contact jblowe@berkeley.edu to get this file.)

* Caveat Utilizator: many BL and other features are not working correctly at the moment; see the UCB JIRAs for details.

The Solr server used for the UCB BL deployments...

## Google Analytics and robots.txt

Google Analytics is not yet enabled for this Blacklight site.

By default, ```public/robots.txt``` block all crawlers. For deployments where you want to admit
crawlers (e.g. production deployments) you may wish to change this. See, e.g.:

https://issues.collectionspace.org/browse/DJAN-98

## Running under Passenger or Rails development server

On the ETS cloud server (```blacklight-(dev,prod).ets.berkeley.edu```), the RoR service
is being running using Passenger under Apache.

The Passenger gem is now required and one can start the server in at least the following ways:

```bash
export RAILS_ENV=production
passenger start
```
or

```bash
export RAILS_ENV=production
rails s
```

Then you should be able to visit the app at [http://blacklight-dev.ets.berkeley.edu:3000]

## Deploying an update on the ETS Production server

Assuming that everything is updated in GitHub, here's the current working
process. Yes, it could use some help!

```
$ ssh blacklight-prod.ets.berkeley.edu

jblowe@blacklight-dev:~$ sudo su - blacklight

# the rails apps and their various versions are all deployed in the projects directory
cd projects
# get rid of existing symlink
rm search_pahma
cd illumination
git pull -v
cd
~/illumination/install.sh pahma s20180505 ~/projects/django_example_config/pahma/config/pahmapublicparms.csv
cd projects/s20180505/
# remake the two symlinks...
# link the log dir to the "permanent" log dir
rm -rf log/
ln -s /var/log/blacklight/pahma log
# link the db directory to the "permanent" db directory
rm -rf db
ln -s /var/blacklight-db/pahma db
#
bundle install
export RAILS_ENV=production
rake db:migrate
# remake the symlink between the actual directory and the directory passenger expects
cd
./relink.sh s20180505
```

NB: it could be that you'll need to check some of the secret keys...
```
# the secret key is now set in the environment. but you could do it here:
vi config/secrets.yml 
# and here:
vi config/initializers/devise.rb
# you'd need to re-apply migrations
rake db:migrate
```

Other things to consider:
```
# if a production deployment, don't forget to remove robots.txt
rm public/robots.txt

# passenger expect the code to be deployed in a fixed directory, e.g. 'search_pahma'
# the relink script will do that as shown above:
./relink.sh s20180505

# or you can do it by hand:
# make a symlink
ln -s s20180505 search_pahma
cd search_pahma
bundle install

# ok now you can restart apache (probably you'll need to exit the app user account to do it):
exit
sudo apache2ctl graceful

# or run under passenger or rails dev server (see above)
```

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

## Monitoring with god

On EC2, the RoR services have been monitored using ```god```.

In this repo there is a file called ```howto-ec2.txt``` which shows how
to configure an EC2 instance with the UCB demo portals and ```god```.

Note that while this description pertains to a server serving all 5 UCB portals, 
it currently focuses on the PAHMA deployment.

Please refer to this file for the basics on how to set things up.
