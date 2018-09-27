#!/usr/bin/env bash
set -e
#set -x
tenant=$1
app_name=$2
portal_config_file=$3
tag=$4
deployment=$5
current_directory=`pwd`
echo "pwd = ${current_directory}"

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

if [ -d "${app_name}" ]; then
  echo "Target directory ${app_name} already exists; please remove first."
  echo "$0 tenant app_name portal_config_file [tag] [production]"
  exit
fi

if [ ! -f "${portal_config_file}" ]; then
  echo "Can't find ${portal_config_file}. Please verify name and location"
  echo "$0 tenant app_name portal_config_file [tag] [production]"
  exit
fi

echo "Creating new rails app in ${app_name}..."
rails new ${app_name} -m https://raw.github.com/projectblacklight/blacklight/master/template.demo.rb > install.log

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/src"
working_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/working_dir"

cd ${source_dir}

if [ -z "${tag}" ]; then
  echo "deploying master branch"
else
  git checkout ${tag}
  echo "deploying tag ${tag} from GitHub"
fi

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
# diff ${working_dir}/catalog_helper_behavior.rb app/helpers/blacklight/
cpalways ${working_dir}/catalog_helper_behavior.rb app/helpers/blacklight/

if [ "${deployment}" == "production" ]; then
  bundle install --deployment > bundle.log
  echo "deploying to production"
else
  bundle install > bundle.log
  echo "deploying for development (may overwrite Gemfile.lock, etc.)"
fi

# stop the troublesome spring server, for now
bin/spring stop

rails generate blacklight_range_limit:install
rails generate blacklight_gallery:install
rails generate blacklight_advanced_search:install

# stop the troublesome spring server again, for now
bin/spring stop

# google analytics stuff
cpalways ${working_dir}/blacklight.html.erb app/views/layouts/
cpalways ${working_dir}/google_analytics.js.coffee app/assets/javascripts/

# additional customization of templates and css
cpalways ${working_dir}/*.svg public/
cpalways ${working_dir}/*.png public/
cpalways ${working_dir}/robots.txt public/
cpalways ${working_dir}/header-logo-${tenant}.png public/header-logo.png
cp ${working_dir}/splash_images/* public/
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

# diff ${working_dir}/${tenant}_catalog_controller.rb app/controllers/catalog_controller.rb
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

# remove this when the footer refactoring is done.
cpalways ${working_dir}/${tenant}_application.css app/assets/stylesheets/application.css

rm -rf ${working_dir}

echo
echo "********************************************************************"
echo "new blacklight app customized for ${tenant} created in ${current_directory}/${app_name}."
echo "to start it up in development:"
echo ""
echo "    cd ${current_directory}/${app_name}"
echo "    rails s"
echo ""
echo "then visit https://localhost:3000 to test"
echo "********************************************************************"
