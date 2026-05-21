extends CharacterBody3D

var posicion = Vector3.ZERO
@onready var hitbox: Area3D = $Hitbox
@export var daño = 1.0

func _physics_process(delta: float) -> void:
	posicion.y = global_position.y
	velocity = (posicion - global_position).normalized() * 200 * delta * -1
	move_and_slide()
	
	if hitbox.get_overlapping_bodies().size() > 0:
		var jugador = hitbox.get_overlapping_bodies()[0]
		if jugador is Jugador:
			jugador.recibir_daño(daño)

func set_posicion(valor: Vector3) -> void:
	posicion = valor

func _on_tiempo_vida_timeout() -> void:
	queue_free()
