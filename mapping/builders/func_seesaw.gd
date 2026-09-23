extends MapperUtilities

const BASE_CLASS_PARENT := false

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node: RigidBody3D = null
	var pivot_offset := Vector3.DOWN * entity.aabb.size.y * 0.5
	node = create_merged_brush_entity(entity, "RigidBody3D")
	if not node: return null

	var root := Node3D.new()
	root.transform = node.transform
	add_global_child(node, root, map.settings)

	node.linear_damp = 10.0
	node.angular_damp = 10.0
	node.axis_lock_linear_x = false
	node.axis_lock_linear_y = false
	node.axis_lock_linear_y = false
	node.axis_lock_angular_x = false
	node.axis_lock_angular_y = false
	node.axis_lock_angular_z = false

	var hinge_joint := HingeJoint3D.new()
	root.add_child(hinge_joint, map.settings.readable_node_names)
	hinge_joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	hinge_joint.node_a = hinge_joint.get_path_to(node)
	hinge_joint.exclude_nodes_from_collision = true
	hinge_joint.position += pivot_offset
	hinge_joint.node_b = NodePath("")

	hinge_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(
		entity.get_float_property("limit_upper", 30.0)))
	hinge_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(
		entity.get_float_property("limit_lower", -30.0)))

	return root


static func build_forge_game_data(entities: FileAccess) -> void:
	entities.store_string(" ".join([
		"@SolidClass",
		"=", "func_seesaw", ":",
		'"physically simulated seesaw"',
		"[",
			"\n\tangle(float)", ":", '"angle of rotation"',
			"\n\tlimit_upper(float)", ":", '"angle limit (degrees)"', ":", '"30.0"',
			"\n\tlimit_lower(float)", ":", '"angle limit (degrees)"', ":", '"-30.0"',
		"\n]\n",
	]).replace(" \n", "\n"))
