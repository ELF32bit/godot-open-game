extends Node

@onready var character: CharacterBody3D = get_parent()
@onready var animation_player: AnimationPlayer = $"ANIMATIONS"

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var velocity := character.velocity.length()
	if character.movement_mode == 1: _play_animation("swim")
	elif velocity > 0.1: _play_animation("walk")
	else: _play_animation("idle")


func _play_animation(animation: StringName, restart: bool = false) -> void:
	if restart or animation_player.current_animation != animation:
		animation_player.play(animation)
