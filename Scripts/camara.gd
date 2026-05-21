extends Camera3D

@export var jugador: Jugador
@export var desajuste: Vector3 = Vector3(0,6,7)

func _physics_process(_delta: float) -> void:
	transform.origin = jugador.global_position + desajuste
	look_at(jugador.global_position)
