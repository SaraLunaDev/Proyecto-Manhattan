extends CharacterBody3D
class_name Enemigo

# Variables
# -----------------------------------------------
@export var velocidad = 0.75
@export var aceleracion = 160.0
@export var retroceso = 6.0
@export_enum("Amarillo", "Rosa", "Verde", "Violeta") var color: int
@onready var jugador = get_tree().get_first_node_in_group("jugador")
@export var hitbox: Area3D
@onready var agent: NavigationAgent3D = $Agente
@export var vida = 4.0
@export var daño = 1.0
@export var punto_daño: Marker3D
@export var punto_daño_label: Marker3D
@export var daño_label: PackedScene
var siendo_apuntado = false
var distancia_a_jugador
var recibiendo_daño = false
var tipo_daño = 0
@export var animaciones: AnimationTree
var activo = false
var muriendo = false
@export var es_rango: bool = false
@onready var colision: CollisionShape3D = $Colision
@export var bala: PackedScene
@export var numero_balas = 10.0
@export var punto_bala: Node3D
@export var punto_bala_marker: Marker3D
@onready var daño_particula: GPUParticles3D = $Daño

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	distancia_a_jugador = (jugador.global_position - global_position).length()
	# Rotar el enemigo hacia donde va su direccion
	if muriendo or jugador.get_muerto():
		return
	
	look_at(jugador.global_position, Vector3.UP, true)
	# Establecer direccion destino del NavAgent
	agent.target_position = jugador.global_transform.origin
	
	# Obtener direccion dentro de los limites del NavRegion
	var destino = agent.get_next_path_position()
	var posicion = global_transform.origin
	var direccion
	
	if recibiendo_daño and  tipo_daño == 1:
		direccion = (destino - posicion).normalized() * retroceso
		direccion.y = 0
		if activo:
			# Movimiento hacia direccion con aceleracion
			velocity = velocity.move_toward(direccion * -1, aceleracion * delta)
	else:
		direccion = (destino - posicion).normalized() * velocidad
		direccion.y = 0
		if activo:
			# Movimiento hacia direccion con aceleracion
			velocity = velocity.move_toward(direccion, aceleracion * delta)
	
	move_and_slide()
	
	# Detectar colision con jugador
	if hitbox.get_overlapping_bodies().size() > 0:
		var jugador_objetivo = hitbox.get_overlapping_bodies()[0]
		if jugador_objetivo is Jugador:
			if jugador_objetivo.get_daño_cd_timer() == 0.0:
				animaciones.set("parameters/conditions/atacando", true)
				await get_tree().create_timer(.2).timeout
				animaciones.set("parameters/conditions/atacando", false)
				jugador_objetivo.recibir_daño(daño)

# Recibir daño
# -----------------------------------------------
func recibir_daño(daño_recibido, tipo: int) -> void:
	if vida == 0.0:
		return
	tipo_daño = tipo
	recibiendo_daño = true
	var nuevo_daño_label = daño_label.instantiate()
	nuevo_daño_label.transform.origin = punto_daño_label.global_position
	get_tree().root.add_child(nuevo_daño_label)
	nuevo_daño_label.mostrar_daño(daño_recibido)
	vida -= daño_recibido
	
	if not tipo_daño == 0:
		daño_particula.emitting = true
		animaciones.set("parameters/conditions/golpeado", true)
		await get_tree().create_timer(.2).timeout
		animaciones.set("parameters/conditions/golpeado", false)
	if tipo_daño == 2:
		daño_particula.emitting = true
		animaciones.set("parameters/conditions/golpeado", true)
		await get_tree().create_timer(.2).timeout
		animaciones.set("parameters/conditions/golpeado", false)
	
	recibiendo_daño = false
	
	if vida <= 0:
		vida = 0.0
		morir()

func morir() -> void:
	hitbox.monitorable = false
	hitbox.monitoring = false
	colision.disabled = true
	muriendo = true
	colision.disabled = false
	animaciones.set("parameters/conditions/muerto", true)

# Getters y Setters
# -----------------------------------------------
func get_daño() -> int:
	return daño

func get_punto_daño() -> Marker3D:
	return punto_daño

func set_siendo_apuntado(valor: bool) -> void:
	siendo_apuntado = valor

func get_siendo_apuntado() -> bool:
	return siendo_apuntado

func get_vida() -> float:
	return vida

func get_muriendo() -> bool:
	return muriendo

func get_distancia_a_jugador() -> float:
	return distancia_a_jugador

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Death":
			queue_free()
		"Spawn":
			activo = true

func _on_disparo_cd_timeout() -> void:
	if es_rango:
		if bala and punto_bala and punto_bala_marker and not recibiendo_daño:
			var paso = 360 / numero_balas
			var pasos = paso
			animaciones.set("parameters/conditions/atacando", true)
			await get_tree().create_timer(.5).timeout
			animaciones.set("parameters/conditions/atacando", false)
			for numero_bala in numero_balas:
				var nueva_bala = bala.instantiate()
				nueva_bala.transform.origin = punto_bala_marker.global_position
				get_tree().root.add_child(nueva_bala)
				punto_bala.global_rotate(Vector3.UP, deg_to_rad(pasos))
				nueva_bala.set_posicion(global_position)
				pasos += paso

func get_color() -> int:
	return color
