# Projet RATP 🚇


### Avant-Propos
Ce projet a été réalisé dans le cadre du cours de "Systèmes répartis" dispensé par Antoine Monino. Le but était d'effectuer un projet de Data Science, de l'extraction des données à la modélisation. Ce projet s'est avéré particulièrement formateur car nous avons pu appréhender toute une partie "traitement de données massives" sur un environnement Big Data de type cluster Hadoop.


### Problématique

Le trafic ferroviaire de l'Ile de France est sujet à de nombreuses critiques de la part des usagers. Les incidents déclarés chaque jour, les saturations de certaines lignes aux heures de pointe, ainsi que les différentes inégalités d'accès à la capitale sont autant de problèmes qui nécessitent des améliorations.

Dans ce contexte, nous avons choisi de nous pencher sur la RATP, car nous sommes quotidiennement confrontés à ces problématiques. Notre projet a pour but d'étudier l'évolution du trafic annuel des différentes stations de RER et de métro parisiens.

Nous avons initialement envisagé d'étudier les incidents sur les différentes lignes, car les données sur ces incidents sont riches en informations. Nous aurions pu comprendre les causes profondes des incidents en faisant du text mining, catégoriser les incidents et prévoir les temps de résolution. Cependant, nous avons dû écarter cette piste car l'extraction des données s'avérait complexe en utilisant un notebook.

Notre problématique reste tout de même intéressante car nous tentons d'identifier les facteurs qui expliquent l'évolution du trafic annuel, tels que la qualité du service, la géographie, l'information des voyageurs ou le fait d'être desservi par une ligne en particulier. Nous espérons que ce projet sera utile pour les usagers de la RATP et pour tous ceux qui s'intéressent à la mobilité en Ile de France.


### Les données
Afin de réaliser ce projet nous avons extrait nos données de  [PRIM](https://prim.iledefrance-mobilites.fr/fr) et  [RATP](https://data.ratp.fr/explore/).
Comme énoncé dans la guideline, à différentes étapes du projet, il y a différents jeux de données:

##### Description de la base de données SQL 
La base SQL de notre projet 'mosef_projet_ratp'  comporte initialement 7 tables. Pour chaque table, vous avez la possibilité de voir la description du jeu de données en cliquant sur le nom de la table:

- [arrets](https://prim.iledefrance-mobilites.fr/fr/donnees-statiques/arrets-lignes)
- [emplacement_gare](https://prim.iledefrance-mobilites.fr/fr/donnees-statiques/emplacement-des-gares-idf-data-generalisee)
- [indicateur_qualite](https://eu.ftp.opendatasoft.com/stif/QualiteService/presentation_des_indicateurs_qs_opendata.pdf)
- [lignes_actives_2021](https://eu.ftp.opendatasoft.com/stif/Documentation/Référentiels.pdf)
- [projets](https://prim.iledefrance-mobilites.fr/fr/donnees-statiques/projets_lignes_idf)
- [trafic_2020](https://data.ratp.fr/explore/dataset/trafic-annuel-entrant-par-station-du-reseau-ferre-2020/information/)
- [trafic_2021](https://data.ratp.fr/explore/dataset/trafic-annuel-entrant-par-station-du-reseau-ferre-2021/information/)


##### Description du jeu de données pour l'analyse et modélisation

Comme expliqué ensuite, nous avons réalisé différentes jointures entre les différentes tables de la base SQL (les étapes sont expliqués dans cette section). Ainsi, finalement, on obtient une table qui sera notre jeu de données pour la modélisation. Les observations de ce jeu de données correspondent aux différentes stations de métros, RER, tramway, transiliens (relatif à la RATP ainsi qu'à la SNCF pour le RER hors Paris et les transiliens). Pour chaque station, on dispose de différentes variables:
- stop_name : nom de la station (STRING) 
- stop_lon : longitude de la station (FLOAT)
- stop_lat : latitude de la station (FLOAT)
- OperatorName: Nom de l'opérateur c'est-à-dire SNCF ou RATP (STRING) 
- ligne_name: Nom de la ligne principale comme Métro 1 ou RER A (STRING) 
- Contact_voyageurs: Score de qualité portant sur la capacité à pouvoir contacter en cas de problème (pour les voyageurs) 
- Information_voyageurs: Score de qualité portant sur la capacité à pouvoir informer les voyageurs
- Propreté:  Score de qualité portant sur la propreté de la station
- Sûreté:  Score de qualité portant sur la sûreté de la station
- ville: Ville dans laquelle se situe la station
- trafic_2020: trafic annuel en 2020 pour la station
- trafic_2021: trafic annuel en 2021 pour la station
- sum_correspondance: nombre de correspondance au sein de la station 




### Installation du projet :

- Connexion à votre cluster Hadoop
- Télécharger le repo du projet GitHub:
``` bash
#Typiquement
wget https://github.com/luciegaba/RATP-data-analysis-project/archive/refs/heads/main.zip -O /tmp/RATP/
unzip /tmp/RATP/main.zip -d .

```
- **Installation de la base de données**: connectez-vous à votre cluster Hadoop, puis:
  - Initiez un fichier .env comportant:
  ```
  ssh_username=[votre_username]
  ssh_password=[votre_mot_de_passe]
  project_path=[path_projet_github: exemple = [/tmp/RATP/RATP-data-analysis-project-main/]
  ```
  - Lancez ce [script](https://github.com/luciegaba/RATP-data-analysis-project/blob/main/scripts/01_create_database/sql_loader/creating_hive_db.sh):
  ```
  cd project_path
  bash /scripts/01_create_database/sql_loader/creating_hive_db.sh
  ```
  
- Création de la table utilisée pour l'analyse et la modélisation:
``` shell
spark-submit project_path/01_create_database/create_table_for_analysis/create_table_for_analysis.py
```
- Processing & Modélisation 
``` shell
spark-submit project_path/02_data_analysis/processing.py

```
  
### Guideline du projet

Le projet est constitué de différentes parties: 

- Constitution de la base de données SQL (via SQL & Shell)   *01_create_database*
- Création de la table utilisée pour l'analyse et la modélisation (via PySpark)   *01_create_database*
- Analyse descriptive de la base (via SparkSQL)    *02_data_analysis*
- Processing & Modélisation (via Pyspark et MLLIB )   *02_data_analysis*


#### Constitution de la base de données 


Pour cette partie, notre ambition était de créer une base de données SQL disposant de plusieurs tables et ce, obtenues de différentes façons: téléchargement de données statiques mais également extraction par appel API Real Time pour alimenter une table progressivement. Finalement, uniquement la première méthode a été utilisé par faute de faisabilité. En effet, la seconde alternative nécessitait l'utilisation de Kafka, ainsi que de Python si nous voulions réaliser facilement l'extraction. 

Après avoir téléchargé des données statiques sous forme de csv, on les dépose sur HDFS puis les chargeons dans les différentes tables de notre base SQL (préalablement créées)
Notre souhait était vraiment de miser sur le côté "Data Engineering" en créant une base données cohérente et utile à différentes fins. 

Remarque: cette base dispose de données sur différents types de transports (bus, métro, train), sur des lignes différentes, et des secteurs différents. Nous ciblons notre projet sur Paris et sa proche banlieue mais il y a différents élements qui peuvent être également étudiés.  




#### Création de la table pour l'analyse et la modélisation

Cette étape consistait à créer un jeu de données qui puisse être exploitable pour un quelconque projet Data comme le notre. En effet, les tables disponibles dans notre base SQL sont brutes et ne peuvent constituer une source de données pertinente à elles-seules. En ce sens, dans cette partie, nous avons effectué quelques modifications ainsi que des jointures pour avoir un niveau d'information satisfaisant. Toute cela a été réalisé sur Spark. La table issue de cette étape est une table temporaire (une vue), qui est ensuite récupérée dans l'étape suivante. 

#### Analyse descriptive de la base (via SparkSQL)
Cette étape consiste à simplement constater différentes relations entre les variables dans le but d'effectuer une modélisation ensuite. Cette analyse est centrée sur une variable d'interêt, le trafic annuel, avec laquelle on effectue des graphiques avec les autres variables de notre table.

#### Processing & Modélisation (via Pyspark et MLLIB)

Le processing consiste au traitement de la target (création de bins pour faire de la classification et non de la régression), ainsi que des différentes variables explicatives. 

La modélisation choisie est l'explication de l'évolution du trafic annuel (sous forme de classification) à savoir si l'évolution entre 2020 et 2021 a été forte, faible, ou quasi inexistante OU si l'évolution a été positive, négative. 
Remarque: Ce modèle n'a pas pour but de prédire l'évolution du trafic, mais plutôt de comprendre les causes: il s'agit d'un modèle explicatif et non prédictif. 




