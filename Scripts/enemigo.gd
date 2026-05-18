extends CharacterBody3D

@export var velocidad = 3.0
@export var aceleracion = 80.0

@export_enum("Amarillo", "Rosa", "Verde", "Violeta") var color: int

@onready var jugador = get_tree().get_first_node_in_group("jugador")

func _physics_process(delta: float) -> void:
	var direccion = global_position.direction_to(jugador.global_position)
	
	velocity.x = move_toward(velocity.x, direccion.x * velocidad, aceleracion * delta)
	velocity.z = move_toward(velocity.z, direccion.z * velocidad, aceleracion * delta)
	
	if direccion.length() > 0:
		look_at(global_position + direccion, Vector3.UP, true)
	
	move_and_slide()
