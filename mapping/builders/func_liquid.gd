extends MapperUtilities

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var brushes: Array[MapperBrush] = []
	for brush in entity.brushes:
		brush.metadata["mesh_disabled"] = false
		brush.metadata["collision_disabled"] = false
		brush.metadata["occluder_disabled"] = false
		brushes.append(brush)

	var node: Area3D = null
	node = create_csg_merged_brush_entity(entity,
		brushes, "Area3D", true, false, false)
	if not node: return null

	var root := Node3D.new()
	root.transform = node.transform
	add_global_child(node, root, map.settings)
	root.set_script(map.loader.load_script("scripts/func_liquid"))
	root.set("liquid_type", entity.get_int_property("type", 0))
	root.set("_area", root.get_path_to(node))

	for brush in brushes:
		var brush_node := create_brush(entity, brush,
			"StaticBody3D", false, true, false)
		if not brush_node: continue

		for child in brush_node.get_children():
			child.position = get_global_transform(child).origin
			brush_node.remove_child(child)

			child.set_meta("AABB", brush.aabb)
			child.set_meta("PLANES", brush.get_planes(false))
			add_global_child(child, node, map.settings)
		brush_node.free()

	match entity.get_int_property("type", 0):
		0: set_water_area_properties(root, node)
		1: set_slime_area_properties(root, node)
		2: set_lava_area_properties(root, node)
		_: set_water_area_properties(root, node)

	var blocking_node: AnimatableBody3D = null
	blocking_node = create_csg_merged_brush_entity(entity,
		brushes, "AnimatableBody3D", false, true, false)
	if blocking_node:
		add_global_child(blocking_node, root, map.settings)
		set_blocking_area_properties(map, blocking_node)

	return root


static func _set_area_properties(root: Node3D, node: Area3D) -> void:
	node.monitorable = false
	node.body_entered.connect(Callable(root,
		"_on_body_entered"), CONNECT_PERSIST)
	node.body_exited.connect(Callable(root,
		"_on_body_exited"), CONNECT_PERSIST)

	node.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	node.linear_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	node.angular_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE

	node.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	node.gravity_direction = ProjectSettings.get_setting(
		"physics/3d/default_gravity_vector")
	node.gravity_point = false


static func set_water_area_properties(root: Node3D, node: Area3D) -> void:
	_set_area_properties(root, node)
	root.set("liquid_type", 0)
	node.gravity *= 0.3
	node.linear_damp = 1.5
	node.angular_damp = 1.0
	node.audio_bus_override = true
	node.audio_bus_name = "func_liquid-water"
	node.reverb_bus_enabled = true
	node.reverb_bus_amount = 0.4
	node.reverb_bus_uniformity = 0.2


static func set_slime_area_properties(root: Node3D, node: Area3D) -> void:
	_set_area_properties(root, node)
	root.set("liquid_type", 1)
	node.gravity *= 0.15
	node.linear_damp = 4.0
	node.angular_damp = 2.0
	node.audio_bus_override = true
	node.audio_bus_name = "func_liquid-slime"
	node.reverb_bus_enabled = true
	node.reverb_bus_amount = 0.1
	node.reverb_bus_uniformity = 0.5


static func set_lava_area_properties(root: Node3D, node: Area3D) -> void:
	_set_area_properties(root, node)
	root.set("liquid_type", 2)
	node.gravity *= 0.05
	node.linear_damp = 6.0
	node.angular_damp = 4.0
	node.audio_bus_override = true
	node.audio_bus_name = "func_liquid-lava"
	node.reverb_bus_enabled = false

@warning_ignore("unused_parameter")
static func set_blocking_area_properties(map: MapperMap, node: Node3D) -> void:
	for child in node.find_children("*", "CollisionShape3D", true, false):
		if not child.shape is ConcavePolygonShape3D: continue
		child.shape.backface_collision = true


static func build_forge_game_data(entities: FileAccess) -> void:
	entities.store_string(" ".join([
		"@SolidClass",
		"=", "func_liquid", ":",
		'"group of liquid brushes"',
		"[",
			"\n\ttype(choices)", ":", '"liquid type"', ":", "0", "=",
			"[",
				"\n\t\t0", ":", '"water"',
				"\n\t\t1", ":", '"slime"',
				"\n\t\t2", ":", '"lava"',
			"\n\t]",
		"\n]\n",
	]).replace(" \n", "\n"))
