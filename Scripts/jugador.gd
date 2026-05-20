extends CharacterBody3D
class_name Jugador

# Variables
# -----------------------------------------------
@export var velocidad = 2.0
@export var aceleracion = 40.0
@export var vida = 10.0
@export var hitbox: Area3D
@export var daño_cd: Timer
@export var espada_cd: Timer
@export var proyectil: PackedScene
@export var punto_proyectil: Marker3D
@export var hitbox_espada: Area3D
@export var daño_espada = 2.0
@export var puede_disparar: bool = false
@export var puede_espadear: bool = false
@export var agent: NavigationAgent3D
var esta_espadeando: bool = false
@export var animaciones: AnimationTree
var esta_recibiendo_daño: bool = false
var esta_muriendose: bool = false
@export var hitbox_proyectil: Area3D
@export var hitbox_espadas_cercanos: Area3D
var ultima_animacion: StringName

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	# Obtener el Input de direccion
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direccion = (Vector3(input.x, 0, input.y)).normalized()

	if direccion:
		# Movimiento hacia direccion con aceleracion
		velocity.x = move_toward(velocity.x, direccion.x * velocidad, aceleracion * delta)
		velocity.z = move_toward(velocity.z, direccion.z * velocidad, aceleracion * delta)
		ejecutar_animacion("Walk")
	else:
		# Pausar movimiento con deceleracion
		velocity.x = move_toward(velocity.x, 0, aceleracion * delta)
		velocity.z = move_toward(velocity.z, 0, aceleracion * delta)
		ejecutar_animacion("Idle")
	
	# Rotar el jugador hacia donde va su direccion
	if direccion.length() > 0:
		if not esta_espadeando and not esta_muriendose and not esta_recibiendo_daño:
			look_at(global_position + direccion, Vector3.UP, true)
	
	if  not esta_muriendose and not esta_recibiendo_daño:
		move_and_slide()
	
	# Detectar colision con enemigo
	var enemigos = hitbox.get_overlapping_bodies()
	if enemigos.size() > 0:
		if enemigos[0] is Enemigo:
			recibir_daño(enemigos[0].get_daño())
	
	if puede_espadear:
		# Detectar enemigos en hitbox espada
		var enemigos_rango_espada = hitbox_espada.get_overlapping_bodies()
		var enemigos_rango_espada_cercanos = hitbox_espadas_cercanos.get_overlapping_bodies()
		if enemigos_rango_espada.size() > 0:
			if espada_cd.time_left <= 0:
				ejecutar_animacion("Attack")
				esta_espadeando = true
				espada_cd.start()
				await get_tree().create_timer(.4).timeout
				for enemigo_rango_espada in enemigos_rango_espada_cercanos:
					if enemigo_rango_espada:
						enemigo_rango_espada.recibir_daño(daño_espada, 1)
				
				await get_tree().create_timer(.6).timeout
				esta_espadeando = false

# Gestion de daño recibido
# -----------------------------------------------
func recibir_daño(daño_recibido) -> void:
	# Si el daño_recibido esta en CD no hacer nada
	if daño_cd.time_left > 0:
		return
	ejecutar_animacion("Hit")
	esta_recibiendo_daño = true
	# Restar vida al Jugador
	vida -= daño_recibido
	print(vida)
	if vida <= 0:
		vida = 0.0
		morir()
	# Comenzar el CD
	daño_cd.start()

# Gestion de muerte
# -----------------------------------------------
func morir() -> void:
	esta_muriendose = true
	ejecutar_animacion("Death")
	await get_tree().create_timer(6).timeout
	get_tree().reload_current_scene()

# Gestion de disparo de proyectil
# -----------------------------------------------
func disparar_proyectil(enemigo_objetivo: Enemigo) -> void:
	if puede_disparar:
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
		var enemigo_objetivo
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
					disparar_proyectil(enemigo_objetivo)
			else:
				disparar_proyectil(enemigo_objetivo)

func ejecutar_animacion(nombre: StringName) -> void:
	match nombre:
		"Death":
			animaciones.set("parameters/conditions/muerto", true)
			await get_tree().create_timer(.1).timeout
			animaciones.set("parameters/conditions/muerto", false)
		"Attack":
			animaciones.set("parameters/conditions/atacando", true)
			await get_tree().create_timer(.1).timeout
			animaciones.set("parameters/conditions/atacando", false)
		"Hit":
			animaciones.set("parameters/conditions/golpeado", true)
			await get_tree().create_timer(.1).timeout
			animaciones.set("parameters/conditions/golpeado", false)
		"Walk":
			animaciones.set("parameters/conditions/andando", true)
			animaciones.set("parameters/conditions/quieto", false)
		"Idle":
			#Idle
			animaciones.set("parameters/conditions/andando", false)
			animaciones.set("parameters/conditions/quieto", true)


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Death":
			esta_recibiendo_daño = false
			esta_muriendose = false
		"Attack":
			esta_recibiendo_daño = false
		"Hit":
			esta_recibiendo_daño = false
			espada_cd.stop()
			espada_cd.start()
