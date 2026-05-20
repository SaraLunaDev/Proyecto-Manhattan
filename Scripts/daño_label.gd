extends Label3D

@export var tiempo_mostrado: Timer
@export var animacion: AnimationPlayer
var daño_mostrado: float = 0.0
var cam

func _ready() -> void:
	hide()
	cam = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	if cam:
		look_at(cam.global_transform.origin, Vector3.UP, true)

func mostrar_daño(daño) -> void:
	daño_mostrado = daño
	text = str(int(daño_mostrado))
	animacion.play("caer")
	show()

func _on_tiempo_mostrado_timeout() -> void:
	queue_free()
