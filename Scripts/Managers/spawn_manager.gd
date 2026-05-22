extends Node3D
class_name SpawnManager

# Variables
# -----------------------------------------------
@export var enemigos: Array[PackedScene]
@export var temporizador_spawn: Timer
@export var enemigos_maximos = 10
@export var punto_spawn: PathFollow3D
@export var enemigos_spawn: Array[int] = [2,2,1,5]
@export var game_manager: GameManager
var puede_spawnear = false

# Spawn de Enemigos
# -----------------------------------------------
func spawnear_enemigo() -> void:
	if not puede_spawnear:
		return
	# No spawnear si ya se llegó al maximo
	var numero_enemigos = get_tree().get_nodes_in_group("enemigo")
	# Obtener el numero de enemigos
	var suma = 0
	for i in enemigos_spawn.size():
		suma += enemigos_spawn.get(i)
	# Ver si supera el maximo para no spawnear mas
	if numero_enemigos.size() >= suma:
		return
	# Obtener cuantos de cada tipo hay
	var enemigo_diccionario = {}
	for enemigo in numero_enemigos:
		if enemigo is Enemigo:
			var color = enemigo.get_color()
			var cantidad = enemigo_diccionario.get(color, 0)
			enemigo_diccionario.set(color, cantidad + 1)
	# Establecer a 0 los que no han sido detectados
	for i in enemigos_spawn.size():
		var hay_enemigo = enemigo_diccionario.get(i)
		if not hay_enemigo:
			enemigo_diccionario.set(i, 0)
	# Ordenarlos
	enemigo_diccionario.sort()
	# Ver cuales no superan su propio maximo
	var enemigos_validos = []
	for i in enemigo_diccionario.size():
		var cantidad = enemigo_diccionario.get(i)
		if cantidad < enemigos_spawn.get(i):
			enemigos_validos.append(i)
	# Elegir un enemigo random de la lista de enemigos
	var enemigo
	if game_manager.get_colores_activos().size() > 0:
		var enemigo_color = game_manager.get_colores_activos().pick_random()
		for enemigo_objetivo in enemigos:
			var enemigo_instanciado = enemigo_objetivo.instantiate()
			if enemigo_instanciado is Enemigo:
				if enemigo_instanciado.get_color_nombre() == enemigo_color and enemigos_validos.find(enemigo_instanciado.get_color()) != -1:
					enemigo = enemigo_instanciado
					break
		if enemigo:
			# Obtener una posicion random en el tablero
			punto_spawn.progress_ratio = randf()
			var posicion_spawn = punto_spawn.transform.origin
			# Instanciar el enemigo
			enemigo.transform.origin = posicion_spawn
			if puede_spawnear:
				add_child(enemigo)

# Se ejecuta cuando termina el temporizador
# -----------------------------------------------
func _on_temporizador_spawn_timeout() -> void:
	spawnear_enemigo()


func set_puede_spawnear(value: bool) -> void:
	puede_spawnear = value
