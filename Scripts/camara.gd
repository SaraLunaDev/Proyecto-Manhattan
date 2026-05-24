extends Camera3D
class_name Camara
	
@export var jugador: Jugador
@export var desajuste: Vector3 = Vector3(0,7,8)
@export var fuerza_aleatoria = 0.3
@export var temblor_desaparecer = 5.0
@export var camara_base_posicion: Vector3 = Vector3(0,0.144,0.552)
@export var camara_base_rotacion: Vector3 = Vector3(36.1,0,0)
var camara_iniciada = false
var aleatorio = RandomNumberGenerator.new()
var fuerza_temblor = 0.0
var camara_cambio_acto = false

func mover_hacia_jugador():
	jugador.devolver_desajuste_camara()
	get_tree().create_tween().tween_property(self, "position", jugador.global_position + desajuste, .8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	camara_iniciada = true

func _physics_process(delta: float) -> void:
	if camara_cambio_acto:
		return
	
	look_at(jugador.get_desajuste_camara())
	
	if not camara_iniciada:
		return
	
	if fuerza_temblor > 0.0:
		fuerza_temblor = lerpf(fuerza_temblor, 0, temblor_desaparecer * delta)
		h_offset = desajuste_aleatorio().x
		v_offset = desajuste_aleatorio().y
	transform.origin = jugador.global_position + desajuste

func aplicar_temblor() -> void:
	fuerza_temblor = fuerza_aleatoria

func desajuste_aleatorio() -> Vector2:
	return Vector2(aleatorio.randf_range(-fuerza_temblor, fuerza_temblor), aleatorio.randf_range(-fuerza_temblor,fuerza_temblor))

func set_camara_cambio_acto(value: bool) -> void:
	camara_cambio_acto = value
