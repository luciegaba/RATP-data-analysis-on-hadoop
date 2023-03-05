
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
from pyspark.ml.evaluation import BinaryClassificationEvaluator
import pandas as pd
import numpy as np


def prepare_data_for_ml(X,y):
    data= X.join(y, on=["stop_name"], how="left")
    (train_data, test_data) = data.randomSplit([0.7, 0.3], seed=100)
    return train_data, test_data



def model_using_cv(train_data): 
    lr = LogisticRegression(labelCol="target",featuresCol = "features")
    evaluator = BinaryClassificationEvaluator(labelCol="target")
    evaluator.setMetricName("areaUnderROC")
    params = ParamGridBuilder()
    params = params.addGrid(lr.regParam, [.01, .1, 1.0, 10.0]).addGrid(lr.elasticNetParam, [0.0, 0.5])
    params = params.build()
    cv = CrossValidator(estimator=lr,
                    estimatorParamMaps=params,
                    evaluator=evaluator,
                    numFolds=5, parallelism=2)


    cv = cv.fit(train_data)
    return cv

def lr_model(train_data):
    lr = LogisticRegression(labelCol="target",featuresCol = "features")
    model_lr = lr.fit(train_data)
    return model_lr

def results_model(model):
    # Affichage des coefficients du modèle
    OddRatios=np.exp( model.coefficientMatrix.toArray())
    OddRatios = pd.DataFrame(data=coeffMatrix, columns=['contact_voyageur', 'information_voyageur', 'proprete', 'surete', 'sum_correspondance','METRO 14', 'METRO 9', 'RER B', 'METRO 13', 'METRO 2'])
    print("Odd Ratios de la régression logistique polytomique :")
    print(OddRatios)
# Ajouter une ligne pour les constantes du modèle

# Utiliser la fonction print() pour afficher le DataFrame

def ml_pipeline():
    train_data,test_data = prepare_data_for_ml(X,y)
    model = lr_model(train_data)
    results_model(model)

if __name__ == '__main__':
    ml_pipeline()
    

