extends CanvasLayer

@onready var pausa = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	# La interfaz del menú de pausa empieza cerrada
	pausa.visible = false

func _input(event):
	# Si el jugador pulsa la tecla esc
	if event.is_action_pressed("pausa"):
		# Si estamos en el menú principal, no podremos pausar
		if get_tree().current_scene.name == "MenuInicio":
			return
		else:
			pausar_juego()


func pausar_juego():
	
	pausa.visible = true
	
	# Invertimos el estado de pausa del motor de juego, para poder reciclar esta función cuando le demos a "Continuar"
	get_tree().paused = !get_tree().paused
	
	# Hacemos que la visibilidad del menú coincida con el estado de pausa
	pausa.visible = get_tree().paused
	
func _on_boton_continuar_pressed():
	pausar_juego()
	
func _on_boton_sair_pressed():
	get_tree().quit() # Salimos del juego
