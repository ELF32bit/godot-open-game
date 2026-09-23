extends MapperUtilities

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := AnimatableBody3D.new()
	apply_entity_transform(entity, node)
	node.collision_layer = (1<<31) | (1<<30)
	node.collision_mask = 0

	var character: PackedScene = load(
		"res://characters/maps/servbot.map")
	var mesh_instance := character.instantiate()
	node.add_child(mesh_instance, map.settings.readable_node_names)

	var aabb := _get_character_aabb(mesh_instance)
	mesh_instance.position += Vector3.DOWN * aabb.size.y * 0.5

	var selection_shape := CollisionShape3D.new()
	node.add_child(selection_shape, map.settings.readable_node_names)

	selection_shape.shape = CapsuleShape3D.new()
	aabb.size = aabb.size.snappedf(map.settings.grid_snap_step)
	selection_shape.shape.radius = maxf(aabb.size.x, aabb.size.z) * 0.5
	selection_shape.shape.height = aabb.size.y

	node.set_script(map.loader.load_script(
		"scripts/character_servbot"))

	return node


static func _get_character_aabb(character: Node3D) -> AABB:
	var aabb := AABB()
	var aabb_is_empty := true
	for child in character.find_children("*", "MeshInstance3D", true, false):
		if not child.get_parent().visible: continue
		if not child.visible: continue
		if not child.mesh: continue

		var child_aabb: AABB = child.get_aabb()
		if not child_aabb.has_surface(): continue

		if aabb_is_empty:
			aabb = child_aabb
			aabb_is_empty = false
			continue

		aabb = aabb.merge(child_aabb)
	return aabb.abs()
