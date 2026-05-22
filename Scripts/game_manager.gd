extends Node3D
class_name GameManager

var acto = 1
@export var numero_actos = 4
@export var jugador: Jugador

func _ready() -> void:
	AudioManager.reproducir_musica("ACT" + str(acto))

func siguiente_acto() -> void:
	await gestionar_color_a_perder()
	acto += 1
	if acto > numero_actos:
		AudioManager.pausar_musica()
	else:
		AudioManager.reproducir_musica("ACT" + str(acto))

func gestionar_color_a_perder() -> void:
	AudioManager.reproducir_musica("SILENCIO")
	if jugador is Jugador:
		jugador.set_inmovil(true)
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	for enemigo in enemigos:
		if enemigo is Enemigo:
			enemigo.set_inmovil(true)
	
	await get_tree().create_timer(10).timeout
	
	if jugador is Jugador:
		jugador.set_inmovil(false)
	enemigos = get_tree().get_nodes_in_group("enemigo")
	for enemigo in enemigos:
		if enemigo is Enemigo:
			enemigo.set_inmovil(false)
