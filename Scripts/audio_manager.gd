extends Node3D

var reproductores_sfx: Array[AudioStreamPlayer] = []
@onready var SFX: Node3D = $SFX
@onready var musica: AudioStreamPlayer = $Musica
@onready var narracion: AudioStreamPlayer = $Narracion

var time_begin: int
var last_tick: int
var scaled_time: float
var time_delay: float

var subtitulos

var subtitulos_diccionario: Dictionary = {
	"STORY_TEXT_1" = {narracion = "OPENING", inicio = 0.49, final = 2.18},
	"STORY_TEXT_2" = {narracion = "OPENING", inicio = 2.18, final = 5.6},
	"STORY_TEXT_3" = {narracion = "OPENING", inicio = 5.6, final = 10.17},
	"STORY_TEXT_4" = {narracion = "ACT1", inicio = 0.0, final = 3.7},
	"STORY_TEXT_5" = {narracion = "ACT1", inicio = 6.57, final = 11},
	"STORY_TEXT_6" = {narracion = "ACT1", inicio = 13.68, final = 18.86},
	"STORY_TEXT_7" = {narracion = "ACT1", inicio = 21.32, final = 24.87},
	"STORY_TEXT_8" = {narracion = "ACT1", inicio = 27.87, final = 32.24},
	"STORY_TEXT_9" = {narracion = "ACT2", inicio = 0.6, final = 10.41},
	"STORY_TEXT_10" = {narracion = "ACT2", inicio = 20.99, final = 25.25},
	"STORY_TEXT_11" = {narracion = "ACT2", inicio = 32.13, final = 35.77},
	"STORY_TEXT_12" = {narracion = "ACT2", inicio = 35.77, final = 40.60},
	"STORY_TEXT_13" = {narracion = "ACT3", inicio = 0.0, final = 2.24},
	"STORY_TEXT_14" = {narracion = "ACT3", inicio = 4.19, final = 6.13},
	"STORY_TEXT_15" = {narracion = "ACT3", inicio = 9.10, final = 13.20},
	"STORY_TEXT_16" = {narracion = "ACT3", inicio = 16.0, final = 19.67},
	"STORY_TEXT_17" = {narracion = "ACT3", inicio = 21.96, final = 25.85},
	"STORY_TEXT_18" = {narracion = "ACT3", inicio = 32.10, final = 36.04},
	"STORY_TEXT_19" = {narracion = "ACT3", inicio = 42.56, final = 46.86},
	"STORY_TEXT_20" = {narracion = "ACT3", inicio = 55.36, final = 60.75},
	"STORY_TEXT_21" = {narracion = "ACT3", inicio = 67.44, final = 78.61},
	"STORY_TEXT_22" = {narracion = "ACT4", inicio = 0.0, final = 6.24},
	"STORY_TEXT_23" = {narracion = "ACT4", inicio = 13.31, final = 19.29},
	"STORY_TEXT_24" = {narracion = "ACT4", inicio = 37.89, final = 40.28},
	"STORY_TEXT_25" = {narracion = "ACT4", inicio = 43.20, final = 47.65},
	"STORY_TEXT_26" = {narracion = "ACT4", inicio = 50.44, final = 54.02},
	"STORY_TEXT_27" = {narracion = "ACT4", inicio = 54.02, final = 57.05},
	"STORY_TEXT_28" = {narracion = "ACT4", inicio = 61.73, final = 69.17},
	"STORY_TEXT_29" = {narracion = "ACT4", inicio = 71.61, final = 79.86},
	"STORY_TEXT_30" = {narracion = "ENDING", inicio = 0.29, final = 2.0},
	"STORY_TEXT_31" = {narracion = "ENDING", inicio = 2.0, final = 5.72},
	"STORY_TEXT_32" = {narracion = "ENDING", inicio = 5.72, final = 9.39},
	"STORY_TEXT_33" = {narracion = "ENDING", inicio = 9.39, final = 13.32},
	"STORY_TEXT_34" = {narracion = "ENDING", inicio = 13.32, final = 16.25},
	"STORY_TEXT_35" = {narracion = "ENDING", inicio = 16.25, final = 18.25},
	"STORY_TEXT_36" = {narracion = "ENDING", inicio = 18.25, final = 20.04},
}


func _process(_delta: float) -> void:
	if narracion.playing:
		var audio = narracion.stream
		var audio_path = audio.resource_path
		var segundo_actual = patched_get_playback_position()
		
		for i in subtitulos_diccionario.size():
			var id = int(i) + 1
			var clave_valor = "STORY_TEXT_" + str(id)
			var narracion_valor = subtitulos_diccionario["STORY_TEXT_" + str(id)]["narracion"]
			var inicio_valor = subtitulos_diccionario["STORY_TEXT_" + str(id)]["inicio"]
			var final_valor = subtitulos_diccionario["STORY_TEXT_" + str(id)]["final"]
			
			if audio_path == ("res://Audio/Narraciones/" + narracion_valor + ".wav"):
				if (segundo_actual <= final_valor and segundo_actual >= inicio_valor):
					if subtitulos.text != clave_valor:
						subtitulos.text = clave_valor
					break
				else:
					subtitulos.text = ""
	else:
		if subtitulos and subtitulos.text != "":
			subtitulos.text = ""

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
	time_begin = Time.get_ticks_usec()
	last_tick = time_begin
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	scaled_time = 0.0
	narracion.play()

func pausar_musica():
	musica.stop()

func pausar_narracion():
	narracion.stop()

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

func set_subtitulos_label(label: Label) ->void:
	subtitulos = label

func patched_get_playback_position() -> float:
	var now := Time.get_ticks_usec()
	var real_delta = (now - last_tick) / 1000000.0
	last_tick = now
	scaled_time += real_delta
	# Compensate for latency.
	var returned_time = scaled_time - time_delay
	return max(0, returned_time)
