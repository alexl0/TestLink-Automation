#!/bin/bash

# Directorio de origen y destino
origen="/c/Users/50052086/Downloads/temp/cucumber/IOT"
# ¡¡ASEGURARSE DE QUE EXISTE LA CARPETA DESTINATION!!
mkdir "/c/Users/50052086/Desktop/git/RYD/ctg-did.pcf/integration_test/pcf_cicd_bdd/target/destination"
destino="/c/Users/50052086/Desktop/git/RYD/ctg-did.pcf/integration_test/pcf_cicd_bdd/target/destination"

# Buscar archivos cucumber-report.json de forma recursiva en el directorio de origen
archivos=$(find "$origen" -name "cucumber-report.json")

# Verificar si se encontraron archivos
if [ -z "$archivos" ]; then
    echo "No se encontraron archivos cucumber-report.json en el directorio de origen."
    echo "Estás seguro de que el script mira en estas subcarpetas?"
else
    for archivo in $archivos; do
        # Verificar si el archivo contiene "status": "failed"
        if grep -q '"status": "failed"' "$archivo"; then
            nombre_carpeta=$(dirname "$archivo")
            echo -e "\e[31mEl archivo $archivo en la carpeta $nombre_carpeta no fue transferido debido a que contiene algún step a failed\e[0m"
        else
            # Copiar el archivo al destino
            cp -f "$archivo" "$destino"
            echo "El archivo $archivo ha sido transferido correctamente."
            # Ejecutar el comando mvn
            cd "$destino"
            cd ..
            cd ..
            echo "Ejecutando mvn..."
            if mvn -f test-pom.xml install -Dmaven.test.skip=true | grep -q "BUILD SUCCESS"; then
                echo -e "\e[32mLa compilación con mvn se realizó con éxito.\e[0m"
            else
                echo -e "\e[31mHubo un error durante la compilación con mvn.\e[0m"
            fi
        fi
    done
fi