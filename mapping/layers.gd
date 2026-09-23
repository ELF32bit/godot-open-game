class_name LAYERS

const RENDER_2D: Dictionary = {}
const RENDER_3D: Dictionary = {}

const PHYSICS_2D: Dictionary = {}
const PHYSICS_3D: Dictionary = {
	"worldspawn/StaticBody3D": [(1<<0), 0],
	"func_liquid/Node3D/Area3D": [(1<<1), (1<<2) | (1<<4)],
	"func_liquid/Node3D/Area3D-Objects!": [(1<<2), null],
	"func_liquid/Node3D/AnimatableBody3D": [(1<<3), 0],
	"func_breakable/Node3D/RigidBody3D": [(1<<4), (1<<4) | (1<<0)],
	"func_plat/Node3D/Area3D": [(1<<5), (1<<6)],
	"func_plat/Node3D/Area3D-Objects!": [(1<<6), null],
	"func_door/Node3D/Area3D": [(1<<7), (1<<8)],
	"func_door/Node3D/Area3D-Objects!": [(1<<8), null],
	"trigger_once/Area3D": [(1<<9), (1<<10)],
	"trigger_once/Area3D-Objects!": [(1<<10), null],
	"trigger_multiple/Area3D": [(1<<11), (1<<12)],
	"trigger_multiple/Area3D-Objects!": [(1<<12), null],
	"trigger_teleport/Area3D": [(1<<13), (1<<14)],
	"trigger_teleport/Area3D-Objects!": [(1<<14), null],
	"trigger_push/Area3D": [(1<<15), (1<<16) | (1<<4)],
	"trigger_push/Area3D-Objects": [(1<<16), null],
	# below are already defined layers for simple entities
	"func_button/AnimatableBody3D": [(1<<0) | (1<<31), 0],
	"func_plat/Node3D/AnimatableBody3D": [(1<<0), 0],
	"func_door/Node3D/AnimatableBody3D": [(1<<0), 0],
	"func_door_secret/AnimatableBody3D": [(1<<0), 0],
	"func_signpost/AnimatableBody3D": [(1<<0) | (1<<31), 0],
	"func_train/AnimatableBody3D": [(1<<0), 0],
}

const NAVIGATION_2D: Dictionary = {}
const NAVIGATION_3D: Dictionary = {}


static func set_audio_stream_player_area_mask(node: AudioStreamPlayer3D) -> void:
	node.area_mask = PHYSICS_3D["func_liquid/Node3D/Area3D"][0]
