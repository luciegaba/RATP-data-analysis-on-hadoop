

CREATE TABLE IF NOT EXISTS $base_name.arrets(
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
FIELDS TERMINATED BY "\u003B"
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
tblproperties("skip.header.line.count"="1");
LOAD DATA INPATH 'hdfs:$folder_name/arrets-lignes.csv' INTO TABLE $base_name.arrets;
SELECT * FROM $base_name.arrets LIMIT 10;

