

#Extracting data from RATP and Mobilités France
#--------------------------------------------------------------ARRETS_LIGNES--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/arrets-lignes/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/arrets-lignes.csv
hadoop fs -put /tmp/arrets-lignes.csv /tmp/projet_ratp


ssh_username=mosef
ssh_password=@Mosef2023!
beeline -n "$ssh_username" -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -e """

CREATE TABLE IF NOT EXISTS mosef_projet_ratp.arrets(
route_id STRING,
route_long_name STRING,
stop_id STRING,
stop_name STRING,
stop_lon DOUBLE,
stop_lat DOUBLE,
OperatorName STRING,
Pointgeo STRING,
Nom_commune STRING,
Code_insee INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\u003B'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
tblproperties('skip.header.line.count'='1');
LOAD DATA INPATH 'hdfs:/tmp/projet_ratp/arrets-lignes.csv' INTO TABLE mosef_projet_ratp.arrets;
SELECT * FROM mosef_projet_ratp.arrets LIMIT 10;
"""

