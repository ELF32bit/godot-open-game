extends Node3D # TODO!

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	pass

@warning_ignore("unused_parameter")
func _on_animation_finished(animation_name: StringName) -> void:
	pass


func _on_wait_timer_timeout() -> void:
	pass
