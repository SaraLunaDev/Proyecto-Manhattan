extends CharacterBody3D
class_name Enemigo

# Variables
# -----------------------------------------------
@export var velocidad = 1.5
@export var aceleracion = 80.0
@export_enum("Amarillo", "Rosa", "Verde", "Violeta") var color: int
@onready var jugador = get_tree().get_first_node_in_group("jugador")
@onready var agent: NavigationAgent3D = $Agente
@export var vida = 4.0
@export var daño = 1.0
@export var punto_daño: Marker3D
@export var punto_daño_label: Marker3D
@export var daño_label: PackedScene
var siendo_apuntado = false

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	# Establecer direccion destino del NavAgent
	agent.target_position = jugador.global_transform.origin
	
	# Obtener direccion dentro de los limites del NavRegion
	var destino = agent.get_next_path_position()
	var posicion = global_transform.origin
	var direccion = (destino - posicion).normalized() * velocidad
	
	direccion.y = 0
	
	# Movimiento hacia direccion con aceleracion
	velocity = velocity.move_toward(direccion, aceleracion * delta)
	
	# Rotar el enemigo hacia donde va su direccion
	if direccion.length() > 0:
		look_at(global_position + direccion, Vector3.UP, true)
	
	move_and_slide()

# Recibir daño
# -----------------------------------------------
func recibir_daño(daño_recibido) -> void:
	var nuevo_daño_label = daño_label.instantiate()
	nuevo_daño_label.transform.origin = punto_daño_label.global_position
	get_tree().root.add_child(nuevo_daño_label)
	nuevo_daño_label.mostrar_daño(daño_recibido)
	
	vida -= daño_recibido
	if vida <= 0:
		vida = 0.0
		morir()

func morir() -> void:
	queue_free()

# Getters y Setters
# -----------------------------------------------
func get_daño() -> int:
	return daño

func get_punto_daño() -> Marker3D:
	return punto_daño

func set_siendo_apuntado(valor: bool) -> void:
	siendo_apuntado = valor

func get_siendo_apuntado() -> bool:
	return siendo_apuntado

func get_vida() -> float:
	return vida
