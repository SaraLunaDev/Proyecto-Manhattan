extends CharacterBody3D

@export var velocidad = 7.0
@export var aceleracion = 80.0

func _physics_process(delta: float) -> void:
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direccion = (Vector3(input.x, 0, input.y)).normalized()
	
	if (direccion):
		velocity.x = move_toward(velocity.x, direccion.x * velocidad, aceleracion * delta)
		velocity.z = move_toward(velocity.z, direccion.z * velocidad, aceleracion * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, aceleracion * delta)
		velocity.z = move_toward(velocity.z, 0, aceleracion * delta)
	
	if direccion.length() > 0:
		look_at(global_position + direccion, Vector3.UP, true)
	
	move_and_slide()
