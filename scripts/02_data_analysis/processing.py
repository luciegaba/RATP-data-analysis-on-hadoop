# On importe les librairies nécessaires
from pyspark.sql.functions import *
from pyspark.sql import HiveContext
from pyspark import SparkContext
from pyspark.ml.feature import *
from ml import ml_pipeline
def preprocess_pipeline():
    # Hive context + requête SQL pour récupérer la table créée dans l'étape 1
    sc = SparkContext.getOrCreate()
    hiveContext = HiveContext(sc)
    data = hiveContext.sql("select * from main_data_for_analysis")

    #Traitement target, variables explicatives, variables quantitatives
    y = target_process(data)
    X = data.drop("trafic_2020","trafic_2021")
    X=X.na.drop(subset=["stop_name"])
    quant_features = [c.name for c in X.schema.fields if str(c.dataType) != "StringType"]

    X_qual = qual_process(X,y)
    X_quant = quant_process(X,quant_features)

    # On assemble les features en une seule colonne 
    assembler = VectorAssembler(inputCols=["qual_features", "quant_features"], outputCol="features")
    X = assembler.transform(X_qual.join(X_quant, on=["stop_name"], how="inner"))
    X=X.select("features","stop_name")
    return X,y




#Traitement de la target
def target_process(data):
        
    #Calcul du taux d'évolution entre 2020 et 2021
    target_vars = ["trafic_2021","trafic_2020"]
    label = data.select("stop_name",*target_vars)

    # On fait la différence entre les deux colonnes puis on calcule le taux
    label = label.withColumn('evolution_rate', expr('-'.join(target_vars)))
    label = label.withColumn('evolution_rate', round(col("evolution_rate")/col("trafic_2020")*100))

    # On ajoute la target au dataframe
    label = label.drop(*target_vars)
    data = data.join(label,"stop_name","left")

    # On convertit la target en binaire en utilisant un Bucketizer
    bucketizer = Bucketizer(
        splits=[-float("inf"), -3, 435, 3614, float("inf")], 
        inputCol="evolution_rate", 
        outputCol="target")
    
    data = bucketizer.transform(data)
    data = data.drop("trafic_2020","trafic_2021","evolution_rate")
    y = data.select("stop_name","target")
    return y


# Qualitative features
def qual_process(X,y):
    
    X = X.join(y, "stop_name","left")
    
    # On encode les variables qualitatives avec StringIndexer et OneHotEncoder (nécessaire pour ChiSqSelector) 
    # Uniquement Ligne_name car elle est significative au test du Chi2 
    stringIndexer = StringIndexer(inputCol="ligne_name", outputCol="ligne_name_encoded")
    model = stringIndexer.fit(X)
    X = model.transform(X)
    onehot_encoder = OneHotEncoder(
    inputCol="ligne_name_encoded",
    outputCol="encoded_ligne_name")   
    X = onehot_encoder.transform(X)
    
    # Selection des modalités les plus importantes au sens du Chi2 pour la variable Ligne_Name
    selector = ChiSqSelector(numTopFeatures=5, featuresCol="encoded_ligne_name", outputCol="selected_features", labelCol="target")
    selector_model = selector.fit(X)
    selected_features = selector_model.transform(X)
    X_qual= selected_features.select("selected_features","stop_name").withColumnRenamed("selected_features", "qual_features")
    return X_qual


def quant_process(X,quant_features):
    # Selection des variables quantitatives 
    X_quant = X.select("stop_name",*quant_features)
    #Fill na les variables de score qualité en fonction des moyennes trouvées dans l'analyse
    X=X.na.fill(96,subset=["contact_voyageur","information_voyageur"])
    X=X.na.fill(99,subset=["surete"])
    X=X.na.fill(93,subset=["proprete"]) 
    
    #Assembler sous forme adéquate pour ML
    assembler = VectorAssembler(inputCols=quant_features, outputCol="features")
    X_quant= assembler.transform(X_quant)
    X_quant = X_quant.select("features","stop_name").withColumnRenamed("features","quant_features")

    return X_quant

if __name__ == '__main__':
    X,y=preprocess_pipeline()
    ml_pipeline(X,y)