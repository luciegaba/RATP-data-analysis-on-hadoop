
# Creating folder for data project
if hadoop fs -test -d "$folder_name"; then
  echo "The folder $folder_name exists in Hadoop"
else
  echo "The folder $folder_name does not exist in Hadoop - creating it now"
  hadoop fs -mkdir "$folder_name"
  echo "The folder $folder_name has been created in Hadoop"
fi
hadoop fs -chmod 755 $folder_name
hadoop fs -chown -R zeppelin $folder_name

# Downloading data from OpenData

#--------------------------------------------------------------ARRETS_LIGNES--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/arrets-lignes/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/arrets-lignes.csv
hadoop fs -put /tmp/arrets-lignes.csv $folder_name
rm /tmp/arrets-lignes.csv

#--------------------------------------------------------------EMPLACEMENTS_GARES--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/emplacement-des-gares-idf/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/emplacement-des-gares-idf.csv
hadoop fs -put /tmp/emplacement-des-gares-idf.csv $folder_name
rm /tmp/emplacement-des-gares-idf.csv

#--------------------------------------------------------------INDICATEUR_QUALITE--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/indicateurs-qualite-service-sncf-ratp/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/indicateurs-qualite-service-sncf-ratp.csv 
hadoop fs -put /tmp/indicateurs-qualite-service-sncf-ratp.csv $folder_name
rm /tmp/indicateurs-qualite-service-sncf-ratp.csv

#--------------------------------------------------------------TRAFIC_2021--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/titres-et-tarifs/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/trafic-annuel-entrant-par-station-du-reseau-ferre-2021.csv
hadoop fs -put /tmp/trafic-annuel-entrant-par-station-du-reseau-ferre-2021.csv $folder_name
rm /tmp/trafic-annuel-entrant-par-station-du-reseau-ferre-2021.csv
#--------------------------------------------------------------LIGNES_ACTIVES_2021--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/referentiel-des-lignes/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/referentiel-des-lignes.csv
hadoop fs -put /tmp/referentiel-des-lignes.csv $folder_name 
rm /tmp/referentiel-des-lignes.csv

#--------------------------------------------------------------PROJETS_LIGNES--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/projets_lignes_idf/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/projets_lignes_idf.csv
hadoop fs -put /tmp/projets_lignes_idf.csv $folder_name 
rm /tmp/projets_lignes_idf.csv