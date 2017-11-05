target_dir=$1
if [ ! -e "${target_dir}" ]; then
  echo "${target_dir} does not exist."
  exit
fi
cp Gemfile ${target_dir}
cp config/blacklight.yml ${target_dir}
cp config/locales/blacklight.en.yml ${target_dir}
cp config/environments/development.rb ${target_dir}
cp app/controllers/catalog_controller.rb ${target_dir}
cp app/helpers/blacklight/catalog_helper_behavior.rb ${target_dir}
cp app/assets/stylesheets/application.css.scss ${target_dir}
cp app/assets/stylesheets/_bootswatch.scss ${target_dir}
cp app/assets/stylesheets/_variables.scss ${target_dir}
cp app/views/shared/_header_navbar.html.erb ${target_dir}
cp app/views/catalog/_home_text.html.erb ${target_dir}
cp app/views/shared/_footer.html.erb ${target_dir}
cp public/17-379a-c.png ${target_dir}
cp app/assets/stylesheets/_variables.scss ${target_dir}
cp app/assets/stylesheets/blacklight.scss ${target_dir}
