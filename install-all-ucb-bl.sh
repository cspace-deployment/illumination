#
# assumes that the illumination repo and the django_example_config have been clone into the
# home directory from GitHub, and that installations will happen in the home directory.
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh pahma search_pahma ~/django_example_config/pahma/config/pahmapublicparms.csv
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh bampfa search_bampfa ~/django_example_config/bampfa/config/public_collection_info.csv
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh botgarden search_botgarden ~/django_example_config/botgarden/config/plantinfo.csv
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh ucjeps search_ucjeps ~/django_example_config/ucjeps/config/ucjepspublicparms.csv