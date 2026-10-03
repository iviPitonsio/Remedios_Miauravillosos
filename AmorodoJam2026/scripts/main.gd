extends Node3D

# Guardamos en esta variable del inspector el archivo del personaje de Dialogic
@export var personaje: DialogicCharacter

# Variables que guardan la posición original de la poción
var posicionInicial: Vector3
var rotacionInicial: Vector3

# Variable en la que guardamos el objeto agarrado
var objetoAgarrado: Area3D = null

# Variables en las que guardamos datos de la cámara
var distanciaCamara: float = 0.0
var profundidadFija: float = 0.0


@onready var botonMesa = $BotonMesa

# Referencia al nodo visual 
@onready var visualPocion = $Area3D/MeshInstance3D


# Variables de Queixo (invivible, no tiene retrato)
@onready var puntoQueixo = $Queixo
const QUEIXO = preload("res://AmorodoJam2026/personajes/queixo.dch")

# Cargamos en la escena los posibles encargos
const FUXELONXE = preload("res://AmorodoJam2026/assets/3D/fuxelonxe.fbx")
const MEDRAMOITO = preload("res://AmorodoJam2026/assets/3D/medramoito.fbx")
const NONPODOMAIS = preload("res://AmorodoJam2026/assets/3D/nonpodomais.fbx")
const ROMPETESTAS = preload("res://AmorodoJam2026/assets/3D/rompetestas.fbx")
const ULTRACABELUS = preload("res://AmorodoJam2026/assets/3D/ultracabelus.fbx")
const ZUMESOSEGO = preload("res://AmorodoJam2026/assets/3D/zumeSosego.fbx")

# Cargamos en la escena las texturas
const TEXTURAS_POCIONES = {
 	"Pós Fuxelonxe" = preload("res://AmorodoJam2026/assets/3D/texturas/Fuxelonxe_DefaultMaterial_AlbedoTransparency.png"),
 	"Píldoras Medramoito" = preload("res://AmorodoJam2026/assets/3D/texturas/Medramoito_DefaultMaterial_AlbedoTransparency.png"),
 	"Crema Nonpodomais" = preload("res://AmorodoJam2026/assets/3D/texturas/Nonpodomais_DefaultMaterial_AlbedoTransparency.png"),
 	"Píldoras Rompetestas" = preload("res://AmorodoJam2026/assets/3D/texturas/Rompetestas_DefaultMaterial_AlbedoTransparency.png"),
 	"Loción Ultracabelus" = preload("res://AmorodoJam2026/assets/3D/texturas/Ultracabelus_DefaultMaterial_BaseColor.png"),
 	"Zume Sosego" = preload("res://AmorodoJam2026/assets/3D/texturas/ZumeSosego_DefaultMaterial_AlbedoTransparency.png")
}


# Lista de turnos de la tienda. Cada cliente tiene su timeline de llegada, 
# la poción que pide, y la timeline que se activa si acierta.
const CLIENTES_COLA = [
	{
		"personaje_dialogic": preload("res://AmorodoJam2026/personajes/muselina.dch"),
		"timeline_llegada": "muselina_llegada",
		"pocion_pedida": "Zume Sosego",
		"timeline_acierto": "muselina_sosego",
		"timeline_fallo": "muselina_fallo",
		"timeline_intermedia": "queixo02",
		"spriteBase": preload("res://AmorodoJam2026/assets/2D/personajes/muselina/Muselina.png"),
		"spriteAlegre": preload("res://AmorodoJam2026/assets/2D/personajes/muselina/Muselina_Alegre.png"),
		"spriteEnfadada": preload("res://AmorodoJam2026/assets/2D/personajes/muselina/Muselina_Enfadada.png")
	},
	{
		"personaje_dialogic": preload("res://AmorodoJam2026/personajes/pita.dch"),
		"timeline_llegada": "pita_llegada",
		"pocion_pedida": "Píldoras Rompetestas",
		"timeline_acierto": "pita_acierto",
		"timeline_fallo": "pita_fallo",
		"timeline_intermedia": "queixo03",
		"spriteBase": preload("res://AmorodoJam2026/assets/2D/personajes/pita/Pita.png"),
		"spriteAlegre": preload("res://AmorodoJam2026/assets/2D/personajes/pita/Pita_Contenta.png"),
		"spriteEnfadada": preload("res://AmorodoJam2026/assets/2D/personajes/pita/Pita_Enfadada.png")
	},
	{
		"personaje_dialogic": preload("res://AmorodoJam2026/personajes/pardal.dch"),
		"timeline_llegada": "pardal_llegada",
		"pocion_pedida": "Crema Nonpodomais",
		"timeline_acierto": "pardal_acierto",
		"timeline_fallo": "pardal_fallo",
		"timeline_intermedia": "queixo04",
		"spriteBase": preload("res://AmorodoJam2026/assets/2D/personajes/pardal/Pardal.png"),
		"spriteAlegre": preload("res://AmorodoJam2026/assets/2D/personajes/pardal/Emilia_Contenta.png"),
		"spriteEnfadada": preload("res://AmorodoJam2026/assets/2D/personajes/pardal/Emilia_Enfadada.png")
	}
]

# Called when the node enters the scene tree for the first time.
func _ready():

	Music.play_track("juego", 2.0)
	
	# Guardamos la posición original de la poción, para devolverla ahí si el jugador la suelta
	posicionInicial = $Area3D.global_position
	rotacionInicial = $Area3D.global_rotation
	
	if not ListaRecetas.introCompletada:
		$Personaje.visible = false # Escondemos al cliente en cola temporalmente

		var dialogoIntro = Dialogic.start("queixo01")
		dialogoIntro.register_character(QUEIXO, puntoQueixo)
		
	else:
	
		# Comprobamos si nos quedan clientes por atender en la cola
		if ListaRecetas.clienteActual < CLIENTES_COLA.size():
			var datosCliente = CLIENTES_COLA[ListaRecetas.clienteActual]
			
			$Personaje.texture = datosCliente["spriteBase"]
			
			# Solo iniciamos el diálogo si no se había iniciado ya esta ronda
			if not ListaRecetas.dialogoInicial:
				nuevo_cliente(CLIENTES_COLA[ListaRecetas.clienteActual])
		
		else:
			# Si ya se completaron todos los clientes al iniciar
			$Personaje.visible = false
			get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/main.tscn")


	# Cambiamos el aspecto del objeto antes de que el jugador lo vea
	actualizarPocion()

	Dialogic.signal_event.connect(_on_dialogic_signal)


### ENTREGAR OBJETO

func _input(event):
	# Si la timeline está funcionando, no permitimos que el jugador haga nada en el entorno
	if Dialogic.current_timeline != null:
		return
		
	# Detectamos que el jugador esté intentando agarrar un objeto
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			intentar_agarrar()
		else:
			soltar_objeto()

func intentar_agarrar():
	#Guardamos la posición del ratón y la de la cámara
	var raton = get_viewport().get_mouse_position()
	var camara = get_viewport().get_camera_3d()
	
	# Proyectamos un rayo desde la cámara para que compruebe si intentamos agarrar un objeto
	var from = camara.project_ray_origin(raton) # punto de origen del rayo
	var to = from + camara.project_ray_normal(raton) * 100 # destino del rayo 
	
	# Comprobamos si chocamos con un objeto
	var spaceState = get_world_3d().direct_space_state #Con space state, detectamos la posición de todos los objetos y colisiones dle mundo
	
	# Creamos el rayo
	var rayo = PhysicsRayQueryParameters3D.create(from, to)
	
	# Habilitamos que el rayo pueda tocar areas
	rayo.collide_with_areas = true
	
	var colision = spaceState.intersect_ray(rayo) # Lanzamos el rayo y, si choca, guardamos los datos en una variable
	
	# Si el objeto toca 
	if colision and colision.collider == $Area3D:
		objetoAgarrado = colision.collider #Guardamos el objeto en una variable

		# Lo mantenemos a la misma distancia que está de la cámara
		distanciaCamara = from.distance_to(colision.position)
			
		# Guardamos la profundidad Z exacta que tiene el objeto al tocarlo para evitar que se mueva en ese eje más adelante
		profundidadFija = objetoAgarrado.global_position.z

func soltar_objeto():
	if objetoAgarrado:

		# Creamos un Tween para poder animar de forma suave el regreso del objeto a su sitio
		var tween = create_tween()
		
		# Configuramos para que el movimiento sea fluido y vuelva rápido a su sitio
		tween.set_trans(Tween.TRANS_CUBIC) 
		tween.set_ease(Tween.EASE_OUT)
		
		# Con el paralell, reseteamos a la vez la posición y rotación del objeto
		tween.parallel().tween_property(objetoAgarrado, "global_position", posicionInicial, 0.5)
		tween.parallel().tween_property(objetoAgarrado, "global_rotation", rotacionInicial, 0.5)
		
		objetoAgarrado = null # Limpiamos la variable para que el objeto no se siga moviendo con el ratón

func _process(_delta): 
	
	if Dialogic.current_timeline != null:
		botonMesa.visible = false
	else:
		botonMesa.visible = true
		
	if get_tree().paused:
		return
		

	if objetoAgarrado:
		var raton = get_viewport().get_mouse_position()
		var camara = get_viewport().get_camera_3d()

		#Guardamos en una variable las coordenadas del objeto en todo momento mientras lo movemos
		var mover = camara.project_position(raton, distanciaCamara)
		
		mover.z = profundidadFija
		
		# Asignamos la posición
		objetoAgarrado.global_position = mover


func _on_entrega_objeto_area_entered(area):
	
	if area != $Area3D:
		return
	
	# Si ya no quedan clientes válidos, salimos
	if ListaRecetas.clienteActual >= CLIENTES_COLA.size():
		return
		
	var recetaJugador = ListaRecetas.resultado
	var datosCliente = CLIENTES_COLA[ListaRecetas.clienteActual]
	var timeline = ""
	
	# Comprobamos si el jugador ha acertado la poción exacta que pide este cliente específico
	if recetaJugador == datosCliente["pocion_pedida"]:
		timeline = datosCliente["timeline_acierto"]
		ListaRecetas.aciertos += 1
		$Personaje.texture = datosCliente["spriteAlegre"]
	else:
		timeline = datosCliente["timeline_fallo"] 
		$Personaje.texture = datosCliente["spriteEnfadada"]

	# Iniciamos la conversación correspondiente
	var dialogoEntrega = Dialogic.start(timeline)
	dialogoEntrega.register_character(datosCliente["personaje_dialogic"], $Personaje/Marker3D)
	dialogoEntrega.register_character(QUEIXO, puntoQueixo)
	

	if objetoAgarrado:
		objetoAgarrado = null
		
	$Area3D.visible = false # Ocultamos el contenedor para que no se quede flotando
	
	ListaRecetas.reset_mezcla()


### PASAR A LA ESCENA DE LA MESA

func _on_boton_mesa_pressed():
	ListaRecetas.ingredientesColocados = 0
	ListaRecetas.sumaActual = 0
	Music.play_track("juego2", 0.5)
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/mesa.tscn")

### ACTUALIZAR RESULTADO

func actualizarPocion():
	var resultado = ListaRecetas.resultado

	# Si no hay mezcla hecha (inicio del juego), dejamos el cubo invisible 
	if resultado == "":
		visualPocion.visible = false
		return
		
	var fbx = null
	
	# Evaluamos las recetas para elegir el modelo 3D correcto
	match resultado:
		"Pós Fuxelonxe": fbx = FUXELONXE
		"Píldoras Rompetestas": fbx = ROMPETESTAS
		"Píldoras Medramoito": fbx = MEDRAMOITO
		"Loción Ultracabelus": fbx = ULTRACABELUS
		"Crema Nonpodomais": fbx = NONPODOMAIS
		"Zume Sosego": fbx = ZUMESOSEGO
		
	# Si ya tenemos el objeto
	if fbx != null:
		$Area3D.visible = true
			
		# Si ya habíamos spawnearlo otra poción antes en esta partida, la limpiamos
		for hijo in $Area3D.get_children():
			if hijo is CollisionShape3D == false: # No borramos la colisión
				hijo.queue_free()
		
		# Instanciamos el modelo
		var modeloFinal = fbx.instantiate()
		
		# Lo metemos dentro del Area3D
		$Area3D.add_child(modeloFinal)
		
		# Si la receta tiene textura asignada en nuestro diccionario
		if TEXTURAS_POCIONES.has(resultado):
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = TEXTURAS_POCIONES[resultado]
			
			# Activamos la transparencia
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
			# Asignamos el material buscando la malla real dentro del modelo
			_aplicar_material(modeloFinal, mat)
			
			
		# Reseteamos su posición local para que esté en el centro del Area3D
		modeloFinal.position = Vector3.ZERO
		modeloFinal.rotation = Vector3.ZERO
		
		# Controlamos el tamaño del objeto
		modeloFinal.scale = Vector3(0.3, 0.3, 0.3)

### MATERIALES

func _aplicar_material(nodo: Node, material: Material):
	if nodo is MeshInstance3D:
		nodo.set_surface_override_material(0, material)
	
	# Recorremos los nodos hijos recursivamente hasta dar con la malla
	for hijo in nodo.get_children():
		_aplicar_material(hijo, material)

### NUEVO CLIENTE LLEGA

func nuevo_cliente(datos: Dictionary):
	$Personaje.fade_in(1.5)
	$Personaje.texture = datos["spriteBase"]
	var dialogo = Dialogic.start(datos["timeline_llegada"])
	dialogo.register_character(datos["personaje_dialogic"], $Personaje/Marker3D)
	dialogo.register_character(QUEIXO, puntoQueixo)
	ListaRecetas.dialogoInicial = true

### FINAL DEL JUEGO

func _on_dialogic_signal(argumento: String):
	match argumento:
		"finalQueixo":
			
			# Terminamos la timeline del cliente
			Dialogic.end_timeline()
			
			# El personaje actual se marcha
			$Personaje.fade_out(1.5)
			await get_tree().create_timer(1.5).timeout 
			
			# Limpiamos las burbujas de texto del cliente antes de que hable Queixo
			var layout = Dialogic.Styles.get_layout_node()
			if layout:
				layout.queue_free()
			await get_tree().process_frame
			
			var datosActuales = CLIENTES_COLA[ListaRecetas.clienteActual]
			
			var dialogoIntermedio = Dialogic.start(datosActuales["timeline_intermedia"])
			dialogoIntermedio.register_character(QUEIXO, puntoQueixo)
			
			
		"final":
			Dialogic.end_timeline()
			
			var layout = Dialogic.Styles.get_layout_node()
			if layout:
				layout.queue_free()

			# Esperamos un frame para garantizar que Godot ha eliminado el layout de la memoria
			await get_tree().process_frame

			if not ListaRecetas.introCompletada:
				ListaRecetas.introCompletada = true 
				$Personaje.visible = true

				nuevo_cliente(CLIENTES_COLA[ListaRecetas.clienteActual])
				return # Salimos aquí para que no avance de ronda todavía
			
			# Pasamos al siguiente cliente de la lista
			ListaRecetas.clienteActual += 1

			# Resetemos el interruptor global para que el nuevo cliente pueda hablar al llegar
			ListaRecetas.dialogoInicial = false 

			# Más clientes en la cola?
			if ListaRecetas.clienteActual < CLIENTES_COLA.size():

				# Hacemos aparecer al nuevo personaje 
				nuevo_cliente(CLIENTES_COLA[ListaRecetas.clienteActual])
			
			else:
				# Si ya no quedan más clientes en el array, entonces terminamos el juego y vemos si el jugador ha ganado o no
				if ListaRecetas.aciertos == 3:
					var finalBueno = Dialogic.start("final_bueno")
					finalBueno.register_character(QUEIXO, puntoQueixo)
					$PantallaFinal.texture = load("res://AmorodoJam2026/assets/2D/pantallas/final/pantalla_final_bien.png")
					Music.play_track("finalBueno", 0.5)
				else:
					var finalMalo = Dialogic.start("final_malo")
					finalMalo.register_character(QUEIXO, puntoQueixo)
					
					$PantallaFinal.texture = load("res://AmorodoJam2026/assets/2D/pantallas/final/final_mal.png")
					$PantallaFinal.visible = true

					Music.play_track("finalMalo", 0.5)
		
		"carta":
			$PantallaFinal.texture = load("res://AmorodoJam2026/assets/2D/pantallas/final/pantalla_final_bien.png")
			$PantallaFinal.visible = true

			var finalBueno = Dialogic.start("carta")
			finalBueno.register_character(QUEIXO, puntoQueixo)

		"finalBueno":
			$PantallaFinal.visible = true

		"cerrar":
			call_deferred("ejecutar_fundido_final")


func ejecutar_fundido_final():
	# Nos aseguramos de que el cuadro negro sea visible y transparente al empezar
	$FundidoNegro.visible = true
	$FundidoNegro.modulate.a = 0.0
	
	# Creamos el Tween para animar el Alpha
	var tween = create_tween()
	
	# Cambiamos el modo del Tween para que ignore si el juego intenta pausarse
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE) 
	
	# Animamos de 0 a 1 en 1.5 segundos
	tween.tween_property($FundidoNegro, "modulate:a", 1.0, 1.5)
	
	# Esperamos a que termine la animación
	await tween.finished
	
	# Volvemos al menú principal y reiniciamos variables 
	ListaRecetas.reset_partida()
	get_tree().change_scene_to_file("res://AmorodoJam2026/scenes/menu_inicio.tscn")
