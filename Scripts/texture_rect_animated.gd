extends TextureRect

@export var imagenes: Array[Texture]
var numero = 0
var temporizador

func _process(_delta: float) -> void:
	if imagenes.size() > 0:
		texture = imagenes[numero]
		
		numero += 1
		if numero >= imagenes.size():
			numero = 0
