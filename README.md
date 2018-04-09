# illumination
Blacklight customizations for UC Berkeley.

Just exactly the files needed to deploy into an existing vanilla BL installation to make it work for the various UCB "museum portals".

_Caveat utilizator!_ This is all fresh and wet behind the gills!

## Prerequisites

First, you must have have installed all the RoR and Solr prerequisites. Probably it is easiest to first
install and run a "vanilla" Blacklight deployment, then try the ```illumination``` code described below.

See the Blacklight documentation:

https://github.com/projectblacklight/blacklight/wiki/Quickstart

http://projectblacklight.org/

## Installation

To install the rickety PAHMA customizations:

_NB: you'll need to be inside the Berkeley firewall or have access via the VPN (the Solr server for the 
PAHMA Public Portal is not available to the outside world). So, start your VPN client up if needed._

```
cd <where_you_want_to_install_blacklight>
```

1. Get the two repos you’ll need...

```
git clone https://github.com/jblowe/illumination.git
git clone https://github.com/cspace-deployment/django_example_config.git
```

2. Run the script to install BL and customize for PAHMA

_**NB before you kick off the install script:**_ 

a. you may be asked in the middle of this to resolve a conflict:

```
   conflict  app/controllers/search_history_controller.rb
Overwrite /Users/jblowe/search_pahma/app/controllers/search_history_controller.rb? (enter "h" for help) [Ynaqdh] 
```

(I’m not sure it matters what you answer at the moment...)

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
./illumination/install.sh pahma search_pahma ~/django_example_config/pahma/config/pahmapublicparms.csv 

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

* This deployment expects to be able to access the public PAHMA Solr server at:

  https://webapps-dev.cspace.berkeley.edu/solr/pahma-public

* If you are doing development that requires a different Solr server, you'll need to update that in ```config/blacklight.yml```.

Typically, you'll want your own Solr server, with your own data, running on localhost.

To do this, you'll need to:

1. Install Solr (we are using Solr5 at the moment, alas)
2. Configure Solr for the ```pahma-public``` core (see below for how to do this).
3. Start it up.
4. Load some test data. (Some or all of the PAHMA public data extract, contact jblowe@berkeley.edu to get this file.)

* Caveat Utilizator: many BL and other features are not working correctly at the moment; see the UCB JIRAs for details.

## Install a local Solr5 server

The Solr server used for the UCB BL deployments

## Google Analytics and robots.txt

Google Analytics is not yet enabled for this Blacklight site.

By default, ```public/robots.txt``` is empty. For deployments where you want to block
crawlers (e.g. development deployments) you may wish to change this. See, e.g.:

https://issues.collectionspace.org/browse/DJAN-98

## Monitoring with god

On EC2, the RoR services have monitored using ```god```.

In this repo there is a file called ```howto-ec2.txt``` which shows how
to configure an EC2 instance with the UCB demo portals and ```god```.

Note that while this description pertains to a server serving all 5 UCB portals, 
it currently focuses on the PAHMA deployment.

Please refer to this file for the basics on how to set things up.

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

## Deploying an update

Assuming that everything is updated in GitHub, here's the current working
process. Yes, it could use some help!

```
$ ssh blacklight-dev.ets.berkeley.edu

jblowe@blacklight-dev:~$ sudo su - blacklight

# the rails apps and their various versions are all deployed in the projects directory
cd projects
# get rid of existing symlink
rm search_pahma
# redeploy PAHMA BL to search_pahma
./illumination/install.sh pahma search_pahma ~/projects/django_example_config/pahma/config/pahmapublicparms.csv
# move the configured directory out of the way

#### for now, it seems, more tweaking required:
cd search_pahma
export RAILS_ENV=production
# need to set a secret key since it's not set in the environment
vi config/secrets.yml 
# devise seems to need editing too...
vi config/initializers/devise.rb
# apply migrations
rake db:migrate

# if a production deployment, don't forget to remove robots.txt
rm public/robots.txt

cd ..
mv search_pahma s3

# make a symlink
ln -s s3 search_pahma
cd search_pahma
bundle install

# or use the script:

./relink.sh s3

# ok now you can restart apache (probably you'll need to exit the app user account to do to):
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