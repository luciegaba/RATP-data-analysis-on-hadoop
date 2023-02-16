CREATE TABLE IF NOT EXISTS mosef_projet_ratp.indicateur_qualite (
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
) ROW FORMAT DELIMITED FIELDS TERMINATED BY "\u003B"
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");

LOAD DATA INPATH 'hdfs:$folder_name/indicateurs-qualite-service-sncf-ratp.csv'
INTO TABLE mosef_projet_ratp.indicateur_qualite;
SELECT * FROM mosef_projet_ratp.indicateur_qualite LIMIT 10;