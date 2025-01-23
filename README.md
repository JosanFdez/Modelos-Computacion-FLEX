# **Proyecto de Procesamiento y Generación de Carreras de Fórmula 1**

Este proyecto combina el uso de **Flex** y **C++** para procesar y generar datos de carreras de Fórmula 1. Ofrece herramientas para leer, visualizar y generar carreras en un formato estructurado.

---

## **Estructura del Proyecto**

El proyecto se organiza en los siguientes directorios:


---

## **Requisitos Previos**

1. **Compilador C++** compatible con C++17.
2. **Flex** (compatible con `flex++`).
3. **Make**.

---

## **Funciones del Proyecto**

### **Procesamiento de Carreras**
El archivo `f1.l` permite leer y procesar archivos `.txt` con carreras en un formato específico.

El formato es el siguiente:

Se almacena información
- Circuito y país.
- Fecha de la carrera.
- Vueltas y distancia por vuelta.
- Posiciones finales de los pilotos.

El ehe

### **Generación de Carreras**
El archivo `generar_carreras.cpp` permite:
- Leer circuitos desde un archivo CSV (`data/circuitos.csv`).
- Generar un número configurable de carreras aleatorias.
- Guardar las carreras generadas en `data/carreras_aleatorias.txt`.

### **Opciones de Visualización**
- Listar todos los pilotos y sus puntos acumulados.
- Consultar carreras por fecha o circuito.
- Mostrar el historial de un piloto.

---

## **Formato de Archivos**

### **Archivo de Carreras (`.txt`)**

Cada carrera contenida en este archivo tendrá el siguiente formato:

Race: "Nombre del circuito" ("País del circuito")
Date: YYYY-MM-DD
Laps: "Número de vueltas"
Lap Distance (km): "Distancia por vuelta en kilómetros"
End Positions:
1. "Nombre del Piloto"
2. "Nombre del Piloto"
3. "Nombre del Piloto"
4. "Nombre del Piloto"
5. "Nombre del Piloto"
6. "Nombre del Piloto"
7. "Nombre del Piloto"
8. "Nombre del Piloto"
9. "Nombre del Piloto"
10. "Nombre del Piloto"

Si hubiera varias carreras, éstas estarán separadas por una línea en blanco.

### **Archivo CSV (`circuitos.csv`)**
Ejemplo del formato:

| **Nombre**            | **País**             | **Distancia (km)** |
|-----------------------|----------------------|--------------------|
| Silverstone Circuit   | United Kingdom       | 5.891              |
| Monza Circuit         | Italy                | 5.793              |
| Circuit de Monaco     | Monaco               | 3.337              |
| Suzuka International  | Japan                | 5.807              |
| Marina Bay Street     | Singapore            | 5.063              |

## **Opciones del Makefile**

El proyecto utiliza un **Makefile** para simplificar la compilación y ejecución de tareas.

### **build**
Compila los siguientes ejecutables:
1. `f1app`: Procesador de carreras.
2. `generar_carreras`: Generador de carreras aleatorias.

**Uso:**
```bash```
make build

### **run_f1app**
Ejecuta el procesador de carreras `f1app` con un archivo de texto como argumento. Los archivos que puedes usar son `2024_races.txt`, que contiene carreras reales sobre el campeonato de Fórmula 1 de 2024, o `carreras_aleatorias.txt` si has usado el programa para generar carreras aleatoriamente con la orden `make generate_race` o cualquier otro archivo txt que tenga el formato indicado anteriormente.

**Uso:**
```bash```
make run_f1app TXT_FILE=./data/<archivo>

### **clean**
Elimina los ejecutables generados con build.

**Uso:**
```bash```
make clean

### **generate_race**
Genera un archivo txt `carreras_aleatorias.txt` que contiene 24 carreras, representando la cantidad total de carreras de un campeonato de Fórmula 1. Guarda el archivo en la carpeta `data`. Si volvemos a ejecutar esta opción y ya existe el archivo, simplemente lo reemplazará.

**Uso:**
```bash```
make generate_race

**Uso:**
```bash```
make build

### **clean_race**
Elimina `carreras_aleatorias.txt`.

**Uso:**
```bash```
make clean_race

### **rebuild**
Limpia y recompila todo el proyecto

**Uso:**
```bash```
make rebuild
