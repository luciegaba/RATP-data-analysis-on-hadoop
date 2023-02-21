
#--------------------------------------------------------------INDICATEUR_QUALITE--------------------------------------------------------------
# On spécifie un séparateur | pour que les ; soient bien considérés
wget "https://data.iledefrance-mobilites.fr/explore/dataset/indicateurs-qualite-service-sncf-ratp/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=," -O /tmp/indicateurs-qualite-service-sncf-ratp.csv 
hadoop fs -put /tmp/indicateurs-qualite-service-sncf-ratp.csv /tmp/projet_ratp


ssh_username=mosef
ssh_password=@Mosef2023!
beeline -n "$ssh_username" -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -e """

CREATE TABLE IF NOT EXISTS mosef_projet_ratp.indicateur_qualite(
OperatorName STRING,
Theme STRING,
Indicateur STRING,
TransportMode STRING,
TransportSubmode STRING,
ID_Line STRING,
Name_Line STRING,
Trimestre STRING,
Annee INT,
ResultatEnPourcentage FLOAT,
ResultatEnOccurrence FLOAT,
ObjectifReferenceContrat FLOAT,
Penalite STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
tblproperties('skip.header.line.count'='1');
LOAD DATA INPATH 'hdfs:/tmp/projet_ratp/indicateurs-qualite-service-sncf-ratp.csv' INTO TABLE mosef_projet_ratp.indicateur_qualite;
SELECT * FROM mosef_projet_ratp.indicateur_qualite LIMIT 10;
"""
