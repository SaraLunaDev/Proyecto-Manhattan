extends Control

@onready var color_rect: ColorRect = $Titulo/ColorRect
@onready var titulo: CanvasLayer = $Titulo
@onready var textos: MarginContainer = $Titulo/MarginContainer

@onready var titulo_label: Label = $Titulo/MarginContainer/VBoxContainer/Titulo
@onready var subtitulo_label: Label = $Titulo/MarginContainer/VBoxContainer/Subtitulo


func alpha_a_negro(titulo_transicion: String = "", subtitulo_transicion: String = "", duracion: int = 1) -> void:
	titulo.visible = true
	textos.visible = false
	titulo_label.text = titulo_transicion
	subtitulo_label.text = subtitulo_transicion
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 1.0), duracion)
	await tween.finished
	await get_tree().create_timer(2).timeout
	
	if titulo_transicion and subtitulo_transicion:
		AudioManager.reproducir_sfx("poom", -4.0, 1.0, "Extras", ".mp3")
		await get_tree().create_timer(.1).timeout
		textos.visible = true
		await get_tree().create_timer(4).timeout
		textos.visible = false
		await get_tree().create_timer(2).timeout

func negro_a_alpha() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 1)
	await tween.finished
	titulo.visible = false
