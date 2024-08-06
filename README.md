# Proyecto de Carga, Limpieza, Validación y Exportación de Datos en MySQL

Para este proyecto se utilizó:
 MySQL 8.0.35.
 Herramienta de administración gráfica Workbench.
 Acceso a la línea de comandos (CMD) de Windows.

## Descripción
Este proyecto consiste en la carga y limpieza de datos en MySQL utilizando dos métodos de importación, para pequeños y grandes volumenes de datos. 
El proceso incluye la importación de archivos CSV, la validación y transformación de datos, y la exportación de las tablas limpias en formato CSV.

Se divide en dos partes: 
La primera parte consiste en la importación de datos usando la interfaz de Workbench, con el asistente "Table Data Import Wizard", útil para bases de datos con un menor número de registros.

La segunda parte consiste en la importación de datos usando el comando `mysqlimport` desde CMD, útul para bases de datos con un mayor número de registros.


## Pasos Realizados

1. **Verificación de Permisos y Configuraciones**
   - Verificación de la variable `local_infile`
   - Otorgar permisos para `mysqlimport`

2. **Creación de Tablas**
   - Creación de tablas para la importación de datos desde archivos CSV.

3. **Importación de Datos**
   - Importación de datos desde la línea de comandos utilizando `mysqlimport`.
   - Importación de datos usando la interfaz de Workbench, con el asistente "Table Data Import Wizard".

4. **Verificación y Validación de Datos**
   - Verificación de datos importados.
   - Revisión de duplicados, valores nulos y formatos incorrectos.

5. **Transformación y Formateo de Datos**
   - Separación de columnas de fecha y hora.
   - Cambio de formatos a DATE y TIME.
   - Creación de índices para optimización de consultas.

6. **Exportación de Datos Limpios**
   - Exportación de las tablas limpias a archivos CSV.

## Ejecución del Script

1. Ejecutar el script SQL en MySQL Workbench o desde la terminal para realizar la limpieza y transformación de datos.
2. Se recomienda ejecutar el script por partes, siguiendo los pasos dentro del mismo para evitar errores.
3. Ejecutar el comando `mysqlimport` para importar los datos, adecuandolo a la ubicación de los archivos CSV que se adjuntan con el proyecto.
4. Ejecutar el script SQL en MySQL Workbench o desde la terminal para realizar la limpieza y transformación de datos.

## Consideraciones
- Asegurarse de que los archivos CSV estén correctamente formateados.
- Ajustar los parámetros de conexión y tiempo de espera según sea necesario.
- Todos los pasos, usos de comandos y solución de errores, se encuentran explicados dentro del script.

## Referencias
- [Solución al error de conexión perdida en MySQL](https://www.javierrguez.com/solucion-error-mysql-lost-connection/)

- [Solución al error 'secure_file_prive'](https://www.youtube.com/watch?v=aPj0XyuTiXE)

## Acceso a la descarga de base de datos original
 (https://zenodo.org/records/53894#.X9oeh3Uzaao)

## Autor
[Diana Herrera]

