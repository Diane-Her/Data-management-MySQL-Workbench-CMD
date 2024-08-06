/* En el siguiente Script se aborda la importación, validación, formateo de datos, 
solución de errores y exportación de datos limpios. Explicado en pasos para facilitar su comprensión y futuras consultas. 

Se divide en dos partes: 
La primera parte consiste en la importación de datos usando la interfaz de Workbench, con el asistente "Table Data Import Wizard", útil para bases de datos con un menor número de registros.
La segunda parte consiste en la importación de datos usando el comando "mysqlimport-" desde CMD, útul para bases de datos con un mayor número de registros.
*/


-- PARTE 01.


/* En el siguiente Script se aborda la importación, validación, formateo de datos, 
   solución de errores y exportación de datos limpios.  */

-- PASO 01. Crear la base de datos para cargar el dataset completo de bellabeat

CREATE database caso_bellabeat;
USE caso_bellabeat;

/*PASO 02. Cargar todas las tablas. Se usó la función Data Import Wizard. 
Hacer una revisión general del contenido de las tablas, conteo de total de sujetos de estudio 
para definir cuales tablas contienen un tamaño de muestra viable.

Nota: Los valores duplicados se eliminaron previamente con excel */

/*Se presentó error al cargar la tabla en la columna Id debido al formato INT, se cambió a TEXT, 
 esto no afecta ya que el Id, solo se usa como un indicador y no se utilizará para realizaer cálculos numéricos. 
 
 Observación: Para todas las tablas se muestra el mismo error al cargar la columna Id como INT, por lo que, para todos los casos se cambió a TEXT */

SELECT * FROM dailyactivity_merged;
SELECT COUNT(Id)  AS Conteo_valores FROM dailyactivity_merged;
SELECT COUNT(DISTINCT Id) AS valores_unicos FROM dailyactivity_merged;
 
 /* Son un total de 457 valores
 35 ID únicos, por lo que es un tamaño de muestra válido */
 
 SELECT * FROM weightloginfo_merged;
 SELECT COUNT(DISTINCT Id) AS valores_unicos FROM weightloginfo_merged;
 
/* La tabla weightloginfo_merged cuenta solo con 11 Id únicos, con este número de valores
 no es viable realizar ningún tipo de análisis ni recomendación con base en los mismos, por lo que la tabla será descartada */
 
 
SELECT * FROM hourlycalories_merged;
SELECT COUNT(*) AS total_valores FROM hourlycalories_merged;
SELECT COUNT(DISTINCT Id) AS valores_unicos FROM hourlycalories_merged;

-- 24084 valores, 34 ID únicos - tamaño de muestra válido

SELECT COUNT(*) AS total_valores FROM hourlyintensities_merged;
SELECT * FROM hourlyintensities_merged;
SELECT COUNT(DISTINCT Id) AS valores_unicos FROM hourlyintensities_merged;
SELECT MAX(TotalIntensity) AS valor_maximo FROM hourlyintensities_merged;

-- 24084 valores , 34 Id únicos - tamaño de muestra válido

SELECT * FROM hourlysteps_merged;
SELECT COUNT(*) AS total_valores FROM hourlysteps_merged;
SELECT COUNT(DISTINCT Id) AS valores_únicos FROM hourlysteps_merged;

-- 24084 valores, 34 Id únicos - tamaño de muestra válido

SELECT * FROM minutesleep_merged;
SELECT COUNT(*) AS total_valores FROM minutesleep_merged;
SELECT COUNT(DISTINCT Id) AS valores_unicos FROM minutesleep_merged;

/* 198559 Valores, 23 Id únicos
23 sujetos de muestra no es un tamaño de muestra aceptable */

/* PASO 03. Validación de datos: Limpieza de valores duplicados y dobles espaciados
Es conveniente revisar a pesar de que se hizo una revisión y eliminación previa usando Excel */

SELECT COUNT(*) AS duplicados
FROM dailyactivity_merged
GROUP BY Id, ActivityDate, TotalSteps, TotalDistance, LoggedActivitiesDistance, 
VeryActiveDistance, ModeratelyActiveDistance, LightActiveDistance, SedentaryActiveDistance,
VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories
HAVING COUNT(*) >1;

SELECT COUNT(*) FROM dailyactivity_merged
 WHERE Id LIKE "%  %";

-- Se revisaron todas las columnas de la tabla dailyactivity_merged con la misma consulta

SELECT * FROM hourlycalories_merged;
SELECT COUNT(*) AS duplicados
FROM hourlycalories_merged
GROUP BY Id, ActivityHour, Calories
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM hourlycalories_merged
 WHERE Id LIKE "%  %";
SELECT COUNT(*) FROM hourlycalories_merged
 WHERE ActivityHour LIKE "%  %"; 
SELECT COUNT(*) FROM hourlycalories_merged
 WHERE Calories LIKE "%  %";

SELECT * FROM hourlyintensities_merged;
SELECT COUNT(*) AS duplicados
FROM hourlyintensities_merged
GROUP BY Id, ActivityHour, TotalIntensity, AverageIntensity
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM hourlyintensities_merged
 WHERE Id LIKE "%  %";
SELECT COUNT(*) FROM hourlyintensities_merged
 WHERE ActivityHour LIKE "%  %"; 
SELECT COUNT(*) FROM hourlyintensities_merged
 WHERE TotalIntensity LIKE "%  %";
SELECT COUNT(*) FROM hourlyintensities_merged
 WHERE AverageIntensity LIKE "%  %";
 
SELECT * FROM hourlysteps_merged;
SELECT COUNT(*) AS duplicados
FROM hourlysteps_merged
GROUP BY Id, ActivityHour, StepTotal
HAVING COUNT(*) >1;

SELECT COUNT(*) FROM hourlysteps_merged
 WHERE Id LIKE "%  %";
SELECT COUNT(*) FROM hourlysteps_merged
 WHERE ActivityHour LIKE "%  %";
SELECT COUNT(*) FROM hourlysteps_merged
 WHERE StepTotal LIKE "%  %";

SELECT * FROM minutesleep_merged;
SELECT COUNT(*) AS duplicados, Id
FROM minutesleep_merged
GROUP BY Id, `date`, `value`, logId
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM minutesleep_merged
 WHERE Id LIKE "%  %";
SELECT COUNT(*) FROM minutesleep_merged
 WHERE `date` LIKE "%  %"; 
SELECT COUNT(*) FROM minutesleep_merged
 WHERE `value` LIKE "%  %";
SELECT COUNT(*) FROM minutesleep_merged
 WHERE logId LIKE "%  %";  


/* PASO 04. Formateo de Datos. Reasignación de formatos, división y/o adición de columnas pertinentes.
El dato Día y Hora se encuentran en una sola columna, con formato TEXT
Procedí a dividir esta columna para que sea más fácil realizar análisis que requieran de este dato por separado.
Los datos se guardaron en tablas temporales */

DESCRIBE hourlycalories_merged; -- se reconoce como formato INT, por lo que no se le puede aplicar la finción SUBSTRING_INDEX, hay que convertirlo a CHAR utilizando CAST en la consulta

/*Utilicé la función SUBSTRING_INDEX para indicar desde que separador deseo iniciar la separación de cadenas
y la función CAST para que el valor fuera reconocido temporalmente como CHAR */

DROP TABLE IF EXISTS hourlycalories_temp;
CREATE TEMPORARY TABLE hourlycalories_temp AS
SELECT 
 Id,
 SUBSTRING_INDEX(CAST(ActivityHour AS CHAR),' ', 1) AS DateCalories,
 SUBSTRING_INDEX(CAST(Activityhour AS CHAR), ' ', -2) AS HourCalories,
 Calories
FROM hourlycalories_merged;

SELECT * FROM hourlycalories_temp;

/* Desactvé el modo Safe Updates y utilicé las funciones UPDATE para establecer la fecha 
 que se encuentra en formato m-d-y a orden de fecha de SQL, con la función STR_TO_DATE, para que pueda leerse como Y-m-d 
Después utilicé ALTER TABLE y CHANGE para asignar el formato correcto a DATE y TIME respectivamente*/

SET SQL_SAFE_UPDATES = 0; 

UPDATE hourlycalories_temp
 SET DateCalories = STR_TO_DATE(DateCalories, '%m/%d/%Y'),
	 HourCalories = STR_TO_DATE(HourCalories, '%r');

ALTER TABLE hourlycalories_temp
 CHANGE DateCalories DateCalories DATE,
 CHANGE HourCalories HourCalories TIME;

DESCRIBE hourlycalories_temp;

-- El proceso se repitió para las siguientes tablas

SELECT * FROM hourlyintensities_merged;
DESCRIBE hourlyintensities_merged; 

DROP TABLE IF EXISTS hourlyintensities_temp;
CREATE TEMPORARY TABLE hourlyintensities_temp AS
 SELECT 
 Id,
 SUBSTRING_INDEX(CAST(ActivityHour AS CHAR), ' ', 1) AS ActivityDate,
 SUBSTRING_INDEX(CAST(ActivityHour AS CHAR), ' ', -2) AS ActivityHour,
 Totalintensity, AverageIntensity
 FROM hourlyintensities_merged;
 
SELECT * FROM hourlyintensities_temp;
  
UPDATE hourlyintensities_temp
 SET ActivityDate = STR_TO_DATE(ActivityDate, '%m/%d/%Y'),
     ActivityHour = STR_TO_DATE(ActivityHour, '%r');

ALTER TABLE hourlyintensities_temp
 CHANGE COLUMN ActivityDate ActivityDay DATE,
 CHANGE COLUMN ActivityHour ActivityHour TIME;

 DESCRIBE hourlyintensities_temp;
 SELECT * FROM hourlyintensities_temp;
 
 SELECT * FROM Hourlysteps_merged;
 DESCRIBE HourlySteps_merged;
 
DROP TABLE IF EXISTS hourlysteps_temp;
CREATE TEMPORARY TABLE hourlysteps_temp AS 
SELECT 
  Id, 
  SUBSTRING_INDEX(CAST(ActivityHour AS CHAR), ' ', 1) AS ActivityDay,
  SUBSTRING_INDEX(CAST(ActivityHour AS CHAR), ' ', -2) AS ActivityHour,
  StepTotal
 FROM HourlySteps_merged; 
  
 UPDATE hourlysteps_temp
  SET ActivityDay = STR_TO_DATE(ActivityDay, '%m/%d/%Y'),
      ActivityHour = STR_TO_DATE(ActivityHour, '%r');
 
ALTER TABLE hourlysteps_temp
 CHANGE ActivityDay ActivityDay DATE,
 CHANGE ActivityHour ActivityHour TIME;
  
DESCRIBE hourlysteps_temp;
SELECT * FROM hourlysteps_temp;

SELECT * FROM minutesleep_merged;
DESCRIBE minutesleep_merged;

DROP TABLE IF EXISTS minutesleep_temp;
CREATE TEMPORARY TABLE minutesleep_temp AS
 SELECT
  Id,
  SUBSTRING_INDEX(CAST(date AS CHAR), ' ', 1) AS SleepDay,
  SUBSTRING_INDEX(CAST(date AS CHAR), ' ', -2) AS SleepHour,
  value, LogId
  FROM minutesleep_merged;

SELECT * FROM minutesleep_temp;

UPDATE minutesleep_temp
 SET SleepDay = STR_TO_DATE(SleepDay, '%m/%d/%Y');
 
/* UPDATE minutesleep_temp
   SET SleepHour = STR_TO_DATE(SleepHour, '%r'); */

/* Se presentó error al intentar establecer el orden de formato de fecha para la columna SleepDay
"Error Code: 1411. Incorrect time value: '04/01/2016 03:17' for function str_to_date"
Se realizaron algunas consultas para encontrar la raíz del problema */

-- Primero se verificó cuantos errores de conversión había

SELECT SleepDay, SleepHour, COUNT(*) AS errores FROM minutesleep_temp
 WHERE SleepHour = '04/01/2016 03:17'
 GROUP BY SleepDay, SleepHour;

/* Se encontraron 16 valores con error, los registros con este error no indican AM O PM, 
Antes de ser eliminados decidí buscar si había más errores además del que indicaba el mensaje de error. */

/*Sabemos que el formato de fecha original contiene un mayor número de caracteres 
por lo que utilicé LENGTH para saber con cuantos caracteres cuenta el valor con error
Y COUNT para saber cuantos errores de conversión había. */

SELECT sleepDay, SleepHour, LENGTH(SleepHour) AS caracteres
FROM  minutesleep_temp
 WHERE SleepDay = '2016-04-01'
 GROUP BY SleepHour, SleepDay;

-- Las fechas que no pudieron separarse cuenta con 16 caracteres

SELECT COUNT(SleepHour) AS errores
FROM minutesleep_temp
  WHERE LENGTH(SleepHour) = 16;

/* Resultaron 82536 errores por lo que no pueden eliminarse
Opté por revisar el número de caracteres de la tabla original */

SELECT LENGTH(date) AS Caracteres, Id, date
FROM minutesleep_merged;

/* El formato de fecha inicial contiene 20 caracteres.
Realicé una nueva consulta para revisar cuantos formatos de fecha diferentes existen en la columna */

SELECT LENGTH(date) AS Caracteres, Id, date
FROM minutesleep_merged
 WHERE LENGTH(date) != 20
 GROUP BY Id, date;

/*Con la anterior consulta se estableció que existen 3 diferentes formatos de fecha en una sola columna:
 Con 20 caracteres que corresponden al formato '3/13/2016 2:39:30 AM'
 Con 21 caracteres que corresponden al formato '3/28/2016 12:58:00 AM'
 Con 16 caracteres que corresponden al formato '04/01/2016 03:17'
Esto ignifica que no todos los valores serán convertidos con la misma instrucción de fotmato.

Explicación de la ocurrencia del error:
El error ocurre en la separación de columnas, los valores que no contienen AM/PM, arrastran nuevamente a la fecha como el valor 1 en la indicación -2 con la función SUBSTRING_INDEX
Esto puede arreglarse a la hora de separar las columnas utilizando SUBSTRING, LOCATE Y CASE para otorgar condiciones individuales según sea el formato.

Iniciando por eliminar la tabla temporal y crear una nueva, utilizando las indicaciones especificas para separar la hora
Adicional a esto utilicé CONCAT para normalizar los datos y agregar los segundos a los datos que no los incluyen. */

DROP TABLE IF EXISTS minutesleep_temp;
CREATE TEMPORARY TABLE minutesleep_temp AS
 SELECT
  Id,
  SUBSTRING_INDEX(CAST(date AS CHAR), ' ', 1) AS SleepDay,
  CASE
    WHEN LENGTH(CAST(date AS CHAR)) = 20 THEN SUBSTRING(date, LOCATE(' ',date) + 1, 7)
    WHEN LENGTH(CAST(date AS CHAR)) = 21 THEN SUBSTRING(date, LOCATE(' ', date) + 1, 8)
    WHEN LENGTH(CAST(date AS CHAR)) = 16 THEN CONCAT(SUBSTRING(date, LOCATE(' ', date) +1, 5),':00')
    ELSE NULL
    END AS SleepHour,
  value, LogId
  FROM minutesleep_merged;
  
SELECT * FROM minutesleep_temp;

-- Revisar que todos los valores de fecha hayan sido convertidos exitosamente y convertir a formatos de DATE y TIME respectivamente

SELECT Id, Sleephour 
 FROM minutesleep_temp 
  WHERE Sleephour IS NULL;
  
UPDATE minutesleep_temp
  SET SleepDay = STR_TO_DATE(SleepDay, '%m/%d/%Y');
  
ALTER TABLE minutesleep_temp
  CHANGE SleepDay SleepDay DATE;
  
/*  La columna de hora permanecerá sin cambio de formato, al no indicar AM o PM y mantener formato de 12 horas
  -- Será deber de interpretación noche/madrugada al elaborar los gráficos */
  
-- Cambiar Formato de fecha en la tabla de Dailyactivity_merged

UPDATE dailyactivity_merged
 SET ActivityDate = STR_TO_DATE(ActivityDate, '%m/%d/%Y');

ALTER TABLE dailyactivity_merged
 CHANGE ActivityDate ActivityDate DATE;

DESCRIBE dailyactivity_merged;
SELECT * FROM dailyactivity_merged;  


/* PASO 05. Exportar archivos limpios y formateados de ser necesario.
Para esto se utilizó la función INTO OUTFILE, para exportar el archivo en formato .csv y se obtuvo el siguiente error:

" MySQL no permite exportar: Error Code: 1290. The MySQL server is running with the --secure-file-priv option so it cannot execute this statement"

Se ejecutó el siguiente comando para tener acceso a la ruta segura de exportación de archivos*/

SHOW VARIABLES LIKE 'secure_file_priv'; -- Brinda la ruta para exportación: C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\

/* La ocurrencia del error se mantuvo aun con la siguiente consulta,
Debido a esto fue necesario desactivar el secure_file_priv desde los archivos de programa
Se hicieron las correcciones en el documento 'my' del sistema de mysql

Adjunto tutorial: https://www.youtube.com/watch?v=aPj0XyuTiXE
*/

/* Una vez solucionado el error procedí a utilizar 
UNION ALL para agregar los nombres de las columnas y INTO OUTFILE para exportar en formato .csv */

(SELECT 'Id', 'SleepDay', 'SleepHour', 'value', 'LogId')
UNION ALL
(SELECT Id, SleepDay, SleepHour, value, LogId
 FROM minutesleep_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\minutesleep_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'StepTotal')
UNION ALL
(SELECT Id, ActivityDay, Activityhour, StepTotal
 FROM hourlysteps_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\hourlysteps_cleaned.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'TotalIntensity', 'AverageIntensity')
UNION ALL
(SELECT Id, ActivityDAy, ActivityHour, Totalintensity, AverageIntensity
FROM hourlyintensities_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\hourlyintensities_cleaned.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'DateCalories', 'HourCalories', 'Calories')
UNION ALL
(SELECT Id, DateCalories, HourCalories, Calories 
FROM hourlycalories_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\hourlycalories_cleaned.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT * FROM dailyactivity_merged;

(SELECT 'Id', 'ActivityDate', 'TotalSteps', 'TotalDistance', 'TrackerDistance', 'LoggedActivitiesDistance', 'VeryActiveDistance', 'ModeratelyActiveDistance', 
'LightActiveDistance','SedentaryActiveDistance', 'VeryActiveMinutes', 'FairlyActiveMinutes', 'LightlyActiveMinutes', 'SedentaryMinutes', 'Calories')
UNION ALL
(SELECT Id, ActivityDate, TotalSteps, TotalDistance, TrackerDistance, LoggedActivitiesDistance, VeryActiveDistance, ModeratelyActiveDistance, 
 LightActiveDistance, SedentaryActiveDistance, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories
 FROM dailyactivity_merged)
 INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\dailyactivity_cleaned.csv'
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n';
 
/* Las tablas se encuentran formateadas y listas para usarse para el análisis /*


-- PARTE 02.


/* En el siguiente Script se encuentran los pasos para cargar las tablas con un número mayor a un millón de registros con el comando mysqlimport. 
Se aborda la verificación, validación, formateo de datos, solución de errores e importación de datos limpios. */

-- PASO 01. Verificar o garantizar los permisos para utilizar el comando "mysqlimport" desde CMD 

USE caso_bellabeat;

SHOW VARIABLES LIKE 'local_infile';
GRANT FILE ON *.* TO 'root'@'localhost';
SHOW GRANTS FOR 'root'@'localhost';

-- PASO 02. Crear las tablas para importar los datos.

CREATE TABLE heartrate_seconds_merged
(Id TEXT, Time CHAR, Value INT);

/*
Se importaron los datos desde CMD con la línea de ejecución:
mysqlimport --local --ignore-lines=1 --fields-terminated-by=',' --user=root --password=**** caso_bellabeat "C:\ProgramData\MySQL\MySQL Server 8.0\Data\heartrate_seconds_merged.csv"
*/


/* PASO 03. Verificación y validación de datos.
Se revisó la correcta importación de datos, cantidad de sujetos de estudio, verificación de formatos, registros duplicados, valores nulos y/o dobles espaciados. */
 
SELECT *FROM heartrate_seconds_merged;
DESCRIBE heartrate_seconds_merged;

SELECT COUNT(*) AS total_valores FROM heartrate_seconds_merged;
SELECT COUNT(DISTINCT Id) AS valores_unicos FROM heartrate_seconds_merged; 

SELECT COUNT(*) 
AS duplicados FROM heartrate_seconds_merged
GROUP BY Id, Time, Value
HAVING COUNT(*) >1;

SELECT COUNT(*) FROM heartrate_seconds_merged
 WHERE Id LIKE "%  %" OR Id IS NULL;
SELECT COUNT(*) FROM heartrate_seconds_merged
 WHERE `Time` LIKE "%  %" OR `Time` IS NULL;
SELECT COUNT(*) FROM heartrate_seconds_merged
 WHERE `Value` LIKE "%  %" OR `Value` IS NULL;

-- No se encontraron espacios dobles o campos nulos.

/* PASO 04. Transformación y Formateo de datos.
Separar los datos de "Time" en dos columnas de "Fecha" y "Hora" respectivamente. Asignar los formatos correctos de DATE y TIME 
*/

-- PASO 4.1 Crear una tabla temporal para la transformación y formateo de datos

DROP TABLE IF EXISTS heartrate_seconds_temp;
CREATE TEMPORARY TABLE heartrate_seconds_temp AS 
 SELECT
 Id, 
 SUBSTRING_INDEX(CAST(`Time` AS CHAR), ' ', 1) AS ActivityDay,
 SUBSTRING_INDEX(CAST(`Time` AS CHAR), ' ', -2) AS ActivityHour,
 `Value`
FROM heartrate_seconds_merged;

SELECT * FROM heartrate_seconds_temp;
DESCRIBE heartrate_seconds_temp;

-- PASO 4.1 Cambiar a formatos de fecha y hora.

SET SQL_SAFE_UPDATES = 0;

UPDATE heartrate_seconds_temp
 SET ActivityDay = STR_TO_DATE(ActivityDay, '%m/%d/%Y'),
     ActivityHour = STR_TO_DATE(ActivityHour, '%r');

ALTER TABLE heartrate_seconds_temp
 CHANGE ActivityDay ActivityDay DATE,
 CHANGE ActivityHour ActivityHour TIME;

-- PASO 05. Creación de ÍNDICES para optimizar las consultas en tablas con más de un millón de registros.

CREATE INDEX Id_idx ON heartrate_seconds_temp(Id(20));
CREATE INDEX ActivityDay_idx ON heartrate_seconds_temp(ActivityDay);
CREATE INDEX ActivityHour_idx ON heartrate_seconds_temp(ActivityHour);
CREATE INDEX Value_idx ON heartrate_seconds_temp(Value);

/*NOTA: Al cargar el resto de las tablas se presentó un error; todos los datos de las columnas se cargan en la columna 1, se verificó el formato
del documento así como la indicación de separar los valores por coma, pero el error se seguía presentando, por lo que fue necesario separa los 
valores en columnas una vez que fueron cargados. 

Se explica el proceso en pasos para la primera tabla que presenta el error.
 */

-- PASO 01. Creación de tablas para importación de datos.

DROP TABLE IF EXISTS minuteCaloriesNarrow_merged;
CREATE TABLE minuteCaloriesNarrow_merged
(Id text, ActivityMinute text, Calories int); 

 /* Se importaron los datos desde CMD con la línea de ejecución:
mysqlimport --local --ignore-lines=1 --fields-terminated-by=',' --user=root --password=**** caso_bellabeat "C:\ProgramData\MySQL\MySQL Server 8.0\Data\minuteCaloriesNarrow_merged.csv"

NOTA: Inicialmente se obtenía error por el tiempo de espera debido al gran volumen de datos.
Solución de error: Edit > Preferences > SQL editor > DBMS Conection readtimeout interval: 0
Esto omite el tiempo de espera de respuesta para la carga de datos

Adjunto fuente de información: https://www.javierrguez.com/solucion-error-mysql-lost-connection/
*/

/* PASO 02. Verificación y validación de datos.
Establecer los valores de respuesta para lectura de datos.
Separación de datos en columnas, revisión de campos nulos, dobles espaciados o valoes duplicados*/

-- PASO 02.1 Establecer valores de respuesta.

SET SQL_SAFE_UPDATES = 0;
SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;

-- PASO 02.2 Verificación de número de sujetos de estudio, campos nulos y conteo de caracteres.

SELECT * FROM minuteCaloriesNarrow_merged;
DESCRIBE minuteCaloriesNarrow_merged;

SELECT COUNT(*) AS total_valores FROM minuteCaloriesNarrow_merged;
SELECT COUNT(DISTINCT Id) AS valores_unicos FROM minuteCaloriesNarrow_merged; -- 34 sujetos de estudio

SELECT COUNT(*) AS VACIOS FROM minuteCaloriesNarrow_merged
 WHERE ActivityMinute IS NULL;

SELECT LENGTH(Id) FROM minuteCaloriesNarrow_merged AS caracteres_Id;

-- PASO 02.3 Añadir las columnas nuevas donde se almacenarán los datos y extraer los datos de la columna original.

ALTER TABLE minuteCaloriesNarrow_merged 
 ADD COLUMN real_Id TEXT;

UPDATE minuteCaloriesNarrow_merged
 SET real_Id = LEFT(LTRIM(Id),10);

ALTER TABLE minuteCaloriesNarrow_merged 
 ADD COLUMN Activity_minute TEXT,
 ADD COLUMN Calories_calories INT;

UPDATE minuteCaloriesNarrow_merged
 SET Activity_minute = SUBSTRING_INDEX(CAST(Id AS CHAR), ',', -1); 

-- PASO 02.4 Renombrar las columnas y reasignar formatos.

ALTER TABLE minuteCaloriesNarrow_merged
 CHANGE Activity_minute Calories DOUBLE,
 CHANGE Calories_calories ActivityMinute TEXT;

-- Coloqué la parte de la fecha en la columna ActivityMinute, usando dos veces SUBSTRING.

UPDATE minuteCaloriesNarrow_merged
 SET ActivityMinute = SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(Id AS CHAR), ',', 2), ',', -1);

/* PASO 02.5 Verificar que todos los valores fueron cambiados exitosamente, 
   revisar que no haya doble espaciado o valores duplicados y eliminar la columna original.*/

SELECT COUNT(*) 
AS duplicados FROM minuteCaloriesNarrow_merged
GROUP BY Id, Calories, ActivityMinute
HAVING COUNT(*) >1;

SELECT COUNT(*) FROM minuteCaloriesNarrow_merged
 WHERE Calories LIKE "%  %" OR Calories IS NULL;
SELECT COUNT(*) FROM minuteCaloriesNarrow_merged
 WHERE ActivityMinute LIKE "%  %" OR ActivityMinute IS NULL;
SELECT COUNT(*) FROM minuteCaloriesNarrow_merged
 WHERE Id LIKE "%  %" OR Id IS NULL;

ALTER TABLE minuteCaloriesNarrow_merged
 DROP COLUMN ActivityMinute, 
 DROP COLUMN Calories, 
 DROP COLUMN Id;

-- PASO 02.6 Renombrar las columnas con los nombres de la base de datos original.

ALTER TABLE minuteCaloriesNarrow_merged
 RENAME COLUMN real_Id TO Id;
 SELECT * FROM minuteCaloriesNarrow_merged;

/* La tabla quedó lista, cargada con los datos originales.*/
  
/* PASO 03. Transformación y formateo de datos.
   PASO 03.1 Creación de tablas temporales para separar columnas y reasignar formatos.
*/

DROP TABLE IF EXISTS MinuteCaloriesNarrow_temp;
CREATE TEMPORARY TABLE MinuteCaloriesNarrow_temp AS 
 SELECT
 Id, 
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', 1) AS ActivityDay,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', -2) AS ActivityHour,
 Calories
FROM minuteCaloriesNarrow_merged;

SELECT * FROM MinuteCaloriesNarrow_temp;

-- PASO 03.2 Modificar la secuencia de valores en fecha para agregar formato de fecha y de hora respectivamente.

UPDATE MinuteCaloriesNarrow_temp
 SET ActivityDay = STR_TO_DATE(ActivityDay, '%m/%d/%Y'),
     ActivityHour = STR_TO_DATE(ActivityHour, '%r');

ALTER TABLE MinuteCaloriesNarrow_temp
 CHANGE ActivityDay ActivityDay DATE ,
 CHANGE ActivityHour ActivityHour TIME;

-- PASO 04. Crear ÍNDICES de las columnas de la tabla temporal para optimizar el tiempo de respuesta.

CREATE INDEX ActivityDay_idx ON MinuteCaloriesNarrow_temp(ActivityDay);
CREATE INDEX ActivityHour_idx ON MinuteCaloriesNarrow_temp(ActivityHour);
CREATE INDEX Id_idx ON MinuteCaloriesNarrow_temp(Id(20));

SHOW INDEX FROM MinuteCaloriesNarrow_temp;

-- Los pasos se repitieron para la carga del resto de las tablas con más de un millón de datos.

DROP TABLE IF EXISTS minuteIntensitiesNarrow_merged;
CREATE TABLE minuteIntensitiesNarrow_merged
(Id TEXT, ActivityMinute TEXT, Valor INT);

SELECT * FROM minuteIntensitiesNarrow_merged;
SELECT COUNT(*) AS total_valores FROM minuteIntensitiesNarrow_merged;
SELECT COUNT(DISTINCT Id) AS valores_únicos FROM minuteIntensitiesNarrow_merged; -- 34 valores únicos

-- Carga de la tabla MinuteMETsNarrow_merged.

DROP TABLE IF EXISTS MinuteMETsNarrow_merged;
CREATE TABLE MinuteMETsNarrow_merged
(Id TEXT, ActivityMinute TEXT, MET INT);

SELECT * FROM MinuteMETsNarrow_merged;
SELECT COUNT(*) AS total_valores FROM MinuteMETsNarrow_merge;
SELECT COUNT(DISTINCT Id) AS valores_únicos FROM MinuteMETsNarrow_merged; -- 34 valores únicos

-- Carga de la tabla minuteStepsNarrow_merged.

DROP TABLE IF EXISTS minuteStepsNarrow_merged;
CREATE TABLE minuteStepsNarrow_merged
(Id TEXT, ActivityMinute TEXT, Steps INT);

SELECT * FROM minuteStepsNarrow_merged;
SELECT COUNT(*) AS total_valores FROM minuteStepsNarrow_merged;
SELECT COUNT(DISTINCT Id) AS valores_únicos FROM minuteStepsNarrow_merged; -- 34 valores únicos

-- Una vez se importó el total de las tablas, procedo a separar los datos en columnas.

ALTER TABLE MinuteIntensitiesNarrow_merged 
 ADD COLUMN real_id TEXT,
 ADD COLUMN real_activityminute TEXT,
 ADD COLUMN real_valor INT;

UPDATE MinuteIntensitiesNarrow_merged
 SET real_id = LEFT(LTRIM(Id), 10),
     real_valor = SUBSTRING_INDEX(CAST(Id AS CHAR), ',', -1),
     real_ActivityMinute = SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(Id AS CHAR), ',', 2), ',', -1);
 
 -- Revisar que todos los valores fueron transferidos, registros duplicados y dobles espaciados.
 
SELECT COUNT(*) FROM minuteIntensitiesNarrow_merged
 WHERE real_activityminute LIKE "%  %" OR real_activityminute IS NULL;
SELECT COUNT(*) FROM minuteIntensitiesNarrow_merged
 WHERE real_valor LIKE "%  %"OR real_valor IS NULL;
SELECT COUNT(*) FROM minuteIntensitiesNarrow_merged
 WHERE real_Id LIKE "%  %" OR real_Id IS NULL;

-- Eliminar las columnas inservibles y renombrar las que tienen los valores

ALTER TABLE MinuteIntensitiesNarrow_merged
 DROP COLUMN Id,
 DROP COLUMN ActivityMinute,
 DROP COLUMN Valor;

ALTER TABLE MinuteIntensitiesNarrow_merged
 CHANGE real_id Id TEXT, 
 CHANGE real_activityminute ActivityMinute TEXT,
 CHANGE real_valor Intensity INT;

-- Separación de columna en tabla temporal y reasignación de formatos correctos.

DROP TABLE IF EXISTS MinuteIntensitiesNarrow_temp;
CREATE TEMPORARY TABLE MinuteIntensitiesNarrow_temp AS
 SELECT
 Id,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', 1) AS ActivityDay,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', -2) AS ActivityHour,
 Intensity
 FROM MinuteIntensitiesNarrow_merged;

SELECT * FROM MinuteIntensitiesNarrow_temp;

UPDATE MinuteIntensitiesNarrow_temp
 SET ActivityDay = STR_TO_DATE(ActivityDay,'%m/%d/%Y'),
     ActivityHour = STR_TO_DATE(ActivityHour,'%r'); 
 
ALTER TABLE MinuteIntensitiesNarrow_temp
 CHANGE ActivityDay ActivityDay DATE,
 CHANGE ActivityHour ActivityHour TIME;
 
 -- Creación de ÍNDICES en la tabla temporal para optimizar las consultas

CREATE INDEX ActivityDay_idx ON MinuteIntensitiesNarrow_temp(ActivityDay);
CREATE INDEX ActivityHour_idx ON MinuteIntensitiesNarrow_temp(ActivityHour);
CREATE INDEX Id_idx ON MinuteIntensitiesNarrow_temp(Id(20));
CREATE INDEX Intensity_idx ON MinuteIntensitiesNarrow_temp(Intensity);

 
-- Validación de datos, verificar que no haya valores repetidos

SELECT COUNT(*) AS duplicados
 FROM MinuteIntensitiesNarrow_temp
 GROUP BY Id, ActivityDay, ActivityHour, Intensity
 HAVING COUNT(*) > 1; 

-- No es necesario revisar campos nulos o espaciados nuevamente ya que esto se hizo al transferir los valores a las columnas

DESCRIBE MinuteIntensitiesNarrow_temp;

-- La tabla está lista y formateada para ser usada o exportada

SELECT * FROM MinuteMETsNarrow_merged;

ALTER TABLE MinuteMETsNarrow_merged
 ADD COLUMN real_id TEXT,
 ADD COLUMN real_activityminute TEXT,
 ADD COLUMN real_MET INT;

UPDATE MinuteMETsNarrow_merged
 SET real_id = LEFT(LTRIM(Id), 10),
     real_MET = SUBSTRING_INDEX(CAST(Id AS CHAR), ',', -1),
     real_ActivityMinute = SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(Id AS CHAR), ',', 2), ',', -1);
 
 -- Revisar que todos los valores fueron transferidos y qu eno hay doble espaciado.
 
SELECT COUNT(*) FROM MinuteMETsNarrow_merged
 WHERE real_activityminute LIKE "%  %" OR real_activityminute IS NULL;
SELECT COUNT(*) FROM MinuteMETsNarrow_merged
 WHERE real_MET LIKE "%  %" OR real_MET IS NULL;
SELECT COUNT(*) FROM MinuteMETsNarrow_merged
 WHERE real_Id LIKE "%  %" OR real_Id IS NULL;

-- Eliminar las columnas inservibles y renombrar las que tienen los valores originales.

ALTER TABLE MinuteMETsNarrow_merged
 DROP COLUMN Id,
 DROP COLUMN ActivityMinute,
 DROP COLUMN MET;

ALTER TABLE MinuteMETsNarrow_merged
 CHANGE real_id Id TEXT, 
 CHANGE real_activityminute ActivityMinute TEXT,
 CHANGE real_MET MET INT;

-- Separación de columna en tabla temporal y reasignación de formatos correctos.

DROP TABLE IF EXISTS MinuteMETsNarrow_temp;
CREATE TEMPORARY TABLE MinuteMETsNarrow_temp AS
 SELECT
 Id,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', 1) AS ActivityDay,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', -2) AS ActivityHour,
 MET
 FROM MinuteMETsNarrow_merged;

SELECT * FROM MinuteMETsNarrow_temp;

UPDATE MinuteMETsNarrow_temp
 SET ActivityDay = STR_TO_DATE(ActivityDay,'%m/%d/%Y'),
     ActivityHour = STR_TO_DATE(ActivityHour,'%r'); 
 
ALTER TABLE MinuteMETsNarrow_temp
 CHANGE ActivityDay ActivityDay DATE,
 CHANGE ActivityHour ActivityHour TIME;
 
 -- Creación de ÍNDICES en la tabla temporal para optimizar consultas.
 
CREATE INDEX ActivityDay_idx ON MinuteMETsNarrow_temp(ActivityDay);
CREATE INDEX ActivityHour_idx ON MinuteMETsNarrow_temp(ActivityHour);
CREATE INDEX Id_idx ON MinuteMETsNarrow_temp(Id(20));
CREATE INDEX MET_idx ON MinuteMETsNarrow_temp(MET);

-- Validación de datos, verificar que no haya valores repetidos.

SELECT COUNT(*) AS duplicados
 FROM MinuteMETsNarrow_temp
 GROUP BY Id, ActivityDay, ActivityHour, MET
 HAVING COUNT(*) > 1; 

SELECT * FROM MinuteMETsNarrow_temp;
DESCRIBE MinuteMETsNarrow_temp;

-- La tabla está lista y formateada para ser usada o exportada

SELECT* FROM minuteStepsNarrow_merged;

ALTER TABLE minuteStepsNarrow_merged
 ADD COLUMN real_id TEXT,
 ADD COLUMN real_activityminute TEXT,
 ADD COLUMN real_Steps INT;

UPDATE minuteStepsNarrow_merged
 SET real_id = LEFT(LTRIM(Id), 10),
     real_Steps = SUBSTRING_INDEX(CAST(Id AS CHAR), ',', -1),
     real_ActivityMinute = SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(Id AS CHAR), ',', 2), ',', -1);
 
 -- Revisar que todos los valores fueron transferidos, que no hay campos nulos o doble espaciado.
 
SELECT COUNT(*) FROM minuteStepsNarrow_merged
 WHERE real_activityminute LIKE '%  %' OR  real_activityminute IS NULL;
SELECT COUNT(*) FROM minuteStepsNarrow_merged
 WHERE real_Steps LIKE '%  %' OR real_Steps IS NULL;
SELECT COUNT(*) FROM minuteStepsNarrow_merged
 WHERE real_Id LIKE '%  %' OR real_Id IS NULL;

-- Eliminar las columnas inservibles y renombrar las que tienen los valores originales.

ALTER TABLE minuteStepsNarrow_merged
 DROP COLUMN Id,
 DROP COLUMN ActivityMinute,
 DROP COLUMN Steps;

ALTER TABLE minuteStepsNarrow_merged
 CHANGE real_id Id TEXT, 
 CHANGE real_activityminute ActivityMinute TEXT,
 CHANGE real_Steps Steps INT;

-- Separación de columna en tabla temporal y reasignación de formatos correctos.

DROP TABLE IF EXISTS minuteStepsNarrow_temp;
CREATE TEMPORARY TABLE minuteStepsNarrow_temp AS
 SELECT
 Id,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', 1) AS ActivityDay,
 SUBSTRING_INDEX(CAST(ActivityMinute AS CHAR), ' ', -2) AS ActivityHour,
 Steps
 FROM minuteStepsNarrow_merged;

SELECT * FROM minuteStepsNarrow_temp;

UPDATE minuteStepsNarrow_temp
 SET ActivityDay = STR_TO_DATE(ActivityDay,'%m/%d/%Y'),
     ActivityHour = STR_TO_DATE(ActivityHour,'%r'); 
 
ALTER TABLE minuteStepsNarrow_temp
 CHANGE ActivityDay ActivityDay DATE,
 CHANGE ActivityHour ActivityHour TIME;
 
 -- Creación de ÍNDICES en la tabla temporal para optimizar consultas.
 
CREATE INDEX ActivityDay_idx ON minuteStepsNarrow_temp(ActivityDay);
CREATE INDEX ActivityHour_idx ON minuteStepsNarrow_temp(ActivityHour);
CREATE INDEX Id_idx ON minuteStepsNarrow_temp(Id(20));
CREATE INDEX Steps_idx ON minuteStepsNarrow_temp(Steps);

 -- Validación de datos, verificar que no haya valores repetidos.

SELECT COUNT(*) AS duplicados
 FROM minuteStepsNarrow_temp
 GROUP BY Id, ActivityDay, ActivityHour, Steps
 HAVING COUNT(*) > 1; 

SELECT * FROM minuteStepsNarrow_temp;
DESCRIBE minuteStepsNarrow_temp;

-- La tabla está lista y formateada para usarse o exportarse.

-- Exportación de bases de datos a formato csv con el comando INTO OUTFILE.

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'Steps')
UNION ALL
(SELECT Id, ActivityDay, ActivityHour, Steps
 FROM minuteStepsNarrow_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\minuteStepsNarrow_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'MET')
UNION ALL
(SELECT Id, ActivityDay, ActivityHour, MET
 FROM MinuteMETsNarrow_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\MinuteMETsNarrow_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'Intensity')
UNION ALL
(SELECT Id, ActivityDay, ActivityHour, Intensity
 FROM MinuteIntensitiesNarrow_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\MinuteIntensitiesNarrow_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'Calories')
UNION ALL
(SELECT Id, ActivityDay, ActivityHour, Calories
 FROM MinuteCaloriesNarrow_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\MinuteCaloriesNarrow_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

(SELECT 'Id', 'ActivityDay', 'ActivityHour', 'Value')
UNION ALL
(SELECT Id, ActivityDay, ActivityHour, Value
 FROM heartrate_seconds_temp)
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\heartrate_seconds_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Todas las tablas fueron exportadas en formato csv.