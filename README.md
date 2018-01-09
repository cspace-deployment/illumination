# illumination
Blacklight customizations for UC Berkeley

Not much of a How To yet! Sorry!

Try the following, assuming you have installed all the RoR and Solr prerequisites. Probably it is easiest to first
install a "vanilla" Blacklight deployment, then try the ```illumination``` code below.

See the Blacklight documentation:

https://github.com/projectblacklight/blacklight/wiki/Quickstart

http://projectblacklight.org/

# Installation

To install the rickety PAHMA customizations:

First, you'll need to be inside the Berkeley firewall or have access via the VPN (the Solr server for the PAHMA Public Portal is not available to the outside world. So, start that up if needed.

```
cd <where_you_want_to_install_blacklight>
```

Get the two repos you’ll need...

```
git clone https://github.com/jblowe/illumination.git
git clone https://github.com/cspace-deployment/django_example_config.git
```

Now run the script to install BL and customize for PAHMA

NB: 

1. you’ll be asked in the middle of this to resolve a conflict:

```
   conflict  app/controllers/search_history_controller.rb
Overwrite /Users/jblowe/search_pahma/app/controllers/search_history_controller.rb? (enter "h" for help) [Ynaqdh] 
```

(I’m not sure it matters what you answer at the moment...

2. You’ll be asked about installing a local search form. Say y.

```
Install local search form with advanced link? (y/N) y
```

The install script takes 3 arguments: 

```
./illumination/install.sh tenant app_name portal_config_file
```

e.g.

```
./illumination/install.sh pahma search_pahma django_example_config/pahma/config/pahmapublicparms.csv 

********************************************************************
new blacklight app customized for pahma created in ~/search_pahma.
to start it up in development:

    cd search_pahma
    rails s

then visit https://localhost:3000 to test
********************************************************************
```
Do as it says:

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

# Important Caveats

* This deployment expects to be able to access the public PAHMA Solr server at:

https://webapps-dev.cspace.berkeley.edu/solr/pahma-public

* If you are doing development that requires a different Solr server, you'll need to update that in ```config/blacklight.yml```.

Typically, you'll want your own Solr server, with your own data, running on localhost.

To do this, you'll need to:

1. Install Solr (we are using Solr4 at the moment, alas)
2. Configure Solr for the ```pahma-public``` core (see below for how to do this).
3. Start it up.
4. Load some test data. (Some or all of the PAHMA public data extract, contact jblowe@berkeley.edu to get this file.)

* Caveat Utilizator: many BL and other features are not working correctly at the moment; see the UCB JIRAs for details.

