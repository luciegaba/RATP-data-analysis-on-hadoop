


#--------------------------------------------------------------TRAFIC_2020--------------------------------------------------------------
wget "https://data.ratp.fr/api/explore/v2.1/catalog/datasets/trafic-annuel-entrant-par-station-du-reseau-ferre-2020/exports/csv?lang=fr&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B" -O /tmp/trafic-annuel-entrant-par-station-du-reseau-ferre-2020.csv
hadoop fs -put /tmp/trafic-annuel-entrant-par-station-du-reseau-ferre-2020.csv /tmp/projet_ratp


beeline -n "$ssh_username" -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -e """ 

CREATE TABLE IF NOT EXISTS mosef_projet_ratp.trafic_2020 (
Rang INT,
Reseau STRING,
Station STRING,
Trafic INT,
Correspondance_1 INT,
Correspondance_2 INT,
Correspondance_3 INT,
Correspondance_4 INT,
Correspondance_5 INT,
Ville STRING,
Arrondissement INT
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\u003B'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties('skip.header.line.count'='1');
LOAD DATA INPATH 'hdfs:/tmp/projet_ratp/trafic-annuel-entrant-par-station-du-reseau-ferre-2020.csv'
INTO TABLE mosef_projet_ratp.trafic_2020;
SELECT * FROM mosef_projet_ratp.trafic_2020 LIMIT 10; """
