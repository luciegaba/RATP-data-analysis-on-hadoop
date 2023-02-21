

#--------------------------------------------------------------LIGNES_ACTIVES_2021--------------------------------------------------------------
wget "https://data.iledefrance-mobilites.fr/explore/dataset/referentiel-des-lignes/download/?format=csv&timezone=Europe/Berlin&lang=fr&use_labels_for_header=true&csv_separator=%3B" -O /tmp/referentiel-des-lignes.csv
hadoop fs -put /tmp/referentiel-des-lignes.csv /tmp/projet_ratp


beeline -n "$ssh_username" -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -e """

CREATE TABLE IF NOT EXISTS mosef_projet_ratp.lignes_actives_2021 (
ID_Line INT,
Name_Line STRING,
ShortName_Line STRING,
TransportMode STRING,
TransportSubmode STRING,
Type STRING,
OperatorRef INT,
OperatorName STRING,
AdditionalOperatorsRef INT,
NetworkName STRING,
ColourWeb_hexa STRING,
TextColourWeb_hexa STRING,
ColourPrint_CMJN STRING,
TextColourPrint_hexa STRING,
Accessibility STRING,
Audiblesigns_Available STRING,
Visualsigns_Available STRING,
ID_GroupOfLines INT,
ShortName_GroupOfLines STRING,
Notice_Title STRING,
Notice_Text STRING,
Picto STRING,
ExternalCode_Line INT,
Valid_fromDate DATE,
Valid_toDate DATE,
Status STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\u003B'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties('skip.header.line.count'='1');
LOAD DATA INPATH 'hdfs:/tmp/projet_ratp/referentiel-des-lignes.csv'
INTO TABLE mosef_projet_ratp.lignes_actives_2021; 

SELECT * FROM mosef_projet_ratp.lignes_actives_2021 LIMIT 10; """