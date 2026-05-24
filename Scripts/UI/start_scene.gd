extends Node3D

@onready var main_layer: CanvasLayer = $ButtonsLayer
@onready var options_layer: CanvasLayer = $OptionsLayer
@onready var language_button: Button = $OptionsLayer/Control/VBoxContainer/LanguageButton
const STAGE = preload("uid://hf208faeks6q")


func _ready() -> void:
	Transicion.negro_a_alpha()
	AudioManager.reproducir_musica("SILENCIO")


func _on_start_button_pressed() -> void:
	await Transicion.alpha_a_negro()
	get_tree().change_scene_to_packed(STAGE)

func _on_arcade_button_pressed() -> void:
	pass

func _on_options_pressed() -> void:
	main_layer.hide()
	options_layer.show()


func _on_sound_slider_value_changed(value: float) -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")
	var volumen = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(volumen, value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")
	var volumen = AudioServer.get_bus_index("Musica")
	AudioServer.set_bus_volume_db(volumen, value)


func _on_narration_slider_value_changed(value: float) -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")
	var volumen = AudioServer.get_bus_index("Narracion")
	AudioServer.set_bus_volume_db(volumen, value)


func _on_language_button_pressed() -> void:
	var idioma_actual = TranslationServer.get_locale()
	if idioma_actual == "es":
		TranslationServer.set_locale("en")
	else:
		TranslationServer.set_locale("es")


func _on_return_button_pressed() -> void:
	main_layer.show()
	options_layer.hide()

# ------------------------------------------------------

func _on_language_button_focus_entered() -> void:
	AudioManager.reproducir_sfx("ui_confirm", -6, 1.0, "UI", ".mp3")


func _on_return_button_focus_entered() -> void:
	AudioManager.reproducir_sfx("ui_confirm", -6, 1.0, "UI", ".mp3")


func _on_start_button_focus_entered() -> void:
	AudioManager.reproducir_sfx("ui_confirm", -6, 1.0, "UI", ".mp3")


func _on_arcade_button_focus_entered() -> void:
	AudioManager.reproducir_sfx("ui_confirm", -6, 1.0, "UI", ".mp3")


func _on_options_focus_entered() -> void:
	AudioManager.reproducir_sfx("ui_confirm", -6, 1.0, "UI", ".mp3")
	
# ------------------------------------------------------

func _on_options_mouse_entered() -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")


func _on_arcade_button_mouse_entered() -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")


func _on_start_button_mouse_entered() -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")


func _on_return_button_mouse_entered() -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")


func _on_language_button_mouse_entered() -> void:
	AudioManager.reproducir_sfx("ui_hover", -6, 1.0, "UI", ".mp3")
