extends MapperUtilities

const BASE_CLASS_TARGET := true
const BASE_CLASS_KILLTARGET := true
const BASE_CLASS_TARGETNAME := true

const MESH_PROPERTIES: Dictionary = {
	"cast_shadow": MeshInstance3D.SHADOW_CASTING_SETTING_OFF,
	"visibility_range_end": 100.0,
	"__recursive": true
}

const AREA_GROW_UNITS: float = 32.0
const AREA_CLEANUP_WHEN_NO_TIMER := true
const SHADER_FADE_PROPERTY: String = "fade"
const ANIMATE_FADE_FALLBACK := true

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node: AnimatableBody3D = null
	node = create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node: return null

	var root := Node3D.new()
	root.transform = node.transform
	add_global_child(node, root, map.settings)

	var area_data := _build_area(map, entity, root)
	var _area_shape: CollisionShape3D = area_data[1]
	var area: Area3D = area_data[0]
	area.monitoring = false

	var animation_player := AnimationPlayer.new()
	root.add_child(animation_player, map.settings.readable_node_names)
	var animations := build_animations(entity,
		[node, ])

	var animation_library := AnimationLibrary.new()
	animation_player.add_animation_library("", animation_library)
	animation_library.add_animation("enable", animations[0])
	animation_library.add_animation("enabled", animations[1])
	animation_library.add_animation("disable", animations[2])
	animation_library.add_animation("disabled", animations[3])
	animation_player.autoplay = "enabled"

	node.set_script(map.loader.load_script("scripts/mining_coal"))
	node.set("mouse_cursor_override", entity.get_int_property("cursor", 1))

	root.set_script(map.loader.load_script("scripts/classes/collectable"))
	root.set("_animation_player", root.get_path_to(animation_player))
	root.set("_animatable_body", root.get_path_to(node))
	root.set("_area", root.get_path_to(area))

	animation_player.animation_finished.connect(Callable(root,
		"_on_animation_finished"), CONNECT_PERSIST)

	var wait_timer := preload("func_button.gd"
		)._build_timer(map, entity, root, "wait", -1.0)

	if wait_timer:
		root.set("_wait_timer", root.get_path_to(wait_timer))
		wait_timer.timeout.connect(Callable(root,
			"_on_wait_timer_timeout"), CONNECT_PERSIST)
	elif AREA_CLEANUP_WHEN_NO_TIMER:
		root.set("_area", "")
		area.free()

	if not entity.get_string_property("targetname", "").is_empty():
		animation_player.autoplay = "disabled"

	return root


static func _build_area(map: MapperMap, entity: MapperEntity, parent: Node3D) -> Array:
	var area := Area3D.new()
	parent.add_child(area, map.settings.readable_node_names)
	area.monitorable = false

	var shape := CollisionShape3D.new()
	area.add_child(shape, map.settings.readable_node_names)
	var grow_units := AREA_GROW_UNITS / map.settings.unit_size
	var size := entity.aabb.get_longest_axis_size() + grow_units

	shape.shape = SphereShape3D.new()
	shape.shape.radius = size

	parent.move_child(area, 0)
	return [area, shape]

@warning_ignore("unused_parameter")
static func build_animations(entity: MapperEntity, nodes: Array) -> Array[Animation]:
	var node: AnimatableBody3D = nodes[0]
	var meshes := node.find_children("*",
		"MeshInstance3D", false, false)
	var shapes := node.find_children("*",
		"CollisionShape3D", false, false)
	var occluders := node.find_children("*",
		"OccluderInstance3D", false, false)

	# animation parameters
	var fade_time: float = 0.5

	var parameters: Dictionary = {
		"node": node,
		"meshes": meshes,
		"shapes": shapes,
		"occluders": occluders,
		"frames": [0.0, fade_time],
	}

	return [
		_build_enable_animation(parameters),
		_build_enabled_animation(parameters),
		_build_disable_animation(parameters),
		_build_disabled_animation(parameters),
	]


static func _build_enable_animation(p: Dictionary) -> Animation:
	var animation := Animation.new()
	__build_bool_track(animation, p, NodePath(
		p.node.name + ":visible"), 1)

	for mesh in p.meshes:
		if not mesh.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) + ":visible"), 1)
		__build_mesh_fade_tracks(animation, p, mesh, 1)

	for shape in p.shapes:
		if shape.disabled: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(shape.name) + ":disabled"), 0)

	for occluder in p.occluders:
		if not occluder.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(occluder.name) + ":visible"), 1)

	animation.length = p.frames[1]
	return animation


static func _build_enabled_animation(p: Dictionary) -> Animation:
	var animation := Animation.new()
	__build_bool_track(animation, p, NodePath(
		p.node.name + ":visible"), 1)

	for mesh in p.meshes:
		if not mesh.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) + ":visible"), 1)
		__build_mesh_fade_tracks(animation, p, mesh, 3)

	for shape in p.shapes:
		if shape.disabled: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(shape.name) + ":disabled"), 0)

	for occluder in p.occluders:
		if not occluder.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(occluder.name) + ":visible"), 1)

	animation.length = p.frames[0]
	return animation


static func _build_disable_animation(p: Dictionary) -> Animation:
	var animation := Animation.new()
	__build_bool_track(animation, p, NodePath(
		p.node.name + ":visible"), 1)

	for mesh in p.meshes:
		if not mesh.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) + ":visible"), 3)
		__build_mesh_fade_tracks(animation, p, mesh, 0)

	for shape in p.shapes:
		if shape.disabled: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(shape.name) + ":disabled"), 2)

	for occluder in p.occluders:
		if not occluder.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(occluder.name) + ":visible"), 3)

	animation.length = p.frames[1]
	return animation


static func _build_disabled_animation(p: Dictionary) -> Animation:
	var animation := Animation.new()
	__build_bool_track(animation, p, NodePath(
		p.node.name + ":visible"), 0)

	for mesh in p.meshes:
		if not mesh.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) + ":visible"), 0)
		__build_mesh_fade_tracks(animation, p, mesh, 2)

	for shape in p.shapes:
		if shape.disabled: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(shape.name) + ":disabled"), 1)

	for occluder in p.occluders:
		if not occluder.visible: continue
		__build_bool_track(animation, p, NodePath(
			p.node.name.path_join(occluder.name) + ":visible"), 0)

	animation.length = p.frames[0]
	return animation


static func __build_bool_track(animation: Animation, p: Dictionary, path: NodePath, mode: int) -> void:
	var index := animation.get_track_count()
	animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(index, path)

	animation.track_insert_key(index, p.frames[0], bool(mode & 1))
	if bool(mode & 2): animation.track_insert_key(index, p.frames[1],
		not bool(mode & 1))

	animation.value_track_set_update_mode(index, Animation.UPDATE_DISCRETE)
	animation.track_set_interpolation_type(index, Animation.INTERPOLATION_NEAREST)
	animation.track_set_interpolation_loop_wrap(index, false)

	animation.track_set_imported(index, true)
	return


static func __build_mesh_fade_tracks(animation: Animation, p: Dictionary, mesh: MeshInstance3D, mode: int) -> void:
	if not ANIMATE_FADE_FALLBACK:
		return __build_fade_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) + ":transparency"),
				null, mode | 4)

	if not mesh.mesh: return
	for index in range(mesh.mesh.get_surface_count()):
		__build_fade_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) +
			(":mesh:surface_%s/material" % index) +
			(":shader_parameter/%s" % SHADER_FADE_PROPERTY)),
			mesh.mesh.surface_get_material(index), mode)
		__build_fade_track(animation, p, NodePath(
			p.node.name.path_join(mesh.name) +
			(":surface_material_override/%s" % index) +
			(":shader_parameter/%s" % SHADER_FADE_PROPERTY)),
			mesh.get_surface_override_material(index), mode)


static func __build_fade_track(animation: Animation, p: Dictionary, path: NodePath, material: Material, mode: int = 0) -> void:
	if not bool(mode & 4):
		if not material: return
		if not material is ShaderMaterial:
			return

	var index := animation.get_track_count()
	animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(index, path)

	if bool(mode & 1):
		if bool(mode & 2):
			animation.track_insert_key(index, p.frames[0], 0.0)
		else:
			animation.track_insert_key(index, p.frames[0], 1.0)
			animation.track_insert_key(index, p.frames[1], 0.0)
	else:
		if bool(mode & 2):
			animation.track_insert_key(index, p.frames[0], 1.0)
		else:
			animation.track_insert_key(index, p.frames[0], 0.0)
			animation.track_insert_key(index, p.frames[1], 1.0)

	if bool(mode & 2):
		animation.value_track_set_update_mode(index, Animation.UPDATE_DISCRETE)
	else: animation.value_track_set_update_mode(index, Animation.UPDATE_CONTINUOUS)
	animation.track_set_interpolation_type(index, Animation.INTERPOLATION_LINEAR)
	animation.track_set_interpolation_loop_wrap(index, false)

	animation.track_set_imported(index, true)
	return


static func _change_script(node: Node, script: GDScript) -> void:
	if not node.get_script() is GDScript: return
	var source_script: GDScript = node.get_script()
	var properties := source_script.get_script_property_list()
	var saved_properties: Dictionary = {}
	for property in properties:
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			saved_properties[property.name] = node.get(property.name)
	node.set_script(script)
	for property in saved_properties:
		if not property in node: continue
		node.set(property, saved_properties[property])


static func build_forge_game_data(entities: FileAccess) -> void:
	entities.store_string(" ".join([
		"@SolidClass",
		"=", "mining_coal", ":",
		'"coal mining node"',
		"[",
			"\n\tcursor(integer)", ":", '"mouse cursor override"', ":", "1",
			"\n\ttarget(target_destination)", ":", '"target to activate"',
			"\n\tkilltarget(target_destination)", ":", '"target to destroy"',
			"\n\ttargetname(target_source)", ":", '"entity name"',
			"\n\twait(float)", ":", '"wait time"', ":", '"-1.0"',
		"\n]\n",
	]).replace(" \n", "\n"))
