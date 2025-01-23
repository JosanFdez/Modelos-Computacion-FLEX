#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <random>
#include <algorithm>
#include <iomanip> // Para std::setw y std::setfill

using namespace std;

// Estructura para representar un circuito
struct Circuito {
    string name;
    string country;
    double distance;
};

// Lista de pilotos
vector<string> pilotos = {
    "Max Verstappen", "Sergio Pérez", "Charles Leclerc", "Carlos Sainz",
    "Lando Norris", "Oscar Piastri", "Fernando Alonso", "Lance Stroll",
    "Lewis Hamilton", "George Russell", "Kevin Magnussen", "Nico Hulkenberg",
    "Valtteri Bottas", "Guanyu Zhou", "Esteban Ocon", "Pierre Gasly",
    "Yuki Tsunoda", "Liam Lawson", "Alex Albon", "Franco Colapinto"
};

// Función para generar un número aleatorio dentro de un rango
int numeroAleatorio(int min, int max) {
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(min, max);
    return dis(gen);
}

// Función para leer circuitos desde un archivo CSV
vector<Circuito> leerCircuitosDesdeCSV(const string& archivoCSV) {
    vector<Circuito> circuitos;
    ifstream archivo(archivoCSV);
    if (!archivo.is_open()) {
        cerr << "Error al abrir el archivo CSV: " << archivoCSV << endl;
        return circuitos;
    }

    string linea;
    getline(archivo, linea); // Saltar la primera línea (encabezado)
    while (getline(archivo, linea)) {
        stringstream ss(linea);
        string name, country, distanceStr;
        getline(ss, name, ',');
        getline(ss, country, ',');
        getline(ss, distanceStr, ',');

        Circuito circuito;
        circuito.name = name;
        circuito.country = country;
        circuito.distance = stod(distanceStr); // Convertir distancia a double
        circuitos.push_back(circuito);
    }

    archivo.close();
    return circuitos;
}

// Función para generar carreras aleatorias y guardar en un archivo .txt
void generarCarrerasDesdeCSV(const vector<Circuito>& circuitos, int numCarreras) {
    // Ruta del archivo de salida
    string rutaSalida = "./data/carreras_aleatorias.txt";

    ofstream archivo(rutaSalida);
    if (!archivo.is_open()) {
        cerr << "No se pudo crear el archivo de salida: " << rutaSalida << endl;
        return;
    }

    random_device rd;
    mt19937 gen(rd());

    for (int i = 0; i < numCarreras; ++i) {
        // Seleccionar un circuito aleatorio
        uniform_int_distribution<> circuitoDist(0, circuitos.size() - 1);
        const Circuito& circuito = circuitos[circuitoDist(gen)];

        // Generar datos aleatorios para la carrera
        int vueltas = numeroAleatorio(50, 78);

        // Generar una fecha aleatoria en formato YYYY-MM-DD
        int anio = 2024;
        int mes = numeroAleatorio(1, 12);
        int dia = numeroAleatorio(1, 28);

        stringstream fechaStream;
        fechaStream << anio << "-"
                    << setw(2) << setfill('0') << mes << "-"
                    << setw(2) << setfill('0') << dia;
        string fecha = fechaStream.str();

        // Generar una lista de pilotos aleatoria
        vector<string> pilotosAleatorios = pilotos;
        shuffle(pilotosAleatorios.begin(), pilotosAleatorios.end(), gen);

        // Escribir los datos en el archivo en formato .txt
        archivo << "Race: " << circuito.name << " (" << circuito.country << ")\n";
        archivo << "Date: " << fecha << "\n";
        archivo << "Laps: " << vueltas << "\n";
        archivo << "Lap Distance (km): " << circuito.distance << "\n";
        archivo << "End Positions:\n";

        for (int j = 0; j < 10; ++j) {
            archivo << j + 1 << ". " << pilotosAleatorios[j] << "\n";
        }

        archivo << "\n"; // Separar las carreras con una línea en blanco
    }

    archivo.close();
    cout << "Archivo 'carreras_aleatorias.txt' generado con " << numCarreras << " carreras." << endl;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        cerr << "Uso: " << argv[0] << " <archivo_csv> <numero_de_carreras>" << endl;
        return 1;
    }

    string archivoCSV = argv[1];
    int numCarreras = stoi(argv[2]);

    if (numCarreras <= 0) {
        cerr << "El número de carreras debe ser mayor que 0." << endl;
        return 1;
    }

    vector<Circuito> circuitos = leerCircuitosDesdeCSV(archivoCSV);
    if (circuitos.empty()) {
        cerr << "No se pudieron leer circuitos desde el archivo CSV." << endl;
        return 1;
    }

    generarCarrerasDesdeCSV(circuitos, numCarreras);
    return 0;
}
