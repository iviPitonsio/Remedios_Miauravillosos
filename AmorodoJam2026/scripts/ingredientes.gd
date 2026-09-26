extends RigidBody3D

@export var id: int = 1 # Variable que determina el número de cada ingrediente
@onready var camara = get_viewport().get_camera_3d()
@onready var alturaMesa = global_position.y # Guardamos la altura original

var arrastrando = false # Booleana que determina si estamos agarrando un objeto

# Guardamos la posición y rotación originales del objeto
var posicionInicial: Vector3
var rotacionInicial: Vector3

func _ready():
	# Guardamos el punto exacto donde empezó el ingrediente
	posicionInicial = global_position
	rotacionInicial = global_rotation

func _input_event(_camera, event, _pos, _normal, _shape):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			arrastrando = true
			freeze = true # Congelamos las físicas para evitar problemas
			freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		else:
			# Al levantar el dedo, desactivamos el arrastre y activamos el regreso
			if arrastrando:
				arrastrando = false
				regresar()

func _process(_delta):
	if arrastrando:
		var posRaton = get_viewport().get_mouse_position()
		
		# Creamos un plano que coincide con la superficie de la mesa
		var planoMesa = Plane(Vector3.UP, alturaMesa)
		
		# Lanzamos un rayo desde la cámara hacia el ratón
		var rayoOrigen = camara.project_ray_origin(posRaton)
		var rayoDireccion = camara.project_ray_normal(posRaton)
		
		# Calculamos dónde corta ese rayo con el plano de la mesa
		var puntoImpacto = planoMesa.intersects_ray(rayoOrigen, rayoDireccion)
		
		if puntoImpacto:
			# Aplicamos la posición pero mantenemos la altura exacta para que no atraviese la mesa
			global_position = Vector3(puntoImpacto.x, alturaMesa + 0.2, puntoImpacto.z)
		

func regresar():
	# Limpiamos cualquier fuerza o velocidad que tenga el ingrediente para que no se vuelva loco
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Congelamos temporalmente las físicas para que el motor nos deje moverlo a mano con el Tween
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	# Creamos la animación de regreso
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Movemos posición y rotación a la vez en 0.5 segundos
	tween.parallel().tween_property(self, "global_position", posicionInicial, 0.5)
	tween.parallel().tween_property(self, "global_rotation", rotacionInicial, 0.5)
	
	# Cuando el Tween termine de colocar el objeto en su sitio, descongelamos las físicas
	tween.finished.connect(descongelar) # si no meto en una función el freeze = false, a Godot le da un brote psicótico xd
	
func descongelar():
	# Devolvemos el objeto al estado físico normal
	freeze = false
