from pyspark.sql.functions import *
from pyspark.sql.types import StringType
from pyspark.sql import HiveContext
from pyspark import SparkContext
from utils import clean_text

def load_data(hive_context):
    arrets_data = hive_context.sql("SELECT route_id, route_long_name, stop_id, stop_name, stop_lon, stop_lat, Nom_commune, OperatorName FROM mosef_projet_ratp.arrets WHERE OperatorName IN ('RATP', 'SNCF')")
    lignes_data = (
        hive_context.sql("select first(idrefligc) as ligne_id, first(ligne_) as ligne_name from mosef_projet_ratp.emplacement_gare "
                  "WHERE (idrefligc not in ('idrefligc','NR')) and exploitant in ('RATP','SNCF') GROUP BY idrefligc")
    )
    indicateur_qualite = hive_context.sql("SELECT *  FROM mosef_projet_ratp.indicateur_qualite")
    trafic_2020 = hive_context.sql("select * from mosef_projet_ratp.trafic_2020")
    trafic_2021 = hive_context.sql("select * from mosef_projet_ratp.trafic_2021")
    return arrets_data, lignes_data, indicateur_qualite,trafic_2020, trafic_2021

def prepare_arrets(arrets_data):
    clean_text_udf = udf(clean_text, StringType())
    arrets_data = arrets_data.withColumn("route_id", substring(col("route_id"), 6, 6)) 
    arrets_data = arrets_data.withColumn("stop_name", clean_text_udf("stop_name"))
  
    return arrets_data
    
def prepare_indicateur_qualite(indicateur_qualite):
    indicateur_qualite = indicateur_qualite.withColumn("ID_Line", explode(split("ID_Line", ";")))
    indicateur_qualite_data = indicateur_qualite.groupBy("Theme", "ID_Line").agg(round(avg("resultatenpourcentage")).alias("MeanResultat")).orderBy("ID_Line", ascending=False)
    indicateur_qualite_data = indicateur_qualite_data.groupBy("ID_Line").pivot("Theme").agg(avg("MeanResultat"))
    indicateur_qualite_data = indicateur_qualite_data.drop("Accessibilité","Theme","Ventes et Validations")
    indicateur_qualite_data = indicateur_qualite_data.filter(col("ID_Line").rlike("[A-Za-z][0-9]+"))
    return indicateur_qualite_data


def prepare_trafic_table(trafic_data):
    clean_text_udf = udf(clean_text, StringType())
    trafic_data = trafic_data.withColumn("ligne_name_2", concat_ws(" ", "reseau", "Correspondance_1"))
    trafic_data = trafic_data.withColumn("ligne_name_2", clean_text_udf()(col("ligne_name_2")))
    trafic_data_sum_correspondance=trafic_data.select("station","correspondance_1","correspondance_2","correspondance_3","correspondance_4","correspondance_5")
    trafic_data_sum_correspondance = trafic_data_sum_correspondance.select("station",*[when(col(c).isNull(), 0).otherwise(1).alias(c) for c in trafic_data.drop("station").columns])
    trafic_data_sum_correspondance = trafic_data_sum_correspondance.withColumn('sum_correspondance', f.expr('+'.join(["correspondance_1","correspondance_2","correspondance_3","correspondance_4","correspondance_5"])))
    trafic_final = trafic_data.join(trafic_data_sum_correspondance, 
                               "station", 
                               'left')
    return trafic_final

def prepare_trafic_data(trafic_2020,trafic_2021):
    trafic_2020 = prepare_trafic_table(trafic_2020)
    trafic_2021 = prepare_trafic_table(trafic_2021)
    trafic_2020 = trafic_2020.select("station","trafic","rang","trafic_2020.correspondance_1","trafic_2020.correspondance_2","ville","ligne_name_2","sum_correspondance").withColumnRenamed("trafic","trafic_2020").withColumnRenamed("rang","rang_2020")        
    trafic_2021 = trafic_2021.select("station","trafic","rang").withColumnRenamed("trafic","trafic_2021").withColumnRenamed("rang","rang_2021")                            
    trafic_all_data =  trafic_2020.join(trafic_2021,"station","inner")
    trafic_all_data = trafic_all_data.drop("trafic_2020.ville","trafic_2020.correspondance_1","")
    return trafic_all_data
    
    
def main():
    sc = SparkContext.getOrCreate()
    hiveContext = HiveContext(sc)
    #Load data
    arrets_data, lignes_data, indicateur_qualite,trafic_2020, trafic_2021 = load_data(hiveContext)
    
    #Preprocess tables 
    arrets_data = prepare_arrets(arrets_data)
    indicateur_qualite = prepare_indicateur_qualite(indicateur_qualite)
    trafic = prepare_trafic_data(trafic_2020,trafic_2020)
    #Jointures
    main_data = arrets_data.join(lignes_data, col('route_id') == col('ligne_id'), 'right').drop('ligne_id')
    main_data = main_data.join(indicateur_qualite, 
                               col('route_id') == col('ID_Line'), 
                               'inner').drop('ligne_id') 
    
    main_data = main_data.join(trafic, 
                               col('stop_name') == col('station'), 
                               'right') 
    #Global process before OK
    main_data = main_data.dropDuplicates(["stop_name"])
    main_data = main_data.drop(*["stop_id","ID_Line","station","Nom_commune","rang_2021","rang_2020","route_long_name","route_id","Ventes & Validations","Elévatique","correspondance_2","correspondance_1","ligne_name_2"])
    main_data = main_data.withColumnRenamed("Contact voyageurs", "contact_voyageur")\
       .withColumnRenamed("Information voyageurs", "information_voyageur")\
       .withColumnRenamed("Propreté","proprete")\
       .withColumnRenamed("Sûreté","surete")
    
    return main_data
    
if __name__ == '__main__':
    main()
    
