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

cd ${app_name}

cp ${source_dir}/Gemfile Gemfile 
cp ${source_dir}/blacklight.yml config/blacklight.yml 
cp ${source_dir}/blacklight.en.yml config/locales/blacklight.en.yml
cp ${source_dir}/development.rb config/environments/development.rb
cp ${source_dir}/catalog_controller.rb app/controllers/catalog_controller.rb
mkdir -p app/helpers/blacklight
cp ${source_dir}/catalog_helper_behavior.rb app/helpers/blacklight/catalog_helper_behavior.rb 

cp ${source_dir}/*.svg public/
cp ${source_dir}/*.png public/
mkdir -p app/views/shared
cp ${source_dir}/_header_navbar.html.erb app/views/shared/_header_navbar.html.erb
cp ${source_dir}/_footer.html.erb app/views/shared/
mkdir -p app/views/catalog/
cp ${source_dir}/_home_text.html.erb app/views/catalog/_home_text.html.erb

cp ${source_dir}/_variables.scss app/assets/stylesheets/
cp ${source_dir}/blacklight.scss app/assets/stylesheets/

cp ${source_dir}/save.sh .

bundle update

rails g blacklight_advanced_search:install
rails g blacklight_gallery:install

echo
echo "********************************************************************"
echo "new blacklight app customized for ${tenant} created in ~/${app_name}."
echo "to start it up in development:"
echo ""
echo "    cd ~/${app_name}
echo "    rails s"
echo ""
echo "then visit https://localhost:3000" to test"
echo "********************************************************************"

