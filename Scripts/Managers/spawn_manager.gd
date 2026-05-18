extends Node3D
class_name SpawnManager

# Variables
# -----------------------------------------------
@export var enemigos: Array[PackedScene]
@export var temporizador_spawn: Timer
@export var enemigos_maximos = 4

# Spawn de Enemigos
# -----------------------------------------------
func spawnear_enemigo() -> void:
	# No spawnear si ya se llegó al maximo
	var numero_enemigos = get_tree().get_nodes_in_group("enemigo")
	if numero_enemigos.size() >= enemigos_maximos:
		return
	
	# Elegir un enemigo random de la lista de enemigos
	var enemigo_rng = randf_range(0, enemigos.size())
	var enemigo = enemigos.get(enemigo_rng).instantiate()
	
	# Obtener una posicion random en el tablero
	var posicion_spawn = Vector3.ZERO
	posicion_spawn.x = randf_range(-8, 8)
	posicion_spawn.z = randf_range(-3, 3)
	
	# Instanciar el enemigo
	enemigo.global_position = posicion_spawn
	add_child(enemigo)

# Se ejecuta cuando termina el temporizador
# -----------------------------------------------
func _on_temporizador_spawn_timeout() -> void:
	spawnear_enemigo()
