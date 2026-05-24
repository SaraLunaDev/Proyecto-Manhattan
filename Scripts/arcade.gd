extends Node3D
class_name Arcade

var acto = 1
@export var numero_actos = 4
@export var jugador: Jugador
@onready var diablo: MeshInstance3D = $"../Stage/Stage2/Armature/Skeleton3D/Floor"

@onready var ingame_menu: CanvasLayer = $"../IngameMenu"

@onready var pos_jugador: Marker3D = $"../PosJugador"
@onready var pos_camara: Marker3D = $"../PosCamara"
@onready var pos_camara_mirar: Marker3D = $"../PosCamaraMirar"

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
const VerdeMaterial = preload("uid://3hvgrqv00cq3")
const RosaMaterial = preload("uid://ctaqk57hbgkrs")
const VioletaMaterial = preload("uid://bmc1f4u4yiru7")
const AmarilloMaterial = preload("uid://b658hxgiehj5g")
const LilaMaterial = preload("uid://c1ar0spnk5ljl")
const AguaMaterial = preload("uid://b03xda4iyk7w1")

const VerdeMaterial_BASE = preload("uid://cs1exvdpf0ds0")
const RosaMaterial_BASE = preload("uid://dfv2rou06ufq7")
const LilaMaterial_BASE = preload("uid://b7vebl72fki7i")
const VioletaMaterial_BASE = preload("uid://bt4fjj05jtktf")
const AguaMaterial_BASE = preload("uid://bmr2ypjxjpkba")
const AmarilloMaterial_BASE = preload("uid://chuqgif6ghtlx")

@onready var verde_icono: TextureRect = $"../IngameMenu/MarginContainer/HBoxContainer/VBoxContainer/Verde"
@onready var rosa_icono: TextureRect = $"../IngameMenu/MarginContainer/HBoxContainer/VBoxContainer/Rosa"
@onready var amarillo_icono: TextureRect = $"../IngameMenu/MarginContainer/HBoxContainer/VBoxContainer/Amarillo"
@onready var violeta_icono: TextureRect = $"../IngameMenu/MarginContainer/HBoxContainer/VBoxContainer/Violeta"
@onready var vida_barra: TextureProgressBar = get_tree().get_first_node_in_group("vida_jugador_barra")

var ha_elegido = false
var que_color_elegido = "Verde"

const START_SCENE = preload("uid://gx5j5xd2wvao")


@onready var timer_label: Label = $"../IngameMenu2/MarginContainer/VBoxContainer/Label"
var tiempo_pasado = 0
@onready var hits_enemigos_label: Label = $"../IngameMenu2/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/MarginContainer/Label"
var hits_enemigos = 0
@onready var hits_jugador_label: Label = $"../IngameMenu2/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MarginContainer/Label"
var hits_jugador = 0


func _ready() -> void:
	AudioManager.set_subtitulos_label(get_tree().get_first_node_in_group("subtitulos_label"))
	AudioManager.reproducir_musica("SILENCIO")
	Transicion.negro_a_alpha()
	VerdeMaterial.set_shader_parameter("metal_color", VerdeMaterial_BASE.get_shader_parameter("metal_color"))
	RosaMaterial.set_shader_parameter("metal_color", RosaMaterial_BASE.get_shader_parameter("metal_color"))
	VioletaMaterial.set_shader_parameter("metal_color", VioletaMaterial_BASE.get_shader_parameter("metal_color"))
	AmarilloMaterial.set_shader_parameter("metal_color", AmarilloMaterial_BASE.get_shader_parameter("metal_color"))
	LilaMaterial.set_shader_parameter("metal_color", LilaMaterial_BASE.get_shader_parameter("metal_color"))
	AguaMaterial.set_shader_parameter("color_1", AguaMaterial_BASE.get_shader_parameter("color_1"))
	AguaMaterial.set_shader_parameter("color_2", AguaMaterial_BASE.get_shader_parameter("color_2"))
	AguaMaterial.set_shader_parameter("color_3", AguaMaterial_BASE.get_shader_parameter("color_3"))
	AguaMaterial.set_shader_parameter("color_4", AguaMaterial_BASE.get_shader_parameter("color_4"))
	
	camera_3d.set_camara_cambio_acto(true)
	jugador.set_desajuste_camara()
	jugador.transform.origin = pos_jugador.global_position
	jugador.rotation_degrees = Vector3(0,180,0)
	
	camera_3d.transform.origin = pos_camara.global_position
	camera_3d.look_at(jugador.get_desajuste_camara())
	jugador.set_inmovil(true)
	
	AudioManager.reproducir_musica("ARCADE",1.0,1.0,".wav")
	jugador.set_inmovil(false)
	camera_3d.set_camara_cambio_acto(false)
	spawn_manager.set_puede_spawnear(true)
	if camera_3d is Camara:
		camera_3d.mover_hacia_jugador()
	ingame_menu.show()
	elegir_dos_habilidades()

func siguiente_acto() -> void:
	pass

func gestionar_color_a_perder() -> void:
	pass

func _on_opening_finished() -> void:
	pass

func elegir_color_a_perder() -> void:
	pass

func get_colores_activos() -> Array:
	return colores_activos

func escena_jugador_demonio() -> void:
	await get_tree().create_timer(1).timeout
	camera_3d.set_camara_cambio_acto(true)
	jugador.set_desajuste_camara()
	jugador.transform.origin = pos_jugador.global_position
	jugador.rotation_degrees = Vector3(0,180,0)
	
	camera_3d.transform.origin = pos_camara.global_position
	camera_3d.look_at(jugador.get_desajuste_camara())
	
	spawn_manager.set_puede_spawnear(false)
	if jugador is Jugador:
		jugador.set_inmovil(true)
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	if enemigos.size() > 0:
		for enemigo in enemigos:
			if enemigo is Enemigo:
				enemigo.morir()
	#if acto >= 3:
		#diablo.show()

func añadir_hit_jugador(value: int) -> void:
	hits_jugador += value
	hits_jugador_label.text = str(hits_jugador)

func añadir_muerte_enemigo(value: int) -> void:
	hits_enemigos += value
	hits_enemigos_label.text = str(hits_enemigos)

func _on_timer_timeout() -> void:
	tiempo_pasado += 1
	timer_label.text = get_tiempo_formateado(tiempo_pasado)

func get_tiempo_formateado(time: int) -> String:
	var minutes: int = floori(time / 60.0)
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]

func _on_salir_pressed() -> void:
	await Transicion.alpha_a_negro()
	get_tree().change_scene_to_file("res://Scenes/startScene.tscn")

func elegir_dos_habilidades() -> void:
	amarillo_icono.texture = preload("res://Textures/UI/UI_Yellow.png")
	verde_icono.texture = preload("res://Textures/UI/UI_Green.png")
	rosa_icono.texture = preload("res://Textures/UI/UI_Pink.png")
	violeta_icono.texture = preload("res://Textures/UI/UI_Violet.png")
	
	var tween_amarillo := create_tween()
	tween_amarillo.tween_property(AmarilloMaterial, 'shader_parameter/metal_color', AmarilloMaterial_BASE.get_shader_parameter("metal_color"), 4)
	var tween2_amarillo := create_tween()
	tween2_amarillo.tween_property(AguaMaterial, 'shader_parameter/color_2', AguaMaterial_BASE.get_shader_parameter("color_2"), 4)
	
	var tween_verde := create_tween()
	tween_verde.tween_property(VerdeMaterial, 'shader_parameter/metal_color', VerdeMaterial_BASE.get_shader_parameter("metal_color"), 4)
	var tween2_verde := create_tween()
	tween2_verde.tween_property(AguaMaterial, 'shader_parameter/color_1', AguaMaterial_BASE.get_shader_parameter("color_1"), 4)
	
	var tween_rosa := create_tween()
	tween_rosa.tween_property(RosaMaterial, 'shader_parameter/metal_color', RosaMaterial_BASE.get_shader_parameter("metal_color"), 4)
	var tween2_rosa := create_tween()
	tween2_rosa.tween_property(AguaMaterial, 'shader_parameter/color_3', AguaMaterial_BASE.get_shader_parameter("color_3"), 4)
	
	var tween_violeta := create_tween()
	tween_violeta.tween_property(VioletaMaterial, 'shader_parameter/metal_color',VioletaMaterial_BASE.get_shader_parameter("metal_color"), 4)
	var tween2_violeta := create_tween()
	tween2_violeta.tween_property(AguaMaterial, 'shader_parameter/color_4', AguaMaterial_BASE.get_shader_parameter("color_4"), 4)
	
	await get_tree().create_timer(4).timeout
	
	var random = randi_range(1,4)
	var random2 = randi_range(1,4)
	while random == random2:
		await get_tree().create_timer(.1).timeout
		random2 = randi_range(1,4)
		continue
	jugador.restaurar_color()
	match random:
		1:
			jugador.eliminar_color("Amarillo")
		2:
			jugador.eliminar_color("Verde")
		3:
			jugador.eliminar_color("Rosa")
		4:
			jugador.eliminar_color("Violeta")
	match random2:
		1:
			jugador.eliminar_color("Amarillo")
		2:
			jugador.eliminar_color("Verde")
		3:
			jugador.eliminar_color("Rosa")
		4:
			jugador.eliminar_color("Violeta")
	
	match random:
		1:
			amarillo_icono.texture = preload("uid://qsxv7vj2e0of")
			var tween := create_tween()
			tween.tween_property(AmarilloMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_2', Color(0.839, 0.839, 0.839, 1.0), 4)
		2:
			verde_icono.texture = preload("uid://dtp7asoqe82qi")
			var tween := create_tween()
			tween.tween_property(VerdeMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_1', Color(0.784, 0.784, 0.784, 1.0), 4)
		3:
			rosa_icono.texture = preload("uid://ce5hj36oucsk7")
			var tween := create_tween()
			tween.tween_property(RosaMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_3', Color(0.851, 0.851, 0.851, 1.0), 4)
		4:
			violeta_icono.texture = preload("uid://bp5umv2pnyyde")
			var tween := create_tween()
			tween.tween_property(VioletaMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_4', Color(0.796, 0.796, 0.796, 1.0), 4)
	
	match random2:
		1:
			amarillo_icono.texture = preload("uid://qsxv7vj2e0of")
			var tween := create_tween()
			tween.tween_property(AmarilloMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_2', Color(0.839, 0.839, 0.839, 1.0), 4)
		2:
			verde_icono.texture = preload("uid://dtp7asoqe82qi")
			var tween := create_tween()
			tween.tween_property(VerdeMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_1', Color(0.784, 0.784, 0.784, 1.0), 4)
		3:
			rosa_icono.texture = preload("uid://ce5hj36oucsk7")
			var tween := create_tween()
			tween.tween_property(RosaMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_3', Color(0.851, 0.851, 0.851, 1.0), 4)
		4:
			violeta_icono.texture = preload("uid://bp5umv2pnyyde")
			var tween := create_tween()
			tween.tween_property(VioletaMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_4', Color(0.796, 0.796, 0.796, 1.0), 4)


func _on_timer_2_timeout() -> void:
	elegir_dos_habilidades()
