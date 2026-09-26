extends Sprite3D

func fade_in(duration: float = 1.0): # Recibe como parámetro la duración que queramos
	# Ponemos la opacidad en 0 al empezar
	modulate.a = 0
	
	# Creamos el Tween, sirve para modificar las curvas de animación
	var tween = create_tween()
	
	# Animamos la propiedad 'modulate:a' hacia 1.0
	tween.tween_property(self, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func fade_out(duration: float = 1.0):
	var tween = create_tween()
	
	# Animamos la propiedad hacia 0.0
	tween.tween_property(self, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
