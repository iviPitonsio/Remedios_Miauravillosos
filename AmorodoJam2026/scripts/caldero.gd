extends Area3D

@onready var efecto = $"../PotEffect"

func _on_body_entered(body):
	
	# Intentamos obtener el ID del ingrediente
	var id = body.get("id")
	
	# Para evitar que la mesa se interponga, en el caso que de que la detecte, la ignoraremos
	if id == null:
		return

	print("Ingrediente detectado con ID: ", id)
	ListaRecetas.anhadir_ingrediente(id)
		
	# Hacemos desaparecer el ingrediente
	body.queue_free()
	
	# Reproducimos el efecto de sonido
	if(ListaRecetas.ingredientesColocados > 0):	
		efecto.play()
		
	# Si ya tenemos los 2, cambiamos de escena
	if ListaRecetas.ingredientesColocados == 2:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/main.tscn")
		
