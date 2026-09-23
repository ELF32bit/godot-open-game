extends MapperUtilities

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	return null


static func build_forge_game_data(entities: FileAccess) -> void:
	entities.store_string(" ".join([
		"@PointClass",
		"=", "info_animation", ":",
		'"helper for the animation system"',
		"[",
			"\n\tautoplay(string)", ":", '"default animation"',
			"\n\tfade_visibility_end(float)", ":", '"for after-images"', ":", '"0.0"',
			"\n\tvisibility_end(float)", ":", '"for meshes"', ":", '"0.0"',
			"\n\tcast_shadow(choices)", ":", '"shadow mode"', ":", "0", "=",
			"[",
				"\n\t\t0", ":", '"disabled"',
				"\n\t\t1", ":", '"on"',
				"\n\t\t2", ":", '"double sided"',
			"\n\t]",
		"\n]\n",
	]).replace(" \n", "\n"))
