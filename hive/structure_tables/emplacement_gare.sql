CREATE TABLE IF NOT EXISTS mosef_projet_ratp.emplacement_gare (
  Geo_Point  STRING ,
  Geo_Shape  STRING ,
  gares_id  INT ,
  nom_long  STRING ,
  nom STRING ,
  nom_sous  STRING ,
  nom_sur  STRING ,
  id_ref_lda  INT ,
  nom_lda  STRING ,
  id_ref_zdl  INT ,
  nom_zdl  STRING ,
  num_mod  INT ,
  mode  STRING ,
  fer  TINYINT ,
  train  TINYINT ,
  rer  TINYINT ,
  metro  TINYINT ,
  tramway  TINYINT ,
  navette  TINYINT ,
  val  TINYINT ,
  terfer  STRING ,
  tertrain  STRING ,
  terrer  STRING ,
  termetro  STRING ,
  tertram  STRING ,
  ternavette  STRING ,
  terval  STRING ,
  idrefliga  STRING ,
  idrefligc  STRING ,
  ligne_  STRING ,
  indice_lig  STRING ,
  res_com  STRING ,
  exploitant  STRING ,
  idf  TINYINT ,
  principal  TINYINT ,
  x  DECIMAL(10,4) ,
  y  DECIMAL(10,4) ,
  picto_ligne  STRING ,
  nom_iv  STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY "\u003B"
LINES TERMINATED BY '\n'
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");


LOAD DATA INPATH 'hdfs:${hivevar:folder_name}/emplacement-des-gares-idf.csv'
INTO TABLE mosef_projet_ratp.emplacement_gare;
SELECT * FROM mosef_projet_ratp.emplacement_gare LIMIT 10;