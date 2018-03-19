#!/usr/bin/env bash
#set -e
#set -x
tenant=$1
app_name=$2
portal_config_file=$3
current_directory=`pwd`
echo "pwd = ${current_directory}"

if [ -d "${app_name}" ]; then
  echo "Target directory ${app_name} already exists; please remove first."
  echo "$0 tenant app_name portal_config_file"
  exit
fi

if [ ! -f "${portal_config_file}" ]; then
  echo "Can't find ${portal_config_file}. Please verify name and location"
  echo "$0 tenant app_name portal_config_file"
  exit
fi

rails new ${app_name} -m https://raw.github.com/projectblacklight/blacklight/master/template.demo.rb

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/src"

cd ${source_dir}
echo "Getting Blacklight custom code from from" `pwd`
git clean -fd
git checkout -- *

perl -i -pe "s/#TENANT#/${tenant}/g" ${source_dir}/*

python ${source_dir}/../ucb_bl.py ${portal_config_file} > bl_config.txt

# configure BL using existing Portal config file
cat ${source_dir}/catalog_controller.template bl_config.txt > ${source_dir}/catalog_controller.rb

cd ${current_directory}
cd ${app_name}

echo "Customizing Blacklight app in" `pwd`

cp ${source_dir}/Gemfile .
cp ${source_dir}/blacklight.yml config/
#cp ${source_dir}/routes.rb config/
cp ${source_dir}/blacklight.en.yml config/locales/
cp ${source_dir}/blacklight_advanced_search.en.yml config/locales/
cp ${source_dir}/development.rb config/environments/
cp ${source_dir}/application_helper.rb app/helpers/
# diff ${source_dir}/catalog_controller.rb app/controllers/catalog_controller.rb
cp ${source_dir}/catalog_controller.rb app/controllers/
cp ${source_dir}/search_history_controller.rb app/controllers/

mkdir -p app/helpers/blacklight
# diff ${source_dir}/catalog_helper_behavior.rb app/helpers/blacklight/
cp ${source_dir}/catalog_helper_behavior.rb app/helpers/blacklight/

bundle update
# stop the troublesome spring server, for now
bin/spring stop

rails generate blacklight_range_limit:install
rails generate blacklight_gallery:install
#rails generate blacklight_advanced_search:install

# stop the troublesome spring server again, for now
bin/spring stop

# additional customization of templates and css
cp ${source_dir}/*.svg public/
cp ${source_dir}/*.png public/
cp ${source_dir}/splash_images/* public/
cp -r ${source_dir}/fonts public/
cp ${source_dir}/header-logo-${tenant}.png public/header-logo.png

mkdir -p app/views/shared
cp ${source_dir}/_header_navbar.html.erb app/views/shared/
cp ${source_dir}/_footer.html.erb app/views/shared/
cp ${source_dir}/_splash.html.erb app/views/shared/

mkdir -p app/views/advanced
cp ${source_dir}/_advanced_search_form.html.erb app/views/advanced/

cp ${source_dir}/_user_util_links.html.erb app/views/

# diff ${source_dir}/${tenant}_catalog_controller.rb app/controllers/catalog_controller.rb
cp ${source_dir}/${tenant}_catalog_controller.rb app/controllers/catalog_controller.rb
cp ${source_dir}/${tenant}_search_history_controller.rb app/controllers/search_history_controller.rb

cp ${source_dir}/${tenant}_header_navbar.html.erb app/views/shared/_header_navbar.html.erb
cp ${source_dir}/${tenant}_footer.html.erb app/views/shared/_footer.html.erb
cp ${source_dir}/${tenant}_splash.html.erb app/views/shared/_splash.html.erb

mkdir -p app/views/catalog/
cp ${source_dir}/_home_text.html.erb app/views/catalog/
cp ${source_dir}/_search_form.html.erb app/views/catalog/

cp ${source_dir}/${tenant}_home_text.html.erb app/views/catalog/_home_text.html.erb
cp ${source_dir}/${tenant}_search_form.html.erb app/views/catalog/_search_form.html.erb

cp ${source_dir}/_variables.scss app/assets/stylesheets/
cp ${source_dir}/${tenant}_variables.scss app/assets/stylesheets/_variables.scss

cp ${source_dir}/blacklight.scss app/assets/stylesheets/

echo
echo "********************************************************************"
echo "new blacklight app customized for ${tenant} created in ~/${app_name}."
echo "to start it up in development:"
echo ""
echo "    cd ${app_name}"
echo "    rails s"
echo ""
echo "then visit https://localhost:3000 to test"
echo "********************************************************************"

