extends CharacterBody3D
class_name Jugador

# Variables
# -----------------------------------------------
@export var velocidad = 2.0
@export var aceleracion = 40.0
@export var vida = 10.0
@export var escudo = 4.0
@export var escudo_max = 4.0
@export var hitbox: Area3D
@export var daño_cd: Timer
@export var espada_cd: Timer
@export var proyectil: PackedScene
@export var punto_proyectil: Marker3D
@export var hitbox_espada: Area3D
@export var daño_espada = 2.0
@export var puede_disparar: bool = false
@export var puede_espadear: bool = false
@export var puede_rayo: bool = false
@export var agent: NavigationAgent3D
var esta_espadeando: bool = false
@export var animaciones: AnimationTree
var esta_muriendose: bool = false
@export var hitbox_proyectil: Area3D
@export var hitbox_espadas_cercanos: Area3D
var ultima_animacion: StringName
@export var nodo_torreta: Node3D
var enemigo_objetivo: Enemigo
var cam: Camera3D
@export var daño_rayo = 1.0
@export var escudo_forma: MeshInstance3D
@export var puede_escudo: bool = false
@export var escudo_cd: Timer

func _ready() -> void:
	cam = get_viewport().get_camera_3d()
	escudo_forma.show()
	escudo = escudo_max

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	# Obtener el Input de direccion
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direccion = (Vector3(input.x, 0, input.y)).normalized()
	
	
	if direccion:
		# Movimiento hacia direccion con aceleracion
		ejecutar_animacion("andando")
		velocity.x = move_toward(velocity.x, direccion.x * velocidad, aceleracion * delta)
		velocity.z = move_toward(velocity.z, direccion.z * velocidad, aceleracion * delta)
	else:
		ejecutar_animacion("quieto")
		# Pausar movimiento con deceleracion
		velocity.x = move_toward(velocity.x, 0, aceleracion * delta)
		velocity.z = move_toward(velocity.z, 0, aceleracion * delta)
	
	# Rotar el jugador hacia donde va su direccion
	if direccion.length() > 0:
		if not esta_espadeando and not esta_muriendose:
			look_at(global_position + direccion, Vector3.UP, true)
	
	if not esta_muriendose:
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
				esta_espadeando = true
				espada_cd.start()
				ejecutar_animacion("atacando")
				await get_tree().create_timer(.5).timeout
				for enemigo_rango_espada in enemigos_rango_espada_cercanos:
					if enemigo_rango_espada:
						enemigo_rango_espada.recibir_daño(daño_espada, 1)
				
				await get_tree().create_timer(.6).timeout
				esta_espadeando = false
		
		if enemigo_objetivo:
			nodo_torreta.look_at(enemigo_objetivo.global_position, Vector3.UP, true)
		else:
			if cam:
				nodo_torreta.look_at(Vector3(cam.global_position.x, 0, cam.global_position.z), Vector3.UP, false)

# Gestion de daño recibido
# -----------------------------------------------
func recibir_daño(daño_recibido) -> void:
	# Si el daño_recibido esta en CD no hacer nada
	if daño_cd.time_left > 0:
		return
	
	if escudo > 0:
		escudo -= daño_recibido
		if escudo <= 0:
			escudo = 0.0
			explotar_escudo()
	else:
		# Restar vida al Jugador
		vida -= daño_recibido
		espada_cd.stop()
		espada_cd.start()
		if vida <= 0:
			vida = 0.0
			morir()
	
	# Comenzar el CD
	daño_cd.start()

# Gestion de muerte
# -----------------------------------------------
func morir() -> void:
	esta_muriendose = true
	await get_tree().create_timer(6).timeout
	get_tree().reload_current_scene()

# Gestion de disparo de proyectil
# -----------------------------------------------
func disparar_proyectil() -> void:
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
					disparar_proyectil()
			else:
				disparar_proyectil()

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

func _on_rayo_cd_timeout() -> void:
	if puede_rayo:
		if hitbox_proyectil.get_overlapping_bodies().size() > 0:
			var enemigo_rayo = hitbox_proyectil.get_overlapping_bodies().pick_random()
			if enemigo_rayo is Enemigo:
				enemigo_rayo.recibir_daño(daño_rayo, 0)

func explotar_escudo() -> void:
	if puede_escudo:
		escudo_forma.hide()
		escudo_cd.start()

func _on_escudo_cd_timeout() -> void:
	escudo_forma.show()
	escudo = escudo_max
