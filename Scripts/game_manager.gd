extends Node3D
class_name GameManager

var acto = 1
@export var numero_actos = 4
@export var jugador: Jugador
@onready var diablo: MeshInstance3D = $"../Stage/Stage2/Armature/Skeleton3D/Floor"

@onready var ingame_menu: CanvasLayer = $"../IngameMenu"

@onready var opening: VideoStreamPlayer = $"../Videos/Opening"
@onready var ending: VideoStreamPlayer = $"../Videos/Ending"

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

@onready var verde_ui: VBoxContainer = $"../Seleccion/MarginContainer2/VBoxContainer/Verde/Verde"
@onready var amarillo_ui: VBoxContainer = $"../Seleccion/MarginContainer2/VBoxContainer/Verde/Amarillo"
@onready var rosa_ui: VBoxContainer = $"../Seleccion/MarginContainer2/VBoxContainer/Verde/Rosa"
@onready var violeta_ui: VBoxContainer = $"../Seleccion/MarginContainer2/VBoxContainer/Verde/Violeta"
@onready var seleccion_canvas: CanvasLayer = $"../Seleccion"

var ha_elegido = false
var que_color_elegido = "Verde"


func _ready() -> void:
	AudioManager.set_subtitulos_label(get_tree().get_first_node_in_group("subtitulos_label"))
	AudioManager.reproducir_narracion("OPENING", -5)
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

func siguiente_acto() -> void:
	escena_jugador_demonio()
	if acto < numero_actos:
		await Transicion.alpha_a_negro("ACT" + str(acto + 1), "ACT" + str(acto + 1) + "_SUB")
	else:
		await Transicion.alpha_a_negro()
	await gestionar_color_a_perder()
	camera_3d.set_camara_cambio_acto(false)
	acto += 1
	if acto > numero_actos:
		AudioManager.pausar_musica()
	else:
		AudioManager.reproducir_musica("ACT" + str(acto))
		AudioManager.reproducir_narracion("ACT" + str(acto))
	
	if acto > numero_actos:
		if vida_barra:
			if vida_barra is TextureProgressBar:
				vida_barra.tint_progress = Color(1.0, 1.0, 1.0, 1.0)
		await get_tree().create_timer(16).timeout
		ending_activo = true
		await Transicion.alpha_a_negro("The End","THANKS", 6)
		ending.play()
		AudioManager.reproducir_narracion("ENDING", -5)
		Transicion.negro_a_alpha()

func gestionar_color_a_perder() -> void:
	AudioManager.reproducir_musica("SILENCIO")
	
	ingame_menu.hide()
	seleccion_canvas.show()
	await Transicion.negro_a_alpha()
	await elegir_color_a_perder()
	
	ingame_menu.show()
	
	await camera_3d.mover_hacia_jugador()
	
	if jugador is Jugador:
		jugador.set_inmovil(false)
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	enemigos = get_tree().get_nodes_in_group("enemigo")
	if enemigos.size() > 0:
		for enemigo in enemigos:
			if enemigo is Enemigo:
				enemigo.set_inmovil(false)
	spawn_manager.set_puede_spawnear(true)

func _on_opening_finished() -> void:
	await Transicion.alpha_a_negro("ACT" + str(acto), "ACT" + str(acto) + "_SUB")
	ending_activo = false
	opening.hide()
	AudioManager.reproducir_musica("ACT" + str(acto))
	AudioManager.reproducir_narracion("ACT" + str(acto))
	jugador.set_inmovil(false)
	camera_3d.set_camara_cambio_acto(false)
	spawn_manager.set_puede_spawnear(true)
	if camera_3d is Camara:
		camera_3d.mover_hacia_jugador()
	ingame_menu.show()
	await Transicion.negro_a_alpha()

func elegir_color_a_perder() -> void:
	while not ha_elegido:
		await get_tree().create_timer(.2).timeout
		continue
	ha_elegido = false
	
	var color_eliminar = que_color_elegido
	print(color_eliminar)
	jugador.eliminar_color(color_eliminar)
	match color_eliminar:
		"Amarillo":
			amarillo_icono.texture = preload("uid://qsxv7vj2e0of")
			var tween := create_tween()
			tween.tween_property(AmarilloMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_2', Color(0.839, 0.839, 0.839, 1.0), 4)
		"Verde":
			verde_icono.texture = preload("uid://dtp7asoqe82qi")
			var tween := create_tween()
			tween.tween_property(VerdeMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_1', Color(0.784, 0.784, 0.784, 1.0), 4)
		"Rosa":
			rosa_icono.texture = preload("uid://ce5hj36oucsk7")
			var tween := create_tween()
			tween.tween_property(RosaMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_3', Color(0.851, 0.851, 0.851, 1.0), 4)
		"Violeta":
			violeta_icono.texture = preload("uid://bp5umv2pnyyde")
			var tween := create_tween()
			tween.tween_property(VioletaMaterial, 'shader_parameter/metal_color', Vector3(1,1,1), 4)
			var tween2 := create_tween()
			tween2.tween_property(AguaMaterial, 'shader_parameter/color_4', Color(0.796, 0.796, 0.796, 1.0), 4)
	colores_activos.erase(color_eliminar)
	print(colores_activos)
	print("--------------")
	await get_tree().create_timer(6).timeout

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


func _on_verde_pressed() -> void:
	seleccion_canvas.hide()
	que_color_elegido = "Verde"
	ha_elegido = true
	verde_ui.hide()

func _on_amarillo_pressed() -> void:
	seleccion_canvas.hide()
	que_color_elegido = "Amarillo"
	ha_elegido = true
	amarillo_ui.hide()

func _on_rosa_pressed() -> void:
	seleccion_canvas.hide()
	que_color_elegido = "Rosa"
	ha_elegido = true
	rosa_ui.hide()

func _on_violeta_pressed() -> void:
	seleccion_canvas.hide()
	que_color_elegido = "Violeta"
	ha_elegido = true
	violeta_ui.hide()
