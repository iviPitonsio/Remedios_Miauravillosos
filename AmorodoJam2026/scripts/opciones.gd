extends Control

@onready var botonPC = $VBoxContainer2/pantallaCompleta
@onready var selectorIdioma = $VBoxContainer2/Idiomas

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Sincronizamos el estado del botón con la realidad del juego al cargar el menú
	var modoActual = DisplayServer.window_get_mode()
	
	if modoActual == DisplayServer.WINDOW_MODE_FULLSCREEN or modoActual == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		botonPC.button_pressed = true
	else:
		botonPC.button_pressed = false
		
	# Limpiamos por si acaso y añadimos los idiomas en orden
	selectorIdioma.clear()
	selectorIdioma.add_item("Español") 
	selectorIdioma.add_item("Galego")  
	selectorIdioma.add_item("English") 
	
	# Sincronizamos el OptionButton con el idioma que ya tenga el juego al abrir el menú
	var idiomaActual = TranslationServer.get_locale()
	
	if idiomaActual.begins_with("gl"):
		selectorIdioma.selected = 1
	elif idiomaActual.begins_with("en"):
		selectorIdioma.selected = 2
	else:
		selectorIdioma.selected = 0
		
	# Conectamos la señal por código
	selectorIdioma.item_selected.connect(_on_idioma_selected)


func _on_volumen_value_changed(value):
	# Convertimos el valor lineal (0.0 a 1.0) a decibelios
	var volumen_db = linear_to_db(value)
	
	# Aplicamos los decibelios al bus de audio 0
	AudioServer.set_bus_volume_db(0, volumen_db)


func _on_resolucion_item_selected(index):
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	botonPC.button_pressed = false # Desactivamos el botón de pantalla completa
	
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1280,720))
	
	# Centramos la ventana en la pantalla del usuario tras el cambio de tamaño
	DisplayServer.window_set_position(DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2 - DisplayServer.window_get_size()/2)
	

func _on_pantalla_completa_toggled(toggled_on):
		if toggled_on:
			# Activamos la pantalla completa
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			# Volvemos al modo ventana normal
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_boton_sair_pressed():
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/menu_inicio.tscn")

func _on_idioma_selected(index: int):
	match index:
		0:
			TranslationServer.set_locale("es")
		1:
			TranslationServer.set_locale("gl")
		2:
			TranslationServer.set_locale("en")
