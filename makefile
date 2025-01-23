# Nombre de los ejecutables
F1_EXECUTABLE = ./build/f1app
GENERATE_EXECUTABLE = ./build/generar_carreras

# Archivos fuente y generados
F1_SOURCE = ./source/f1.l
F1_CPP = ./source/f1app.cpp
GENERATE_SOURCE = ./source/generar_carreras.cpp

# Archivo de datos y salida
CIRCUITOS_CSV = ./data/circuitos.csv
GENERATED_RACE_TXT = ./data/carreras_aleatorias.txt

# Compilador y banderas
CXX = g++
FLEX = flex++
CXXFLAGS = -std=c++17 -Wall -Wextra
FLEXFLAGS =

# Objetivos del Makefile

.PHONY: build clean generate_race clean_race rebuild

# Construye los ejecutables
build: $(F1_EXECUTABLE) $(GENERATE_EXECUTABLE)

$(F1_EXECUTABLE): $(F1_SOURCE)
	@echo "Generando archivo C++ a partir de $(F1_SOURCE)..."
	$(FLEX) $(FLEXFLAGS) -o $(F1_CPP) $(F1_SOURCE)
	@echo "Compilando $(F1_CPP) en $(F1_EXECUTABLE)..."
	$(CXX) $(CXXFLAGS) -o $(F1_EXECUTABLE) $(F1_CPP)
	@echo "Eliminando archivo temporal $(F1_CPP)..."
	rm -f $(F1_CPP)

$(GENERATE_EXECUTABLE): $(GENERATE_SOURCE)
	@echo "Compilando $(GENERATE_SOURCE) en $(GENERATE_EXECUTABLE)..."
	$(CXX) $(CXXFLAGS) -o $(GENERATE_EXECUTABLE) $(GENERATE_SOURCE)

# Ejecuta f1app con un archivo de texto como argumento
run_f1app: $(F1_EXECUTABLE)
	@echo "Ejecutando $(F1_EXECUTABLE)..."
	$(F1_EXECUTABLE) $(TXT_FILE)

# Limpia los archivos generados en la carpeta build
clean:
	@echo "Eliminando todo el contenido de la carpeta build..."
	rm -rf ./build/*

# Ejecuta el generador de carreras con 24 como argumento
generate_race: $(GENERATE_EXECUTABLE)
	@echo "Ejecutando $(GENERATE_EXECUTABLE) para generar carreras aleatorias..."
	$(GENERATE_EXECUTABLE) $(CIRCUITOS_CSV) 24

# Borra el archivo generado de carreras aleatorias
clean_race:
	@echo "Eliminando archivo de carreras generadas: $(GENERATED_RACE_TXT)..."
	rm -f $(GENERATED_RACE_TXT)

# Realiza limpieza completa y reconstrucción
rebuild: clean build
