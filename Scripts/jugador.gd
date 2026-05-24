extends CharacterBody3D
class_name Jugador

# Variables
# -----------------------------------------------
@export_category("Stats")
@export var vida = 10.0
@export var velocidad = 2.0
@export var aceleracion = 40.0
@export var hitbox: Area3D
@export var daño_cd: Timer
@export var agent: NavigationAgent3D
var esta_muriendose: bool = false
var enemigo_objetivo: Enemigo
var ultima_animacion: StringName
var cam: Camera3D
@onready var daño_particula: GPUParticles3D = $ExplosionEscudo
var inmovil = false
@export var desajuste_camara: Marker3D

# -----------------------------------------------
@export_category("Espada")
@export var puede_espadear: bool = false
@export var daño_espada = 2.0
@export var espada_cd: Timer
@export var hitbox_espada: Area3D
@export var hitbox_espadas_cercanos: Area3D
@export var espada_animacion: AnimationPlayer
@export var animaciones: AnimationTree
var esta_espadeando: bool = false
# -----------------------------------------------
@export_category("Escudo")
@export var puede_escudo: bool = false
var escudo = 4.0
@export var escudo_max = 4.0
@export var escudo_forma: MeshInstance3D
@export var escudo_cd: Timer
@export var daño_explosion = 4.0
@export var escudo_posicion: Node3D
const material_escudo = preload("uid://b75barw2orci0")
@export var animacion_escudo: AnimationPlayer
# -----------------------------------------------
@export_category("Proyectil")
@export var puede_disparar: bool = false
@export var proyectil: PackedScene
@export var punto_proyectil: Marker3D
@export var hitbox_proyectil: Area3D
@export var nodo_torreta: Node3D
# -----------------------------------------------
@export_category("Rayo")
@export var puede_rayo: bool = false
@export var daño_rayo = 1.0
@export var rayo: PackedScene
# -----------------------------------------------
@onready var explosion_escudo: GPUParticles3D = $ExplosionEscudo
@onready var explosion_escudo_2: GPUParticles3D = $ExplosionEscudo2
@onready var explosion_escudo_3: GPUParticles3D = $ExplosionEscudo3
var game_manager
@onready var vida_barra: TextureProgressBar = get_tree().get_first_node_in_group("vida_jugador_barra")

# Ready
# -----------------------------------------------
func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("gamemanager")
	ejecutar_animacion("quieto")
	# Resetear escudo
	material_escudo.set_shader_parameter("ray_sharpness", 0.1)
	material_escudo.set_shader_parameter("vertical_speed", 1.5)
	#Obtener camara
	cam = get_viewport().get_camera_3d()
	if puede_escudo:
		# Enseñar el escudo si lo tiene
		escudo_forma.show()
	else:
		# Ocultarlo si no
		escudo_forma.hide()
	# Reset vida de escudo
	escudo = escudo_max

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	if inmovil:
		ejecutar_animacion("quieto")
		return
	# No hacer nada mientras muere
	if esta_muriendose:
		return
	# Obtener el Input de direccion
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direccion = (Vector3(input.x, 0, input.y)).normalized()
	# Controlar accion por direccion
	if direccion:
		ejecutar_animacion("andando")
		# Movimiento hacia direccion con aceleracion
		velocity.x = move_toward(velocity.x, direccion.x * velocidad, aceleracion * delta)
		velocity.z = move_toward(velocity.z, direccion.z * velocidad, aceleracion * delta)
	else:
		ejecutar_animacion("quieto")
		# Pausar movimiento con deceleracion
		velocity.x = move_toward(velocity.x, 0, aceleracion * delta)
		velocity.z = move_toward(velocity.z, 0, aceleracion * delta)
	# Rotar el jugador hacia donde va su direccion
	if direccion.length() > 0:
		# Solo si no esta espadeando
		if not esta_espadeando:
			look_at(global_position + direccion, Vector3.UP, true)
	# Aplicar el movimiento
	move_and_slide()
	# Espadear
	espadear()
	# Gestion de giro de torreta
	girar_torreta()
	# Gestion de giro de escudo
	girar_escudo()

# Girar escudo hacia camara
# -----------------------------------------------
func girar_escudo():
	if cam:
		escudo_posicion.look_at(Vector3(cam.global_position.x, 0, cam.global_position.z), Vector3.UP, false)

# Girar torreta hacia enemigo
# -----------------------------------------------
func girar_torreta():
	if enemigo_objetivo:
		# Si hay enemigo apuntarle a el
		nodo_torreta.look_at(enemigo_objetivo.global_position, Vector3.UP, true)
	else:
		# Si no, a la camara
		if cam:
			nodo_torreta.look_at(Vector3(cam.global_position.x, 0, cam.global_position.z), Vector3.UP, false)

# Gestionar habilidad con espada
# -----------------------------------------------
func espadear():
	if puede_espadear and not inmovil:
		# Detectar enemigos en hitbox espada
		var enemigos_rango_espada = hitbox_espada.get_overlapping_bodies()
		# Detectar enemigos en hitbox del rango de daño de la espada
		var enemigos_rango_espada_cercanos = hitbox_espadas_cercanos.get_overlapping_bodies()
		# Si hay enemigos en rango
		if enemigos_rango_espada.size() > 0:
			# Y el CD esta apagao
			if espada_cd.time_left <= 0:
				# Empezar a espadear
				esta_espadeando = true
				AudioManager.reproducir_sfx("SWORD", -8, 1.4)
				espada_animacion.play("girar_espada")
				espada_cd.start()
				ejecutar_animacion("atacando")
				# Pequeña pausa para que la animacion enlace con el daño
				await get_tree().create_timer(.5).timeout
				for enemigo_rango_espada in enemigos_rango_espada_cercanos:
					if enemigo_rango_espada:
						# Aplicar el daño a todos los enemigos
						enemigo_rango_espada.recibir_daño(daño_espada, 1)
				await get_tree().create_timer(.6).timeout
				# Parar de espadear
				esta_espadeando = false

# Gestion de daño recibido
# -----------------------------------------------
func recibir_daño(daño_recibido) -> void:
	if inmovil:
		return
	# Si no tiene vida no recibir daño
	if vida <= 0.0:
		return
	# Si el daño_recibido esta en CD no hacer nada
	if daño_cd.time_left > 0:
		return
	# Emitir particula de daño
	daño_particula.emitting = true
	AudioManager.reproducir_sfx("HIT")
	# Si al escudo le queda vida y tiene la habilidad
	if escudo > 0 and puede_escudo and not inmovil:
		# Gestionar el daño en el escudo
		escudo -= daño_recibido
		animacion_escudo.stop()
		# Visualizar la vida del escudo restante con shader
		animacion_escudo.play("dañar_escudo")
		material_escudo.set_shader_parameter("ray_sharpness", 0.175 * ((escudo_max - escudo)))
		material_escudo.set_shader_parameter("vertical_speed", 1.25 * ((escudo_max - escudo)))
		# Si me quedo sin escudo
		if escudo <= 0:
			escudo = 0.0
			# Aplicar daño del escudo
			explotar_escudo()
	else:
		# Si no tiene escudo, restar la vida al Jugador
		vida -= daño_recibido
		if vida_barra:
			if vida_barra is TextureProgressBar:
				vida_barra.value = vida
		espada_cd.stop()
		espada_cd.start()
		# Si se queda sin vida, morir
		if vida <= 0:
			vida = 0.0
			morir()
	
	cam.aplicar_temblor()
	# Comenzar el CD
	daño_cd.start()

# Gestion de muerte
# -----------------------------------------------
func morir() -> void:
	esta_muriendose = true
	AudioManager.reproducir_sfx("DEATH")
	# Daño en area cuando muera
	explotar_escudo()
	ejecutar_animacion("muerto")
	AudioManager.pausar_narracion()
	await get_tree().create_timer(6).timeout
	# Tras un tiempo resetear la escena
	await Transicion.alpha_a_negro()
	get_tree().reload_current_scene()

# Gestion de disparo de proyectil
# -----------------------------------------------
func disparar_proyectil() -> void:
	if puede_disparar and not inmovil:
		AudioManager.reproducir_sfx("PROJECTILE", -5, 6)
		var nuevo_proyectil = proyectil.instantiate()
		nuevo_proyectil.transform.origin = punto_proyectil.global_position
		get_tree().root.add_child(nuevo_proyectil)
		nuevo_proyectil.set_enemigo_objetivo(enemigo_objetivo)

# Gestion si se dispara el proyectil
# -----------------------------------------------
func _on_proyectil_cd_timeout() -> void:
	if hitbox_proyectil.get_overlapping_bodies().size() > 0:
		var enemigo_cercano = null
		for enemigo_proyectil in hitbox_proyectil.get_overlapping_bodies():
			if not enemigo_cercano:
				enemigo_cercano = enemigo_proyectil
			if enemigo_cercano.get_distancia_a_jugador() > enemigo_proyectil.get_distancia_a_jugador():
				enemigo_cercano = enemigo_proyectil
		var es_apuntado = false
		if not enemigo_cercano.get_siendo_apuntado():
			es_apuntado = true
			enemigo_objetivo = enemigo_cercano
			if es_apuntado:
				var vida_enemigo = enemigo_objetivo.get_vida()
				var proyectiles = get_tree().get_nodes_in_group("proyectil")
				var daño_total = 0.0
				for proyectil_activo in proyectiles:
					var daño_proyectil = proyectil_activo.get_daño()
					daño_total += daño_proyectil
				if not daño_total >= vida_enemigo:
					disparar_proyectil()
			else:
				disparar_proyectil()

# Gestion de animaciones
# -----------------------------------------------
func ejecutar_animacion(animacion: StringName):
	match animacion:
		"andando":
			animaciones.set("parameters/conditions/andando", true)
			animaciones.set("parameters/conditions/quieto", false)
		"quieto":
			animaciones.set("parameters/conditions/quieto", true)
			animaciones.set("parameters/conditions/andando", false)
		"atacando":
			animaciones.set("parameters/conditions/atacando", true)
			await get_tree().create_timer(.4).timeout
			animaciones.set("parameters/conditions/atacando", false)
		"muerto":
			animaciones.set("parameters/conditions/muerto", true)

# Gestion del Rayo
# -----------------------------------------------
func _on_rayo_cd_timeout() -> void:
	if esta_muriendose:
		return
	if puede_rayo and not inmovil:
		if hitbox_proyectil.get_overlapping_bodies().size() > 0:
			AudioManager.reproducir_sfx("THUNDER", -8.0)
			var enemigo_rayo = hitbox_proyectil.get_overlapping_bodies().pick_random()
			if enemigo_rayo is Enemigo:
				if not enemigo_rayo.get_muriendo():
					enemigo_rayo.recibir_daño(daño_rayo, 2)
					var nuevo_rayo = rayo.instantiate()
					nuevo_rayo.transform.origin = enemigo_rayo.global_position
					get_tree().root.add_child(nuevo_rayo)

# Gestion de la explosion del escudo
# -----------------------------------------------
func explotar_escudo() -> void:
	if puede_escudo and not inmovil:
		if cam is Camara:
			cam.aplicar_temblor()
		animacion_escudo.play("romper_escudo")
		AudioManager.reproducir_sfx("SHIELD")
		explosion_escudo.emitting = true
		explosion_escudo_2.emitting = true
		explosion_escudo_3.emitting = true
		var enemigos_escudo = hitbox_proyectil.get_overlapping_bodies()
		if enemigos_escudo.size() > 0:
			for enemigo_escudo in enemigos_escudo:
				if enemigo_escudo is Enemigo:
					enemigo_escudo.recibir_daño(daño_explosion, 1)
		escudo_cd.start()

# Gestion de aparicion del escudo
# -----------------------------------------------
func _on_escudo_cd_timeout() -> void:
	if esta_muriendose or not puede_escudo:
		return
	animacion_escudo.play("aparecer_escudo")
	escudo_forma.show()
	escudo = escudo_max
	material_escudo.set_shader_parameter("ray_sharpness", 0.1)
	material_escudo.set_shader_parameter("vertical_speed", 1.5)

# Esconder el escudo tras explotarlo
# -----------------------------------------------
func _on_animacion_escudo_animation_finished(anim_name: StringName) -> void:
	if anim_name == "romper_escudo":
		escudo_forma.hide()

func devolver_desajuste_camara():
	get_tree().create_tween().tween_property(desajuste_camara, "position", Vector3(0,0,0), .8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

# Getters y Setters
# -----------------------------------------------
func get_daño_cd_timer() -> float:
	return daño_cd.time_left

func get_muerto() -> bool:
	return esta_muriendose

func set_inmovil(value: bool) -> void:
	inmovil = value

func get_desajuste_camara() -> Vector3:
	return desajuste_camara.global_position

func set_desajuste_camara() -> void:
	desajuste_camara.position = Vector3(0,6,0)

func eliminar_color(color: String) -> void:
	match color:
		"Amarillo":
			puede_espadear = false
		"Rosa":
			puede_escudo = false
			escudo_forma.hide()
		"Violeta":
			puede_rayo = false
		"Verde":
			puede_disparar = false
			nodo_torreta.hide()
