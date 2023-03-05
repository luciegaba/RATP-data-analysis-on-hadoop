
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
from pyspark.ml.evaluation import BinaryClassificationEvaluator


def prepare_data_for_ml(data):
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
    print("Coefficients: " + str(model.coefficients))
    summary = model.summary
    print("Ajustement du modèle:")
    print("ROC: %f" % summary.areaUnderROC)


def main():
    train_data,test_data = prepare_data_for_ml(data)
    model = lr_model(train_data)
    results_model(model)

if __name__ == '__main__':
    main()
    

