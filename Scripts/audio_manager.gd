extends Node3D

var reproductores_sfx: Array[AudioStreamPlayer] = []
@onready var SFX: Node3D = $SFX
@onready var musica: AudioStreamPlayer = $Musica
@onready var narracion: AudioStreamPlayer = $Narracion

func reproducir_sfx(nombre: String, volumen: float = 1.0, pitch: float = 1.0, tipo: String = "Jugador", formato: String = ".wav") -> void:
	var audio = load("res://Audio/SoundEffects/" + tipo + "/" + nombre + formato)
	
	var reproductor: AudioStreamPlayer = pillar_siguiente_reproductor()
	
	reproductor.stream = audio
	reproductor.volume_db = volumen
	reproductor.pitch_scale = pitch
	reproductor.bus = "SFX"
	reproductor.play()

func reproducir_musica(nombre: String, volumen: float = 1.0, pitch: float = 1.0) -> void:
	var audio = load("res://Audio/Music/" + nombre + ".mp3")
	musica.stream = audio
	musica.volume_db = volumen
	musica.pitch_scale = pitch
	musica.bus = "Musica"
	musica.play()

func reproducir_narracion(nombre: String, volumen: float = 1.0, pitch: float = 1.0) -> void:
	var audio = load("res://Audio/Narraciones/" + nombre + ".wav")
	narracion.stream = audio
	narracion.volume_db = volumen
	narracion.pitch_scale = pitch
	narracion.bus = "Narracion"
	narracion.play()

func pausar_musica():
	musica.stop()

func pillar_siguiente_reproductor() -> AudioStreamPlayer:
	for reproductor: AudioStreamPlayer in reproductores_sfx:
		if not reproductor.playing:
			return reproductor
	
	var reproductor: AudioStreamPlayer = AudioStreamPlayer.new()
	SFX.add_child(reproductor)
	reproductor.finished.connect(on_reproductor_finished.bind(reproductor))
	return reproductor

func on_reproductor_finished(reproductor: AudioStreamPlayer) -> void:
	reproductor.queue_free()

func _on_musica_finished() -> void:
	var gamemanager = get_tree().get_first_node_in_group("gamemanager")
	if gamemanager is GameManager:
		gamemanager.siguiente_acto()
