#!/usr/bin/env bash
set -e
#set -x
tenant=$1
app_name=$2
portal_config_file=$3
tag=$4
deployment=$5
current_directory=`pwd`

# this function cpalways wraps cp so that it always succeeds
# since we have set -e and since some of the files deployed may or may not exist for
# particular deployments, we need to prevent the script from stopping in this case.
# note it only works for copying single files.
# yes, this coulda been done with rsync or other shell tricks. but this is the way I did it.

function cpalways()
{
  if [ -e $1 ]; then
    echo "$1 found and copied to $2"
    cp $1 $2 2>/dev/null
  else
    echo "$1 not found"
  fi
  return 0
}

# check the command line parameters

if [ -d "${app_name}" ]; then
  echo "Target directory ${app_name} already exists; please remove first."
  echo "$0 tenant app_name portal_config_file tag|master production|development"
  exit
fi

if [ ! -f "${portal_config_file}" ]; then
  echo "Can't find portal config file '${portal_config_file}'. Please verify name and location"
  echo "$0 tenant app_name portal_config_file tag|master production|development"
  exit
fi

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/src"
working_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/working_dir"

if [ ! -d "${source_dir}" ]; then
  echo "Can't find directory '${source_dir}'. Please verify you are running this script from within the repo"
  echo "$0 tenant app_name portal_config_file tag|master production|development"
  exit
fi

# make sure we have the right code available
cd ${source_dir}

if [ "${tag}" == "master" ]; then
  echo "deploying master branch"
  git checkout master
elif [ "${tag}" == "notag" ]; then
  echo "deploying current (possibly uncommitted) code, as is"
elif [ `git tag --list "${tag}"` ]; then
    echo "deploying tag ${tag} from GitHub"
    #git checkout ${tag}
else
    echo "could not find tag '${tag}'. we need a valid tag, or 'notag' for current (possibly uncommitted) code, or 'master' for master branch"
    exit
fi

cd ${current_directory}

echo "Creating new rails app in ${current_directory}/${app_name}..."
rails new ${app_name} -m https://raw.github.com/projectblacklight/blacklight/master/template.demo.rb > install.log

cd ${source_dir}

echo "Copying Blacklight customized source code from from ${source_dir} to ${working_dir}"

# we put all the customized code into a temporary directory where we can munge it further...
cp -r ${source_dir} ${working_dir}

perl -i -pe "s/#TENANT#/${tenant}/g" ${working_dir}/*

python3 ${working_dir}/../ucb_bl.py ${portal_config_file} > bl_config_temp.txt

# configure BL using existing Portal config file
cat ${working_dir}/catalog_controller.template bl_config_temp.txt > ${working_dir}/catalog_controller.rb
rm bl_config_temp.txt

cd ${current_directory}/${app_name}

echo "Deploying Blacklight app in" `pwd`

cpalways ${working_dir}/Gemfile .
cpalways ${working_dir}/Gemfile.lock .
cpalways ${working_dir}/blacklight.yml config/
#cp ${working_dir}/routes.rb config/
cpalways ${working_dir}/blacklight.en.yml config/locales/
cpalways ${working_dir}/blacklight_advanced_search.en.yml config/locales/
cpalways ${working_dir}/development.rb config/environments/
cpalways ${working_dir}/production.rb config/environments/
cpalways ${working_dir}/application_helper.rb app/helpers/
# diff ${working_dir}/catalog_controller.rb app/controllers/catalog_controller.rb
cpalways ${working_dir}/catalog_controller.rb app/controllers/
cpalways ${working_dir}/search_history_controller.rb app/controllers/

mkdir -p app/helpers/blacklight
cpalways ${working_dir}/catalog_helper_behavior.rb app/helpers/blacklight/

if [ "${deployment}" == "production" ]; then
  echo "deploying to production"
  bundle install --deployment > bundle.log
else
  echo "deploying for development (may overwrite Gemfile.lock, etc.)"
  bundle install > bundle.log
fi

# stop the troublesome spring server, for now
bin/spring stop

# TODO fix this: --force needed for now as there is a conflict between range limit and advanced search
rails generate blacklight_range_limit:install --force
rails generate blacklight_gallery:install --force
rails generate blacklight_advanced_search:install --force

# stop the troublesome spring server again, for now
bin/spring stop

# google analytics stuff
cpalways ${working_dir}/blacklight.html.erb app/views/layouts/
cpalways ${working_dir}/google_analytics.js.coffee app/assets/javascripts/

# additional customization of static files, templates, and css
cp ${working_dir}/*.svg public/
cp ${working_dir}/*.png public/
cp ${working_dir}/splash_images/* public/
cpalways ${working_dir}/robots.txt public/
cpalways ${working_dir}/header-logo-${tenant}.png public/header-logo.png
cp -r ${working_dir}/fonts public/
# the favicon only needs to go one place, but I'm not sure which of the two possibilities is right.
# so for now, put it in both places.
cpalways ${working_dir}/favicon.png app/assets/images/favicon.png
cpalways ${working_dir}/${tenant}_favicon.png app/assets/images/favicon.png
cpalways ${working_dir}/favicon.png public
cpalways ${working_dir}/${tenant}_favicon.png public/favicon.png

mkdir -p app/views/shared
cpalways ${working_dir}/_header_navbar.html.erb app/views/shared/
cpalways ${working_dir}/_footer.html.erb app/views/shared/
cpalways ${working_dir}/_splash.html.erb app/views/shared/

mkdir -p app/views/advanced
cpalways ${working_dir}/_advanced_search_form.html.erb app/views/advanced/

cpalways ${working_dir}/_user_util_links.html.erb app/views/

cpalways ${working_dir}/${tenant}_catalog_controller.rb app/controllers/catalog_controller.rb
cpalways ${working_dir}/${tenant}_search_history_controller.rb app/controllers/search_history_controller.rb

cpalways ${working_dir}/${tenant}_header_navbar.html.erb app/views/shared/_header_navbar.html.erb
cpalways ${working_dir}/${tenant}_footer.html.erb app/views/shared/_footer.html.erb
cpalways ${working_dir}/${tenant}_splash.html.erb app/views/shared/_splash.html.erb

mkdir -p app/views/catalog/
cpalways ${working_dir}/_home_text.html.erb app/views/catalog/
cpalways ${working_dir}/_search_form.html.erb app/views/catalog/

cpalways ${working_dir}/${tenant}_home_text.html.erb app/views/catalog/_home_text.html.erb
cpalways ${working_dir}/${tenant}_search_form.html.erb app/views/catalog/_search_form.html.erb

cpalways ${working_dir}/_variables.scss app/assets/stylesheets/
cpalways ${working_dir}/${tenant}_variables.scss app/assets/stylesheets/_variables.scss

cpalways ${working_dir}/extras.scss app/assets/stylesheets/
cpalways ${working_dir}/${tenant}_extras.scss app/assets/stylesheets/extras.scss

cpalways ${working_dir}/blacklight.scss app/assets/stylesheets/

rm -rf ${working_dir}

echo
echo "********************************************************************"
echo "new blacklight app (version ${tag}) customized for ${tenant} created in ${current_directory}/${app_name}"
echo "to start it up in development mode:"
echo ""
echo "    cd ${current_directory}/${app_name}"
echo "    rails s"
echo ""
echo "    or"
echo ""
echo "    passenger start"
echo ""
echo "then visit https://localhost:3000 to test"
echo "********************************************************************"
