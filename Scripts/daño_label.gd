extends Label3D

# Variables
# -----------------------------------------------
@export var tiempo_mostrado: Timer
@export var animacion: AnimationPlayer
var daño_mostrado: float = 0.0
var cam

# Ready
# -----------------------------------------------
func _ready() -> void:
	global_position = global_position + Vector3(randf_range(-0.2,0.2),randf_range(-0.2,0.2),randf_range(-0.2,0.2))
	hide()
	cam = get_viewport().get_camera_3d()

# Process
# -----------------------------------------------
func _process(_delta: float) -> void:
	if cam:
		look_at(cam.global_transform.origin, Vector3.UP, true)

# Mostar el label
# -----------------------------------------------
func mostrar_daño(daño) -> void:
	daño_mostrado = daño
	text = str(int(daño_mostrado))
	animacion.play("caer")
	show()

# Eliminarlo tras CD
# -----------------------------------------------
func _on_tiempo_mostrado_timeout() -> void:
	queue_free()
