cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh pahma search_pahma_v6 ~/django_example_config/pahma/config/pahmapublicparms.csv
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh bampfa search_bampfa_v1 ~/django_example_config/bampfa/config/public_collection_info.csv 
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh botgarden search_botgarden_v7 ~/django_example_config/botgarden/config/plantinfo.csv
cd ~/illumination
git checkout -- src/*
cd
./illumination/install.sh ucjeps search_ucjeps_v7 ~/django_example_config/ucjeps/config/ucjepspublicparms.csv 
