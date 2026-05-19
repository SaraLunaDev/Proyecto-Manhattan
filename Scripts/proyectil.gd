extends Area3D

@export var velocidad = 20.0
@export var daño = 1.0

func _physics_process(delta: float) -> void:
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	var enemigo = enemigos[0]
	enemigo.set_siendo_apuntado(true)
	if enemigos.size() > 0:
		position = position.move_toward(enemigo.get_punto_daño().global_position, delta * velocidad)
	
	# Eliminar proyectil cuando colisione
	var enemigos_colisionados = get_overlapping_bodies()
	if enemigos_colisionados.size() > 0:
		aplicar_daño(enemigos_colisionados[0])

func aplicar_daño(enemigo: Enemigo) -> void:
	enemigo.recibir_daño(daño)
	enemigo.set_siendo_apuntado(false)
	queue_free()

func get_daño() -> float:
	return daño
