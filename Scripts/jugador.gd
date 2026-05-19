extends CharacterBody3D
class_name Jugador

# Variables
# -----------------------------------------------
@export var velocidad = 4.0
@export var aceleracion = 80.0
@export var vida = 10.0
@export var hitbox: Area3D
@export var daño_cd: Timer
@export var espada_cd: Timer
@export var proyectil: PackedScene
@export var punto_proyectil: Marker3D
@export var hitbox_espada: Area3D
@export var daño = 1.0
@export var puede_disparar: bool = false
@export var puede_espadear: bool = false
@export var animacion: AnimationPlayer

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	# Obtener el Input de direccion
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direccion = (Vector3(input.x, 0, input.y)).normalized()
	
	if (direccion):
		# Movimiento hacia direccion con aceleracion
		velocity.x = move_toward(velocity.x, direccion.x * velocidad, aceleracion * delta)
		velocity.z = move_toward(velocity.z, direccion.z * velocidad, aceleracion * delta)
	else:
		# Pausar movimiento con deceleracion
		velocity.x = move_toward(velocity.x, 0, aceleracion * delta)
		velocity.z = move_toward(velocity.z, 0, aceleracion * delta)
	
	# Rotar el jugador hacia donde va su direccion
	if direccion.length() > 0:
		look_at(global_position + direccion, Vector3.UP, true)
	
	move_and_slide()
	
	# Detectar colision con enemigo
	var enemigos = hitbox.get_overlapping_bodies()
	if enemigos.size() > 0:
		if enemigos[0] is Enemigo:
			recibir_daño(enemigos[0].get_daño())
	
	if puede_espadear:
		# Detectar enemigos en hitbox espada
		var enemigos_rango_espada = hitbox_espada.get_overlapping_bodies()
		if enemigos_rango_espada.size() > 0:
			if espada_cd.time_left <= 0:
				animacion.play("espadazo")
				espada_cd.start()
				for enemigo_rango_espada in enemigos_rango_espada:
					enemigo_rango_espada.recibir_daño(daño)

# Gestion de daño recibido
# -----------------------------------------------
func recibir_daño(daño_recibido) -> void:
	# Si el daño_recibido esta en CD no hacer nada
	if daño_cd.time_left > 0:
		return
	# Restar vida al Jugador
	vida -= daño_recibido
	if vida <= 0:
		vida = 0.0
		morir()
	# Comenzar el CD
	daño_cd.start()

# Gestion de muerte
# -----------------------------------------------
func morir() -> void:
	get_tree().reload_current_scene()

# Gestion de disparo de proyectil
# -----------------------------------------------
func disparar_proyectil() -> void:
	if puede_disparar:
		var nuevo_proyectil = proyectil.instantiate()
		nuevo_proyectil.transform.origin = punto_proyectil.global_position
		get_tree().root.add_child(nuevo_proyectil)

# Gestion si se dispara el proyectil
# -----------------------------------------------
func _on_proyectil_cd_timeout() -> void:
	# Intentar lanzar un proyectil
	var enemigos_objetivo = get_tree().get_nodes_in_group("enemigo")
	if enemigos_objetivo.size() > 0:
		var es_apuntado = false
		var enemigo_objetivo
		for enemigo in enemigos_objetivo:
			if enemigo.get_siendo_apuntado():
				es_apuntado = true
				enemigo_objetivo = enemigo
		
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
