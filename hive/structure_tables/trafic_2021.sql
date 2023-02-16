CREATE TABLE IF NOT EXISTS $basename.trafic_2021 (
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
) ROW FORMAT DELIMITED FIELDS TERMINATED BY "\u003B"
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
LOAD DATA INPATH 'hdfs:$folder_name/trafic-annuel-entrant-par-station-du-reseau-ferre-2021.csv'
INTO TABLE $basename.trafic_2021;
SELECT * FROM $basename.trafic_2021 LIMIT 10;
