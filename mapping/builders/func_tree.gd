extends MapperUtilities # TODO!

const BASE_CLASS_TARGET := true
const BASE_CLASS_KILLTARGET := true
const BASE_CLASS_TARGETNAME := true
const AREA_GROW_UNITS: float = 32.0

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node: AnimatableBody3D = null
	var pivot_offset := Vector3.DOWN * entity.aabb.size.y / 2.0
	entity.node_properties["position"] = entity.center + pivot_offset
	node = create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node: return null

	var root := Node3D.new()
	root.transform = node.transform.translated(-pivot_offset)
	add_global_child(node, root, map.settings)

	var area_data := _build_area(map, entity, root)
	var area_shape: CollisionShape3D = area_data[1]
	var area: Area3D = area_data[0]

	var animation_player := AnimationPlayer.new()
	root.add_child(animation_player, map.settings.readable_node_names)
	var animations := build_animations(entity,
		[root, node, area, area_shape, ])

	var animation_library := AnimationLibrary.new()
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = ""

	root.set_script(map.loader.load_script("scripts/func_tree"))
	root.set("_animation_player", root.get_path_to(animation_player))
	root.set("_area", root.get_path_to(area))

	area.body_entered.connect(Callable(root,
		"_on_body_entered"), CONNECT_PERSIST)
	animation_player.animation_finished.connect(Callable(root,
		"_on_animation_finished"), CONNECT_PERSIST)

	var wait_timer := preload("func_button.gd"
		)._build_timer(map, entity, root, "wait", 2.0)

	if wait_timer:
		node.set("_wait_timer", node.get_path_to(wait_timer))
		wait_timer.timeout.connect(Callable(node,
			"_on_wait_timer_timeout"), CONNECT_PERSIST)

	return root


static func _build_area(map: MapperMap, entity: MapperEntity, parent: Node3D) -> Array:
	var area := Area3D.new()
	parent.add_child(area, map.settings.readable_node_names)
	area.monitorable = false

	var shape := CollisionShape3D.new()
	area.add_child(shape, map.settings.readable_node_names)
	var grow_units := AREA_GROW_UNITS / map.settings.unit_size
	var size := entity.aabb.grow(grow_units).size
	shape.shape = BoxShape3D.new()
	shape.shape.size = size

	parent.move_child(area, 0)
	return [area, shape]


static func build_animations(entity: MapperEntity, nodes: Array) -> Array[Animation]:
	return []


static func build_forge_game_data(entities: FileAccess) -> void:
	entities.store_string(" ".join([
		"@SolidClass",
		"=", "func_tree", ":",
		'"animated tree collectable"',
		"[",
			"\n\ttarget(target_destination)", ":", '"target to activate"',
			"\n\tkilltarget(target_destination)", ":", '"target to destroy"',
			"\n\ttargetname(target_source)", ":", '"entity name"',
			"\n\twait(float)", ":", '"wait time"', ":", '"2.0"',
		"\n]\n",
	]).replace(" \n", "\n"))
