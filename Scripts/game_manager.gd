extends Node3D
class_name GameManager

var acto = 1
@export var numero_actos = 4
@export var jugador: Jugador

@onready var opening: VideoStreamPlayer = $"../Shaders/Opening"
@onready var ending: VideoStreamPlayer = $"../Shaders/Ending"

@onready var animaciones: AnimationPlayer = $"../Shaders/Animaciones"
@onready var spawn_manager: SpawnManager = $"../SpawnManager"
var opening_activo = true
var ending_activo = false
@onready var camera_3d: Camara = $"../Camera3D"
var colores_activos = [
	"Amarillo",
	"Rosa",
	"Verde",
	"Violeta"
	]

func _ready() -> void:
	AudioManager.reproducir_musica("SILENCIO")
	jugador.set_inmovil(true)

func siguiente_acto() -> void:
	await gestionar_color_a_perder()
	acto += 1
	if acto > numero_actos:
		AudioManager.pausar_musica()
	else:
		AudioManager.reproducir_musica("ACT" + str(acto))
	
	if acto > numero_actos:
		await get_tree().create_timer(10).timeout
		ending_activo = true
		animaciones.play("ocultar")

func gestionar_color_a_perder() -> void:
	AudioManager.reproducir_musica("SILENCIO")
	spawn_manager.set_puede_spawnear(false)
	if jugador is Jugador:
		jugador.set_inmovil(true)
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	if enemigos.size() > 0:
		for enemigo in enemigos:
			if enemigo is Enemigo:
				enemigo.morir()
	
	await elegir_color_a_perder()
	
	if jugador is Jugador:
		jugador.set_inmovil(false)
	enemigos = get_tree().get_nodes_in_group("enemigo")
	if enemigos.size() > 0:
		for enemigo in enemigos:
			if enemigo is Enemigo:
				enemigo.set_inmovil(false)
	spawn_manager.set_puede_spawnear(true)

func _on_opening_finished() -> void:
	animaciones.play("ocultar")

func _on_animaciones_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"ocultar":
			if opening_activo:
				opening_activo = false
				opening.hide()
				AudioManager.reproducir_musica("ACT" + str(acto))
				animaciones.play("mostrar")
				return
			if ending_activo:
				animaciones.play("mostrar")
				ending.play()
			else:
				get_tree().reload_current_scene()
		"mostrar":
			if not opening_activo:
				jugador.set_inmovil(false)
				spawn_manager.set_puede_spawnear(true)
				if camera_3d is Camara:
					camera_3d.mover_hacia_jugador()
				return

func elegir_color_a_perder() -> void:
	var color_eliminar = colores_activos.get(randi_range(0,colores_activos.size() -1))
	print(color_eliminar)
	jugador.eliminar_color(color_eliminar)
	colores_activos.erase(color_eliminar)
	print(colores_activos)
	print("--------------")
	await get_tree().create_timer(6).timeout

func get_colores_activos() -> Array:
	return colores_activos
