set -e
tenant=$1
app_name=$2
if [ -e "${app_name}" ]; then
  echo "Target directory ${app_name} already exists; please remove first."
  echo "$0 tenant app_name"
  exit
fi

cd
rails new ${app_name} -m https://raw.github.com/projectblacklight/blacklight/master/template.demo.rb

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${app_name}

cp ${source_dir}/Gemfile .
cp ${source_dir}/blacklight.yml config/
cp ${source_dir}/blacklight.en.yml config/locales/
cp ${source_dir}/development.rb config/environments/
cp ${source_dir}/catalog_controller.rb app/controllers/
mkdir -p app/helpers/blacklight
cp ${source_dir}/catalog_helper_behavior.rb app/helpers/blacklight/

bundle update
# stop the troublesome spring server, for now
bin/spring stop

rails g blacklight_advanced_search:install
rails g blacklight_gallery:install

# additional customization of templates and css
cp ${source_dir}/*.svg public/
cp ${source_dir}/*.png public/
mkdir -p app/views/shared
cp ${source_dir}/_header_navbar.html.erb app/views/shared/
cp ${source_dir}/_footer.html.erb app/views/shared/
mkdir -p app/views/catalog/
cp ${source_dir}/_home_text.html.erb app/views/catalog/
cp ${source_dir}/_search_form.html.erb app/views/catalog/

cp ${source_dir}/_variables.scss app/assets/stylesheets/
cp ${source_dir}/blacklight.scss app/assets/stylesheets/

# a useful script for saving back modifications to source repo
cp ${source_dir}/save.sh .

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

