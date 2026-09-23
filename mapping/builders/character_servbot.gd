extends MapperUtilities

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var path: String = "res://characters/scenes/servbot.tscn"
	var node: Node3D = load(path).instantiate()

	var mesh_instance := node.get_child(0).get_child(0)
	var aabb: AABB = mesh_instance.get_meta("AABB", AABB())
	var offset: Vector3 = aabb.get_center()

	if not entity.node_properties.has("position"):
		entity.node_properties["position"] = entity.center
	entity.node_properties["scale"] = (Vector3.ONE *
		entity.get_float_property("scale", 1.0))

	entity.node_properties["position"] += (Vector3.ONE *
		entity.node_properties["scale"] * offset)

	return node


static func build_forge_game_data(entities: FileAccess) -> void:
	entities.store_string(" ".join([
		"@PointClass",
		"size(-8 -8 0, 8 8 32)",
		'model("models/servbot.obj")',
		"=", "character_servbot", ":",
		'"dummy character"',
		"[",
		"\n]\n",
	]).replace(" \n", "\n"))
