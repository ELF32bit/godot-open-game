extends MapperUtilities

@warning_ignore("unused_parameter")
static func build(map: MapperMap) -> void:
	var first_world_entity := map.get_first_world_entity()
	if first_world_entity and first_world_entity.brushes.size():
		var lightmap_gi := create_lightmap_gi(map, map.node)
	var paths := preload("path_corner.gd").post_build(map)

	build_base_class_targetname(map)
	preload("func_door.gd").post_build(map)

	build_base_class_target(map)
	build_base_class_killtarget(map)
	build_mesh_properties(map)
	build_mesh_gi_modes(map)

	build_safe_timers(map)
	build_animation_players(map)
	build_collision_layers(map)
	build_sound_players(map)

	preload("func_connector.gd").post_build(map)
	build_forge_game_data(map)


static func _get_build_scripts(map: MapperMap, post: bool = false) -> Dictionary:
	var directory_path := map.settings.game_directory.path_join(
		map.settings.game_builders_directory)

	var scripts: Dictionary = {}
	var directory := DirAccess.open(directory_path)
	if not directory: return scripts

	for script_path in directory.get_files():
		if not script_path.ends_with(".gd"): continue
		if script_path.begins_with(map.settings.post_build_script_name):
			if not post: continue

		var path := directory_path.path_join(script_path)
		var script_name := script_path.trim_suffix(".gd")
		if script_name.ends_with("_"):
			script_name = script_name.trim_suffix("_")
			script_name += "*"

		scripts[script_name] = load(path)
	return scripts


static func build_base_class_target(map: MapperMap) -> void:
	var scripts := _get_build_scripts(map)
	for script_name in scripts:
		var script: GDScript = scripts[script_name]
		if typeof(script.get("BASE_CLASS_TARGET")) == TYPE_BOOL:
			if not script.BASE_CLASS_TARGET: continue
			_bind_target_base(map, script_name)


static func _bind_target_base(map: MapperMap, classname: String) -> void:
	for name in map.classnames:
		if not name.matchn(classname): continue
		for entity in map.classnames.get(name, []):
			entity.bind_signal_property("target",
				"targetname", "generic", "_on_generic_signal")
			entity.bind_node_path_property("target",
				"targetname", "_target")
			entity.bind_node_path_array_property("target",
				"targetname", "_targets")


static func build_base_class_killtarget(map: MapperMap) -> void:
	var scripts := _get_build_scripts(map)
	for script_name in scripts:
		var script: GDScript = scripts[script_name]
		if typeof(script.get("BASE_CLASS_KILLTARGET")) == TYPE_BOOL:
			if not script.BASE_CLASS_KILLTARGET: continue
			_bind_killtarget_base(map, script_name)


static func _bind_killtarget_base(map: MapperMap, classname: String) -> void:
	for name in map.classnames:
		if not name.matchn(classname): continue
		for entity in map.classnames.get(name, []):
			entity.bind_signal_property("killtarget",
				"targetname", "generic_free", "queue_free")
			entity.bind_node_path_property("killtarget",
				"targetname", "_kill_target")
			entity.bind_node_path_array_property("killtarget",
				"targetname", "_kill_targets")


static func build_base_class_targetname(map: MapperMap) -> void:
	var scripts := _get_build_scripts(map)
	for script_name in scripts:
		var script: GDScript = scripts[script_name]
		if typeof(script.get("BASE_CLASS_TARGETNAME")) == TYPE_BOOL:
			if not script.BASE_CLASS_TARGETNAME: continue
			_bind_targetname_base(map, script_name)


static func _bind_targetname_base(map: MapperMap, classname: String) -> void:
	for name in map.classnames:
		if not name.matchn(classname): continue
		for entity in map.classnames.get(name, []):
			var node: String = entity.get_string_property("targetname", "")
			node = node.validate_node_name().strip_edges()
			if not node.is_empty() and entity.node:
				entity.node.set("name", node)


static func build_mesh_properties(map: MapperMap) -> void:
	var scripts := _get_build_scripts(map)
	for script_name in scripts:
		var script: GDScript = scripts[script_name]
		if typeof(script.get("MESH_PROPERTIES")) == TYPE_DICTIONARY:
			_set_mesh_properties(map, script_name, script.MESH_PROPERTIES,
				script.MESH_PROPERTIES.get("__recursive", false))


static func _set_mesh_properties(map: MapperMap, classname: String, properties: Dictionary, recursive: bool) -> void:
	for name in map.classnames:
		if not name.matchn(classname): continue
		for entity in map.classnames.get(name, []):
			if not entity.node: continue
			var children: Array[Node] = entity.node.find_children(
				"*", "MeshInstance3D", recursive, false)
			for child in children:
				for property in properties:
					child.set(property, properties[property])


static func build_mesh_gi_modes(map: MapperMap) -> void:
	if map.settings.prefer_static_lighting: return
	for node in map.node.find_children("*", "AnimatableBody3D", true, false):
		for child in node.find_children("*", "MeshInstance3D", false, false):
			if child.gi_mode == MeshInstance3D.GI_MODE_STATIC:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED


static func build_safe_timers(map: MapperMap) -> void:
	for node in map.node.find_children("*", "Timer", true, false):
		node.process_callback = Timer.TIMER_PROCESS_PHYSICS
		node.wait_time = clampf(node.wait_time, 0.05, INF)


static func build_animation_players(map: MapperMap) -> void:
	for node in map.node.find_children("*", "AnimationPlayer", true, false):
		node.callback_mode_process = (
			AnimationPlayer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS)
		create_reset_animation(node, node.get_animation_library(""))


static func build_sound_players(map: MapperMap) -> void:
	for node in map.node.find_children("*", "AudioStreamPlayer3D", true, false):
		node.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		LAYERS.set_audio_stream_player_area_mask(node)


static func build_collision_layers(map: MapperMap) -> void:
	for node in map.node.find_children("*", "CollisionObject3D", true, false):
		var path := map.node.get_path_to(node, false)

		var node_path: String = ""
		var layer_name: String = ""
		for index in range(path.get_name_count()):
			var path_name := path.get_name(index)
			node_path = node_path.path_join(path_name)

			if index == 0:
				layer_name = layer_name.path_join(path_name)
			elif index > 0:
				var path_node := map.node.get_node(node_path)
				layer_name = layer_name.path_join(path_node.get_class())

		if not LAYERS.PHYSICS_3D.has(layer_name): continue
		var layers: Array = LAYERS.PHYSICS_3D[layer_name]
		node.collision_layer = layers[0]
		node.collision_mask = layers[1]


static func build_forge_game_data(map: MapperMap) -> void:
	var entities := FileAccess.open(
		map.settings.game_directory.path_join(
			"entities.fgd"), FileAccess.WRITE)
	if not entities: return

	entities.store_string("// Game definition file (.fgd)\n\n")
	for script in _get_build_scripts(map).values():
		if script and script.has_method("build_forge_game_data"):
			script.build_forge_game_data(entities)
			entities.store_string("\n")

@warning_ignore("unused_parameter")
static func build_faces_colors(face: MapperFace, colors: PackedColorArray) -> void:
	if not face.parameters.size() >= 3: return
	var source_colors := colors.duplicate()
	var face_value := face.parameters[2]

	# barycentric wireframes mode can be adjusted via special face flags
	# colors.a = (16.0 - flags) / 16.0, where flags are [1], [2], [4], [8]
	# [8] is the sign of face value distinguishing triangles from n-gons
	# [1] will disable red vertex, [2] - green, [4] - blue
	var ngon_flag: int = (8 if int(face_value) < 0 else 0)
	face_value = str(absi(int(face_value)))

	# face colors array can be resized to triangulate the face
	colors.clear()
	for index in range(1, source_colors.size() - 1):
		colors.append(source_colors[0])
		colors.append(source_colors[index])
		colors.append(source_colors[index + 1])

	# barycentric wireframes mode can be applied per triangle in the face
	for index in range(mini(face_value.length(), source_colors.size() - 2)):
		var vertex_flags := int(face_value[index]) % 8
		var flags := (16.0 - float(vertex_flags | ngon_flag)) / 16.0
		colors[index * 3 + 0].a = flags
		colors[index * 3 + 1].a = flags
		colors[index * 3 + 2].a = flags
