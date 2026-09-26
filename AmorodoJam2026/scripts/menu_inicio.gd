extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Music.play_track("inicio", 0.0)


func _on_boton_inicio_pressed():
	# Cambio de escena
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/main.tscn")


func _on_boton_salir_pressed():
	# Cerramos el ejecutable
	get_tree().quit()


func _on_boton_creditos_pressed():
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/creditos.tscn")


func _on_opcións_pressed():
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/opciones.tscn")
