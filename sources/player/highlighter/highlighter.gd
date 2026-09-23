extends Node

const HIGHLIGHT_MATERIAL: Material = preload("highlight.tres")

@onready var camera: Camera3D = owner.get_node("CharacterBody3D/Camera3D")

# OBJECT: _on_player_selected()
# OBJECT: _on_player_unselected()
var selected_object: CollisionObject3D = null:
	set(value):
		if is_instance_valid(selected_object):
			if value != selected_object:
				unhighlight_object(selected_object)
				if selected_object.has_method("_on_player_unselected"):
					selected_object._on_player_unselected()

		if is_instance_valid(value):
			if value != selected_object:
				if value.has_method("_on_player_selected"):
					value._on_player_selected()

		selected_object = value
		highlight_object(selected_object)

var hovered_object: CollisionObject3D = null

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not is_instance_valid(selected_object):
		selected_object = null

	if selected_object != null:
		if selected_object == camera.selected_object:
			hovered_object = camera.selected_object
			return

	if selected_object != null:
		if hovered_object == selected_object:
			hovered_object = camera.selected_object
			return

	if hovered_object != camera.selected_object:
		unhighlight_object(hovered_object)
		hovered_object = camera.selected_object
		highlight_object(hovered_object)

# OBJECT: _on_player_unhighlighted()
func unhighlight_object(object: CollisionObject3D) -> void:
	if not is_instance_valid(object): return
	for child in object.find_children("*", "GeometryInstance3D", false):
		if child.material_overlay != HIGHLIGHT_MATERIAL: continue
		child.material_overlay = null
	if object.has_method("_on_player_unhighlighted"):
		object._on_player_unhighlighted()

# OBJECT: _on_player_highlighted()
func highlight_object(object: CollisionObject3D) -> void:
	if not is_instance_valid(object): return
	for child in object.find_children("*", "GeometryInstance3D", false):
		if child.material_overlay != null: continue
		child.material_overlay = HIGHLIGHT_MATERIAL
	if object.has_method("_on_player_highlighted"):
		object._on_player_highlighted()
