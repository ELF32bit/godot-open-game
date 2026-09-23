extends AnimatableBody3D

@export var hover_text: String = ""
@export var mouse_cursor_override: int = 1

@export_node_path("Node3D") var _ui_label: NodePath
@onready var ui_label: Node3D = get_node(_ui_label)


func _on_player_highlighted() -> void:
	ui_label.text = hover_text
	ui_label.visible = true


func _on_player_unhighlighted() -> void:
	ui_label.text = ""
	ui_label.visible = false
