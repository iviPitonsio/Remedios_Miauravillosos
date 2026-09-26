extends Node

var sumaActual = 0
var ingredientesColocados = 0
var resultado = ""
var clienteActual: int = 0
var introCompletada: bool = false
var aciertos: int = 0

# Booleanas para que el dialogo ocurra una vez
var dialogoInicial: bool = false

##### IDs de los ingredientes #####
# Oso de urco => 1
# Cinza da lareira => 2
# Semente de carballo => 4
# Herba de San Xoán => 8

# Diccionario basado en la suma de los IDs con las distintas combinaciones
var recetas = { # Combinaciones que nunca se van a repetir:
	3: "Pós Fuxelonxe",   # (1+2) => oso + cinza
	5: "Píldoras Rompetestas",   # (1+4) => oso + semente
	6: "Píldoras Medramoito",  # (2+4) => semente + cinza
	9: "Loción Ultracabelus", # (1+8) => oso + herba
	10: "Crema Nonpodomais",  # (2+8) => herba + cinza
	12: "Zume Sosego" # (4+8) => semente + herba
}

# Funcion que reseta todos los valores a 0 cada vez que queramos crear una poción nueva
func reset_mezcla():
	sumaActual = 0
	ingredientesColocados = 0
	resultado = ""

func anhadir_ingrediente(id: int):
	sumaActual += id
	ingredientesColocados += 1
	
	# Si ya tenemos todos los ingredientes
	if ingredientesColocados == 2:
		resultado = recetas[sumaActual] 
		#Guardamos en el resultado la poción correspondiente al numero en el diccionario igual a la suma de los IDs


# Reseteamos todas las variables al terminar el juego
func reset_partida():
	introCompletada = false
	clienteActual = 0
	dialogoInicial = false
	aciertos = 0
	resultado = ""
	ingredientesColocados = 0
	sumaActual = 0
	
# Reseteo de variables solo para la escena de la mesa
func reset_mesa():
	ingredientesColocados = 0
	sumaActual = 0
