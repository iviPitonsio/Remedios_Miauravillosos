extends Node3D

var paginaActual: int = 0
@onready var libro = $InterfazLibro
@onready var botonLibro = $BotonLibro
@onready var pagina = $InterfazLibro/Pag
@onready var botonIzq = $InterfazLibro/BotonIzq
@onready var botonDer = $InterfazLibro/BotonDer

const PAGINAS = [
	preload("res://AmorodoJam2026/assets/2D/pantallas/libro/gl/libro_receta1.png"),
	preload("res://AmorodoJam2026/assets/2D/pantallas/libro/gl/libro_receta2.png"),
	preload("res://AmorodoJam2026/assets/2D/pantallas/libro/gl/libro_receta3.png"),
	preload("res://AmorodoJam2026/assets/2D/pantallas/libro/gl/libro_receta4.png"),
	preload("res://AmorodoJam2026/assets/2D/pantallas/libro/gl/libro_receta5.png"),
	preload("res://AmorodoJam2026/assets/2D/pantallas/libro/gl/libro_receta6.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	libro.visible = false


func _on_boton_libro_pressed():
	# Hacemos visible la interfaz del libro
	libro.visible = true
	botonLibro.visible = false
	
	# Pausamos el juego de fondo
	get_tree().paused = true


func _on_boton_salir_pressed():
	# Ocultamos de nuevo la interfaz
	libro.visible = false
	botonLibro.visible = true
	
	# Reanudamos el juego
	get_tree().paused = false
	

func actualizar_libro():
	# Cambiamos la textura de la página por la actual de la lista
	pagina.texture = PAGINAS[paginaActual]
	
	# Si es la primera página, ocultamos la flecha izquierda
	if paginaActual == 0:
		botonIzq.visible = false
	else:
		botonIzq.visible = true
		
	# Si es la última página, ocultamos la flecha derecha
	if paginaActual == PAGINAS.size() - 1:
		botonDer.visible = false
	else:
		botonDer.visible = true


# Botón izquierdo 
func _on_boton_izq_pressed():
	if paginaActual > 0:
		paginaActual -= 1
		actualizar_libro()

# Botón derecho
func _on_boton_der_pressed():
	if paginaActual < PAGINAS.size() - 1:
		paginaActual += 1
		actualizar_libro()
		


func _on_boton_reset_pressed():
	ListaRecetas.reset_mesa()
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/mesa.tscn")
