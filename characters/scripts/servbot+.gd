extends AnimatableBody3D

@export var is_player_selectable: bool = true
@export var is_player_interactable: bool = true
@export var mouse_cursor_override: int = 5

@onready var node: Node3D = get_parent()
@onready var selection: SpotLight3D = $DECALS/SELECTION
@onready var shadow: SpotLight3D = $DECALS/SHADOW


func _ready() -> void:
	selection.uniform_scale = node.scale.y
	shadow.uniform_scale = node.scale.y
	selection.update_shape()
	shadow.update_shape()


func _on_player_selected(player: Node) -> void:
	selection.selection_color = Color.GREEN
	selection.update_selection_color()
	selection.visible = true
	node._on_player_selected(player)
	GUI.update_portrait($MeshInstance3D/PORTRAIT.image_path)


func _on_player_unselected(player: Node) -> void:
	selection.visible = false
	node._on_player_unselected(player)
	GUI.update_portrait("")

@warning_ignore("unused_parameter")
func _on_player_interacted(player: Node) -> void:
	pass
