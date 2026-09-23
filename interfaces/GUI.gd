extends Control

@onready var mouse_cursor: Node = $"MOUSE_CURSOR"
@onready var screen_effects: Node = $"SCREEN_EFFECTS"


func update_screen_effects() -> void:
	screen_effects.set_distortion_effect(GameState.player_swim_area_type)

# OBJECT: mouse_cursor_override: int
func update_mouse_cursor_image_on_hover() -> void:
	var object: CollisionObject3D = GameState.player_hovered_object
	var cursor_type: int = 0

	if not is_instance_valid(object):
		cursor_type = int(mouse_cursor.CursorType.DEFAULT)
	elif typeof(object.get("mouse_cursor_override")) == TYPE_INT:
		cursor_type = int(object.mouse_cursor_override)
	else: cursor_type = int(mouse_cursor.CursorType.HOVER)

	if object == GameState.player_interactable_object:
		mouse_cursor.set_custom_alternative_image(cursor_type)
	else: mouse_cursor.set_custom_image(cursor_type)


func update_portrait(image_path: String) -> void: # TODO!
	if not image_path.is_empty():
		$HBoxContainer/Label.text = ([
			"Hello World!", "Hello!",
			"Welcome!", "What do you want?",
			"Leave me alone!", "Get away from me!"][randi() % 6])
		$HBoxContainer/PORTRAIT.texture = load("%s.png" % image_path)
		$HBoxContainer.visible = true
	else:
		$HBoxContainer.visible = false
		$HBoxContainer/PORTRAIT.texture = null
