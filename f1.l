%option noyywrap

/*----- Sección de Declaraciones ----------------*/

%{
#include <iostream>
#include <fstream>
#include <map>
#include <vector>
#include <string>
#include <algorithm> // Para std::find y std::sort
#include <sstream>

using namespace std;

string delimitador = "====================================";

// Estructuras y variables globales
struct Piloto {
    string equipo;
    int puntos;
};

struct Carrera {
    string circuito;
    string pais;
    string fecha;
    int vueltas;
    double distancia_vuelta;
    vector<string> posiciones_final;  // Lista de nombres de pilotos en posiciones finales
};

map<string, Piloto> pilotos;   // Mapa de pilotos con sus datos
vector<Carrera> carreras;      // Lista de carreras

ifstream fichero;               // Fichero para leer los datos

// Funciones
void procesarDatosCarrera();
void inicializarPilotos();
void actualizarPuntos(const vector<string>& posiciones);
void agregarCarrera(const Carrera& carrera);
void mostrarTodosLosPilotos();
void mostrarHistorialPiloto(const string& nombre);
void consultarCarreraPorFecha(const string& fecha);
void consultarCarreraPorCircuito(const string& circuito);
void mostrarClasificacionGeneral();

%}

/*----- Alias de Expresiones Regulares ----------------*/
DIGITO                  [0-9]
UPPER                   ([A-Z]|Ñ|Ä|Ö|Ü)
LOWER                   ([a-z]|ñ|ä|ö|ü)
UPPER_ACCENT            (Á|É|Í|Ó|Ú)
LOWER_ACCENT            (á|é|í|ó|ú)
CARACTER_ESPECIAL       (\-|\'|\`|\.)
PALABRA                 ({UPPER}|{LOWER}|{UPPER_ACCENT}|{LOWER_ACCENT}|{CARACTER_ESPECIAL})+
GUION                   ("-"|" -"|"- "|" - ")
ENTERO                  {DIGITO}+
DECIMAL                 ({DIGITO}+)"."({DIGITO}+)
ESPACIO                 [ \t]+

CIRCUITO                {PALABRA}({ESPACIO}{PALABRA})*" \("{PALABRA}({ESPACIO}{PALABRA})*"\)"
FECHA                   {DIGITO}{DIGITO}{DIGITO}{DIGITO}-{DIGITO}{DIGITO}-{DIGITO}{DIGITO}
FECHA_CARRERA           "Date: "{FECHA}
VUELTAS                 "Laps: "{ENTERO}
DISTANCIA               "Lap Distance \(km\): "{DECIMAL}
NOMBRE_PILOTO           {PALABRA}({ESPACIO}{PALABRA})*
POSICION                {ENTERO}"\. "{NOMBRE_PILOTO}
POSICIONES              "End Positions:\n"({POSICION}"\n")+

INFO_CARRERA            "Race: "{CIRCUITO}"\n"{FECHA_CARRERA}"\n"{VUELTAS}"\n"{DISTANCIA}"\n"{POSICIONES}


%%

{INFO_CARRERA} {
    // Extraer los datos de la carrera del texto detectado
    string input(yytext);
    Carrera nuevaCarrera;
    istringstream stream(input);
    string line;

    // Procesar línea por línea
    while (getline(stream, line)) {
        if (line.find("Race:") == 0) {
            size_t parenStart = line.find('(');
            size_t parenEnd = line.find(')');
            nuevaCarrera.circuito = line.substr(6, parenStart - 7);
            nuevaCarrera.pais = line.substr(parenStart + 1, parenEnd - parenStart - 1);
        } else if (line.find("Date:") == 0) {
            nuevaCarrera.fecha = line.substr(6);
        } else if (line.find("Laps:") == 0) {
            nuevaCarrera.vueltas = stoi(line.substr(6));
        } else if (line.find("Lap Distance (km):") == 0) {
            // Buscar exactamente después del prefijo "Lap Distance (km):"
            size_t startPos = line.find(":") + 1;
            string distanceStr = line.substr(startPos);
            // Eliminar espacios al inicio y final, si los hubiera
            distanceStr.erase(0, distanceStr.find_first_not_of(" \t"));
            distanceStr.erase(distanceStr.find_last_not_of(" \t") + 1);
            try {
                nuevaCarrera.distancia_vuelta = stod(distanceStr);
            } catch (const invalid_argument& e) {
                cerr << "Error: No se pudo convertir la distancia a número en la línea: " << line << endl;
                nuevaCarrera.distancia_vuelta = 0.0; // Valor por defecto en caso de error
            }
        } else if (isdigit(line[0])) {
            // Procesar posiciones finales
            size_t dotPos = line.find('.');
            string piloto = line.substr(dotPos + 2);
            nuevaCarrera.posiciones_final.push_back(piloto);
        }
    }

    // Guardar la carrera en la lista global
    carreras.push_back(nuevaCarrera);

    // Actualizar puntos de los pilotos según las posiciones finales
    actualizarPuntos(nuevaCarrera.posiciones_final);
}

.|\n {
    /* Ignorar */
}
%%

/*----- Sección de Procedimientos de Usuario ----------------*/

void inicializarPilotos() {
    pilotos = {
        {"Max Verstappen", {"Red Bull", 0 }},
        {"Sergio Pérez", {"Red Bull", 0 }},
        {"Charles Leclerc", {"Ferrari", 0 }},
        {"Carlos Sainz", {"Ferrari", 0 }},
        {"Lando Norris", {"McLaren", 0 }},
        {"Oscar Piastri", {"McLaren", 0 }},
        {"Fernando Alonso", {"Aston Martin", 0 }},
        {"Lance Stroll", {"Aston Martin", 0 }},
        {"Lewis Hamilton", {"Mercedes", 0 }},
        {"George Russell", {"Mercedes", 0 }},
        {"Kevin Magnussen", {"Haas", 0 }},
        {"Nico Hulkenberg", {"Haas", 0 }},
        {"Valtteri Bottas", {"Stake F1 Team Kick Sauber", 0 }},
        {"Guanyu Zhou", {"Stake F1 Team Kick Sauber", 0 }},
        {"Esteban Ocon", {"Alpine", 0 }},
        {"Pierre Gasly", {"Alpine", 0 }},
        {"Yuki Tsunoda", {"Visa Cash App RB F1 Team", 0 }},
        {"Liam Lawson", {"Visa Cash App RB F1 Team", 0 }},
        {"Alex Albon", {"Williams", 0 }},
        {"Franco Colapinto", {"Williams", 0 }}
    };
}

void actualizarPuntos(const vector<string>& posiciones) {
    // Sistema de puntos
    int puntos[] = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1};

    for (size_t i = 0; i < posiciones.size() && i < 10; ++i) {
        string piloto = posiciones[i];
        if (pilotos.find(piloto) != pilotos.end()) {
            pilotos[piloto].puntos += puntos[i];
        }
    }
}

void agregarCarrera(const Carrera& carrera) {
    cout << "Carrera añadida: " << carrera.circuito
         << " (" << carrera.pais << "), Fecha: " << carrera.fecha << endl;
}

// Mostrar todos los pilotos con su equipo
void mostrarPilotos() {
    cout << "Pilotos registrados:\n";
    cout << delimitador << endl;
    for (const auto& [nombre, piloto] : pilotos) {
        cout << "Nombre: " << nombre << ", Equipo: " << piloto.equipo
             << ", Puntos: " << piloto.puntos << "\n";
    }
    cout << delimitador << endl;
}

void mostrarCarreras() {
    cout << "Carreras registradas:\n";
    cout << delimitador << endl;
    for (const auto& carrera : carreras) {
        cout << "Circuito: " << carrera.circuito << " (" << carrera.pais << ")\n";
        cout << "Fecha: " << carrera.fecha << "\n";
        cout << "Vueltas: " << carrera.vueltas << "\n";
        cout << "Distancia por vuelta: " << carrera.distancia_vuelta << " km\n";
        cout << "Posiciones finales:\n";
        
        // Mostrar las posiciones finales
        for (size_t i = 0; i < carrera.posiciones_final.size(); ++i) {
            cout << i + 1 << ". " << carrera.posiciones_final[i] << "\n";
        }
        cout << delimitador << endl;
    }
}

// Mostrar historial de un piloto
void mostrarHistorialPiloto(const string& nombre) {
    cout << "Historial de carreras para el piloto: " << nombre << "\n";
    cout << delimitador << endl;
    bool encontrado = false;

    for (const auto& carrera : carreras) {
        auto it = find(carrera.posiciones_final.begin(), carrera.posiciones_final.end(), nombre);
        if (it != carrera.posiciones_final.end()) {
            int posicion = distance(carrera.posiciones_final.begin(), it) + 1; // Índice + 1
            cout << "Circuito: " << carrera.circuito << ", País: " << carrera.pais
                 << ", Fecha: " << carrera.fecha << ", Posición: " << posicion << "\n";
            encontrado = true;
        }
    }

    if (!encontrado) {
        cout << "El piloto no tiene historial en el top 10.\n";
    }

    cout << delimitador << endl;
}

// Consultar una carrera por fecha
void consultarCarreraPorFecha(const string& fecha) {
    cout << delimitador << endl;
    auto it = find_if(carreras.begin(), carreras.end(), [&](const Carrera& carrera) {
        return carrera.fecha == fecha;
    });

    if (it != carreras.end()) {
        const auto& carrera = *it;
        cout << "Circuito: " << carrera.circuito << " (" << carrera.pais << ")\n";
        cout << "Fecha: " << carrera.fecha << "\n";
        cout << "Vueltas: " << carrera.vueltas << "\n";
        cout << "Distancia por vuelta: " << carrera.distancia_vuelta << " km\n";
        cout << "Posiciones finales:\n";

        // Sistema de puntos para las posiciones
        int puntos[] = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1};

        for (size_t i = 0; i < carrera.posiciones_final.size(); ++i) {
            const string& piloto = carrera.posiciones_final[i];
            int puntosGanados = (i < 10) ? puntos[i] : 0;
            cout << i + 1 << ". " << piloto << " (" << puntosGanados << " puntos)\n";
        }
    } else {
        cout << "No se encontró una carrera en la fecha indicada.\n";
    }
    cout << delimitador << endl;
}

// Consultar una carrera por circuito
void consultarCarreraPorCircuito(const string& circuito) {
    cout << delimitador << endl;
    auto it = find_if(carreras.begin(), carreras.end(), [&](const Carrera& carrera) {
        return carrera.circuito == circuito;
    });

    if (it != carreras.end()) {
        const auto& carrera = *it;
        cout << "Circuito: " << carrera.circuito << " (" << carrera.pais << ")\n";
        cout << "Fecha: " << carrera.fecha << "\n";
        cout << "Vueltas: " << carrera.vueltas << "\n";
        cout << "Distancia por vuelta: " << carrera.distancia_vuelta << " km\n";
        cout << "Posiciones finales:\n";

        // Sistema de puntos para las posiciones
        int puntos[] = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1};

        for (size_t i = 0; i < carrera.posiciones_final.size(); ++i) {
            const string& piloto = carrera.posiciones_final[i];
            int puntosGanados = (i < 10) ? puntos[i] : 0;
            cout << i + 1 << ". " << piloto << " (" << puntosGanados << " puntos)\n";
        }
    } else {
        cout << "No se encontró una carrera en el circuito indicado.\n";
    }
    cout << delimitador << endl;
}

// Mostrar clasificación general de los pilotos
void mostrarClasificacionGeneral() {
    cout << delimitador << endl;
    vector<pair<int, string>> clasificacion;

    // Crear una lista de pilotos con puntos
    for (const auto& [nombre, piloto] : pilotos) {
        clasificacion.emplace_back(piloto.puntos, nombre);
    }

    // Ordenar por puntos (descendente)
    sort(clasificacion.rbegin(), clasificacion.rend());

    cout << "Clasificación General:\n";
    for (const auto& [puntos, nombre] : clasificacion) {
        cout << nombre << " (" << pilotos[nombre].equipo << ") - " << puntos << " puntos\n";
    }
    cout << delimitador << endl;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        cerr << "Uso: " << argv[0] << " <archivo_entrada.txt>" << endl;
        return 1; // Error si no se proporciona el archivo
    }

    // Abrir archivo con fstream
    ifstream fichero(argv[1]);
    if (!fichero.is_open()) {
        cerr << "Error al abrir el archivo: " << argv[1] << endl;
        return 1; // Error al abrir el archivo
    }

    inicializarPilotos();

    // Configurar Flex para procesar el archivo
    yyFlexLexer flujo (&fichero, 0);
    flujo.yylex(); // Procesar el archivo de entrada

    int opcion;

    do {
        cout << "\nMenú de opciones:\n";
        cout << "1. Mostrar todos los pilotos\n";
        cout << "2. Mostrar todas las carreras\n";
        cout << "3. Mostrar historial de un piloto\n";
        cout << "4. Consultar una carrera por fecha\n";
        cout << "5. Consultar una carrera por circuito\n";
        cout << "6. Mostrar clasificación general\n";
        cout << "7. Salir\n";
        cout << "\nElija una opción: ";

        cin >> opcion;

        switch (opcion) {
            case 1:
                mostrarPilotos();
                break;
            case 2:
                mostrarCarreras();
                break;
            case 3: {
                cout << "Ingrese el nombre del piloto: ";
                string nombre;
                cin.ignore();
                getline(cin, nombre);
                mostrarHistorialPiloto(nombre);
                break;
            }
            case 4: {
                cout << "Ingrese la fecha (YYYY-MM-DD): ";
                string fecha;
                cin >> fecha;
                consultarCarreraPorFecha(fecha);
                break;
            }
            case 5: {
                cout << "Ingrese el nombre del circuito: ";
                string circuito;
                cin.ignore();
                getline(cin, circuito);
                consultarCarreraPorCircuito(circuito);
                break;
            }
            case 6:
                mostrarClasificacionGeneral();
                break;
            case 7:
                cout << "Saliendo del programa...\n";
                break;
            default:
                cout << "Opción no válida. Inténtelo de nuevo.\n";
        }
    } while (opcion != 7);

    return 0;
}
