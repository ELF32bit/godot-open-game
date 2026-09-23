extends Node3D

@onready var controller: CharacterBody3D = $"CharacterBody3D"
@onready var selector: Node = $"Selector3D"

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	_update_swim_areas_screen_effect.call_deferred()
	_update_selector_objects.call_deferred()


func _update_swim_areas_screen_effect() -> void:
	if controller.is_swimming_deep:
		GameState.player_swim_area_type = controller.swim_area_type
	else: GameState.player_swim_area_type = -1


func _update_selector_objects() -> void:
	GameState.player_selected_object = selector.get_selected_object()
	GameState.player_interactable_object = selector.get_interactable_object()
	GameState.player_hovered_object = selector.get_hovered_object()


func push(velocity: Vector3) -> void:
	controller.push(velocity)


func teleport(to: Transform3D, push_speed: float = 0.0) -> void:
	controller.teleport(to, push_speed)
