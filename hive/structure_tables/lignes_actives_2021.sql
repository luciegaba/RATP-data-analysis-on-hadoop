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
FIELDS TERMINATED BY "\u003B"
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
LOAD DATA INPATH 'hdfs:$folder_name/referentiel-des-lignes.csv'
INTO TABLE mosef_projet_ratp.lignes_actives_2021; 

SELECT * FROM mosef_projet_ratp.lignes_actives_2021 LIMIT 10;