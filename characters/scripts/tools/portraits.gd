@tool
extends Node3D

@export var generate: bool = false:
	set(value):
		if value == false: return
		elif not is_instance_valid(viewport): return
		elif not generate_automatic: _capture_portrait()
		else: push_warning("Can't generate portrait while automatic!")

@export var generate_suffix: String = ""
@export var generate_automatic: bool = true
@export var image_path: String = ""

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/Camera3D


func _ready() -> void:
	if not Engine.is_editor_hint():
		return _cleanup()
	elif not generate_automatic:
		return
	elif owner == null: return
	var parent := owner.get_parent()
	if not parent is SubViewport: return
	if not parent.name.begins_with("@"): return
	update_capture_transform(owner)
	_capture_portrait()


func update_capture_transform(node: Node3D = owner) -> void:
	if not is_instance_valid(node): return
	if not node.has_meta("AABB"): return
	var aabb: AABB = node.get_meta("AABB", AABB())
	transform = Transform3D.IDENTITY
	var center := aabb.get_center()

	transform.origin = center
	transform.origin.z -= aabb.size.z * 2.5
	transform.origin.y += aabb.size.y * 0.55
	transform = transform.rotated_local(Vector3.UP, deg_to_rad(180.0))
	transform = transform.rotated(Vector3.UP, deg_to_rad(-30.0))
	transform = transform.looking_at(center +
		Vector3.UP * aabb.size.y * 0.25)


func _capture_portrait() -> void:
	var file_path := String("%s%s.png" %
		[image_path, generate_suffix])
	await RenderingServer.frame_post_draw
	var texture := viewport.get_texture()
	var image := texture.get_image()
	image.save_png(file_path)
	_update_filesystem(file_path)


func _update_filesystem(file_path: String) -> void:
	var editor_interface := Engine.get_singleton("EditorInterface")
	if not editor_interface: return

	var filesystem: Variant = (
		editor_interface.get_resource_filesystem())
	filesystem.update_file(file_path)
	filesystem.reimport_files([file_path])

	var config := ConfigFile.new()
	var import_path := String("%s.import" % file_path)
	if not FileAccess.file_exists(import_path): return
	var error := config.load(import_path)
	if error == OK:
		config.set_value("params", "compress/mode", 3)
		config.save(import_path)
		filesystem.reimport_files([file_path])


func _cleanup() -> void:
	for child in get_children():
		child.queue_free()
