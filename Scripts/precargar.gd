extends Node3D

@onready var explosion_escudo: GPUParticles3D = $ExplosionEscudo
@onready var explosion_escudo_2: GPUParticles3D = $ExplosionEscudo2
@onready var explosion_escudo_3: GPUParticles3D = $ExplosionEscudo3
@onready var daño: GPUParticles3D = $Daño
@onready var animation_player: AnimationPlayer = $SwordTrail/AnimationPlayer

func free() -> void:
	explosion_escudo.emitting = true
	explosion_escudo_2.emitting = true
	explosion_escudo_3.emitting = true
	daño.emitting = true
	animation_player.play("girar_espada")
