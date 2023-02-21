
#--------------------------------------------------------------PROJETS_LIGNES--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/projets_lignes_idf/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/projets_lignes_idf.csv
hadoop fs -put /tmp/projets_lignes_idf.csv /tmp/projet_ratp


beeline -n "$ssh_username" -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -e """ 

CREATE TABLE IF NOT EXISTS mosef_projet_ratp.projets(
ID_LIGNE INT,
ID_PROJET INT,
NOM_PROJET STRING,
ID_OPERATI INT,
OPERATION STRING,
MODE_ INT,
SOUS_MODE INT,
INDICE STRING,
PHASE INT,
VARIANTE STRING,
CREATION INT,
PROLONG INT,
AMELIOR INT,
CPER_2007 INT,
CPER_2015 INT,
CPRD INT,
SDRIF INT,
PLAN_MOB INT,
NGP INT,
STATUT INT,
DUP INT,
DUP_date STRING,
OPENDATA INT,
OD_STEP INT,
OD_STEP_d INT,
MES_OFF_TX STRING,
DATE_EDITI STRING,
RVB_ STRING,
CMJN_ STRING,
geo_point_2d STRING,
geo_shape STRING
) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\u003B'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties('skip.header.line.count'='1');


LOAD DATA INPATH 'hdfs:/tmp/projet_ratp/projets_lignes_idf.csv'
INTO TABLE mosef_projet_ratp.projets;
SELECT * FROM mosef_projet_ratp.projets LIMIT 10;"""
