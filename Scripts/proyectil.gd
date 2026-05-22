extends Area3D

# Variables
# -----------------------------------------------
@export var velocidad = 20.0
@export var daño = 1.0
var enemigo_objetivo

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	if not enemigo_objetivo:
		queue_free()
		return
	enemigo_objetivo.set_siendo_apuntado(true)
	position = position.move_toward(enemigo_objetivo.get_punto_daño().global_position, delta * velocidad)
	if not enemigo_objetivo.get_punto_daño().global_position == global_position:
		look_at(enemigo_objetivo.get_punto_daño().global_position, Vector3.UP, true)
	# Eliminar proyectil cuando colisione
	var enemigos_colisionados = get_overlapping_bodies()
	if enemigos_colisionados.size() > 0:
		aplicar_daño(enemigos_colisionados[0])

# Gestion de aplicar daño
# -----------------------------------------------
func aplicar_daño(enemigo: Enemigo) -> void:
	enemigo.recibir_daño(daño, 0)
	enemigo.set_siendo_apuntado(false)
	queue_free()

# Getters y Setters
# -----------------------------------------------
func get_daño() -> float:
	return daño

func set_enemigo_objetivo(value: Enemigo) -> void:
	enemigo_objetivo = value
