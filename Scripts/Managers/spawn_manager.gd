extends Node3D
class_name SpawnManager

# Variables
# -----------------------------------------------
@export var enemigos: Array[PackedScene]
@export var temporizador_spawn: Timer
@export var enemigos_maximos = 10
@export var punto_spawn: PathFollow3D

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
	punto_spawn.progress_ratio = randf()
	var posicion_spawn = punto_spawn.transform.origin
	# TODO: Almacenar ultimo spawn para que el nuevo spawn sea distinto
	
	# Instanciar el enemigo
	enemigo.transform.origin = posicion_spawn
	add_child(enemigo)

# Se ejecuta cuando termina el temporizador
# -----------------------------------------------
func _on_temporizador_spawn_timeout() -> void:
	spawnear_enemigo()
