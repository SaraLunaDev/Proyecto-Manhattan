extends Node3D
class_name SpawnManager

# Variables
# -----------------------------------------------
@export var enemigos: Array[PackedScene]
@export var temporizador_spawn: Timer
@export var enemigos_maximos = 10
@export var punto_spawn: PathFollow3D
@export var enemigos_spawn: Array[int] = [2,2,1,5]

# Spawn de Enemigos
# -----------------------------------------------
func spawnear_enemigo() -> void:
	# No spawnear si ya se llegó al maximo
	var numero_enemigos = get_tree().get_nodes_in_group("enemigo")
	
	var suma = 0
	for i in enemigos_spawn.size():
		suma += enemigos_spawn.get(i)
	
	if numero_enemigos.size() >= suma:
		return
	
	var enemigo_diccionario = {}
	for enemigo in numero_enemigos:
		if enemigo is Enemigo:
			var color = enemigo.get_color()
			var cantidad = enemigo_diccionario.get(color, 0)
			enemigo_diccionario.set(color, cantidad + 1)
	
	for i in enemigos_spawn.size():
		var hay_enemigo = enemigo_diccionario.get(i)
		if not hay_enemigo:
			enemigo_diccionario.set(i, 0)
	
	enemigo_diccionario.sort()
	
	var enemigos_validos = []
	for i in enemigo_diccionario.size():
		var cantidad = enemigo_diccionario.get(i)
		if cantidad < enemigos_spawn.get(i):
			enemigos_validos.append(i)
	
	# Elegir un enemigo random de la lista de enemigos
	var enemigo_rng = randf_range(0, enemigos_validos.size())
	var enemigo = enemigos.get(enemigos_validos[enemigo_rng]).instantiate()
	
	# Obtener una posicion random en el tablero
	punto_spawn.progress_ratio = randf()
	var posicion_spawn = punto_spawn.transform.origin
	
	# Instanciar el enemigo
	enemigo.transform.origin = posicion_spawn
	add_child(enemigo)

# Se ejecuta cuando termina el temporizador
# -----------------------------------------------
func _on_temporizador_spawn_timeout() -> void:
	spawnear_enemigo()
