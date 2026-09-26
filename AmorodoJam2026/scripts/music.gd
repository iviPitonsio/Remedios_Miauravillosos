extends Node

# Señal opcional para avisar cuando se completa una transición
signal musica(new_track_name: String)

# Reproductores necesarios para realizar la transición cruzada (Crossfade)
var reproA: AudioStreamPlayer
var reproB: AudioStreamPlayer
var reproActual: AudioStreamPlayer


# Diccionario para almacenar las pistas. 
@export var tracks: Dictionary = {
	"finalBueno": preload("res://AmorodoJam2026/music/Final_bueno.wav"),
	"finalMalo": preload("res://AmorodoJam2026/music/Final_malo.wav"),
	"inicio": preload("res://AmorodoJam2026/music/Inicio.wav"),
	"juego": preload("res://AmorodoJam2026/music/Juego.wav"),
	"juego2": preload("res://AmorodoJam2026/music/juego_2.wav")
}

func _ready() -> void:
	# Inicializamos dinámicamente ambos reproductores
	reproA = AudioStreamPlayer.new()
	reproB = AudioStreamPlayer.new()
	
	add_child(reproA)
	add_child(reproB)
	
	# Asignar un Bus de Audio
	reproA.bus = "Music"
	reproB.bus = "Music"
	
	# Empezamos con ambos en silencio (-80 dB)
	reproA.volume_db = -80.0
	reproB.volume_db = -80.0
	
	reproActual = reproA

# Función principal para reproducir y hacer la transición de música
func play_track(track_name: String, fade_time: float = 1.5) -> void:
	if not tracks.has(track_name):
		push_warning("MusicManager: La pista '" + track_name + "' no está en el diccionario.")
		return
		
	var objetivo: AudioStream = tracks[track_name]
	
	# Validar que se haya asignado un recurso a la clave
	if objetivo == null:
		push_warning("MusicManager: No se ha asignado ningún archivo de audio para '" + track_name + "'.")
		return
		
	# Si ya está reproduciéndose esta misma música, no hacemos nada para no reiniciarla
	if reproActual.playing and reproActual.stream == objetivo:
		return
		
	# Seleccionamos el reproductor que está libre
	var reproSiguiente: AudioStreamPlayer = reproB if reproActual == reproA else reproA
	
	# Preparamos el reproductor entrante
	reproSiguiente.stream = objetivo
	reproSiguiente.volume_db = -80.0
	reproSiguiente.play()
	
	# Creamos la transición paralela con Tween
	var tween: Tween = create_tween().set_parallel(true)
	
	# Fade Out del reproductor actual
	if reproActual.playing:
		tween.tween_property(reproActual, "volume_db", -80.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# Fade In de la nueva música
	tween.tween_property(reproSiguiente, "volume_db", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Guardamos la referencia para el callback
	var old_player: AudioStreamPlayer = reproActual
	
	# Al finalizar las transiciones anteriores, detenemos la música vieja
	tween.chain().tween_callback(func():
		if old_player.playing:
			old_player.stop()
		musica.emit(track_name)
	)
	
	# Intercambiamos el rol del reproductor activo
	reproActual = reproSiguiente

# Función para apagar toda la música suavemente
func stop_music(fade_time: float = 1.5) -> void:
	if reproActual.playing:
		var tween: Tween = create_tween()
		tween.tween_property(reproActual, "volume_db", -80.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		var reproViejo: AudioStreamPlayer = reproActual
		tween.tween_callback(func():
			reproViejo.stop()
		)
