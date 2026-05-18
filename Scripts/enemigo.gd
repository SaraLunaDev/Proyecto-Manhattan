extends CharacterBody3D
class_name Enemigo

# Variables
# -----------------------------------------------
@export var velocidad = 3.0
@export var aceleracion = 80.0

@export_enum("Amarillo", "Rosa", "Verde", "Violeta") var color: int

@onready var jugador = get_tree().get_first_node_in_group("jugador")
@onready var agent: NavigationAgent3D = $Agente

# Process
# -----------------------------------------------
func _physics_process(delta: float) -> void:
	# Establecer direccion destino del NavAgent
	agent.target_position = jugador.global_transform.origin
	
	# Obtener direccion dentro de los limites del NavRegion
	var destino = agent.get_next_path_position()
	var posicion = global_transform.origin
	var direccion = (destino - posicion).normalized() * velocidad
	
	# Movimiento hacia direccion con aceleracion
	velocity = velocity.move_toward(direccion, aceleracion * delta)
	
	# Rotar el enemigo hacia donde va su direccion
	if direccion.length() > 0:
		look_at(global_position + direccion, Vector3.UP, true)
	
	move_and_slide()
