extends Camera3D
class_name Camara
	
@export var jugador: Jugador
@export var desajuste: Vector3 = Vector3(0,6,7)

@export var fuerza_aleatoria = 0.3
@export var temblor_desaparecer = 5.0

var aleatorio = RandomNumberGenerator.new()

var fuerza_temblor = 0.0

func _physics_process(delta: float) -> void:
	if fuerza_temblor > 0.0:
		fuerza_temblor = lerpf(fuerza_temblor, 0, temblor_desaparecer * delta)
		h_offset = desajuste_aleatorio().x
		v_offset = desajuste_aleatorio().y
	transform.origin = jugador.global_position + desajuste
	look_at(jugador.global_position)

func aplicar_temblor() -> void:
	fuerza_temblor = fuerza_aleatoria

func desajuste_aleatorio() -> Vector2:
	return Vector2(aleatorio.randf_range(-fuerza_temblor, fuerza_temblor), aleatorio.randf_range(-fuerza_temblor,fuerza_temblor))
