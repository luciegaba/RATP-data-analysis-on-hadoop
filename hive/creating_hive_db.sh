beeline -n $ssh_username -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -e" create database if not exists $base_name;"
create database if not exists $base_name;
SQL_DIR="/structure_tables"
for sql_file in $SQL_DIR/*.sql
do
    beeline -n ssh_username sef -p '$ssh_password' -u "jdbc:hive2://avisia-cluster-01:10000/default" -hivevar folder_name="$folder_name" base_name="$base_name" -f "$sql_file"  
done
