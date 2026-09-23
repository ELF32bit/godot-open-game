class_name LAYERS

const RENDER_2D: Dictionary = {}
const RENDER_3D: Dictionary = {}

const PHYSICS_2D: Dictionary = {}
const PHYSICS_3D: Dictionary = {
	"worldspawn/StaticBody3D": [(1<<0), 0],
	"func_liquid/Node3D/Area3D": [(1<<1), (1<<2)],
	"func_liquid/Node3D/Area3D-Objects!": [(1<<2), null],
	"func_liquid/Node3D/AnimatableBody3D": [(1<<3), 0],

	# worldspawn
	"func_door/Node3D/AnimatableBody3D": [(1<<0), 0],
	"func_door_secret/AnimatableBody3D": [(1<<0), 0],
	"func_plat/Node3D/AnimatableBody3D": [(1<<0), 0],
	"func_train/AnimatableBody3D": [(1<<0), 0],
	"func_rotor/AnimatableBody3D": [(1<<0), 0],

	# selectable worldspawn
	"func_button/AnimatableBody3D": [(1<<0) | (1<<31), 0],
	"func_signpost/AnimatableBody3D": [(1<<0) | (1<<31), 0],

	# functional
	"func_door/Node3D/Area3D": [0, (1<<4)],
	"func_door/Node3D/Area3D-Objects!": [(1<<4), null],
	"func_plat/Node3D/Area3D": [0, (1<<5)],
	"func_plat/Node3D/Area3D-Objects!": [(1<<5), null],

	"func_breakable/Node3D/RigidBody3D": [
		(1<<8) | (1<<2) | (1<<18) | (1<<19),
		(1<<8) | (1<<0)],

	# triggers
	"trigger_once/Area3D": [0, (1<<16)],
	"trigger_once/Area3D-Objects!": [(1<<16), null],
	"trigger_multiple/Area3D": [0, (1<<17)],
	"trigger_multiple/Area3D-Objects!": [(1<<17), null],
	"trigger_teleport/Area3D": [0, (1<<18)],
	"trigger_teleport/Area3D-Objects!": [(1<<18), null],
	"trigger_push/Area3D": [0, (1<<19)],
	"trigger_push/Area3D-Objects": [(1<<19), null],

	# survival
	"survival_rock/Node3D/Area3D": [0, (1<<24)],
	"survival_rock/Node3D/Area3D-Objects!": [(1<<24), null],
	"survival_rock/Node3D/AnimatableBody3D": [(1<<0) | (1<<31), 0],

	"survival_tree/Node3D/Area3D": [0, (1<<24)],
	"survival_tree/Node3D/Area3D-Objects!": [(1<<24), null],
	"survival_tree/Node3D/AnimatableBody3D": [(1<<0) | (1<<31), 0],

	# mining
	"mining_coal/Node3D/Area3D": [0, (1<<24)],
	"mining_coal/Node3D/Area3D-Objects!": [(1<<24), null],
	"mining_coal/Node3D/AnimatableBody3D": [(1<<0) | (1<<31), 0],

	"mining_iron/Node3D/Area3D": [0, (1<<24)],
	"mining_iron/Node3D/Area3D-Objects!": [(1<<24), null],
	"mining_iron/Node3D/AnimatableBody3D": [(1<<0) | (1<<31), 0],

	"mining_silver/Node3D/Area3D": [0, (1<<24)],
	"mining_silver/Node3D/Area3D-Objects!": [(1<<24), null],
	"mining_silver/Node3D/AnimatableBody3D": [(1<<0) | (1<<31), 0],

	"mining_gold/Node3D/Area3D": [0, (1<<24)],
	"mining_gold/Node3D/Area3D-Objects!": [(1<<24), null],
	"mining_gold/Node3D/AnimatableBody3D": [(1<<0) | (1<<31), 0],
}

const NAVIGATION_2D: Dictionary = {}
const NAVIGATION_3D: Dictionary = {}


static func set_audio_stream_player_area_mask(node: AudioStreamPlayer3D) -> void:
	node.area_mask = PHYSICS_3D["func_liquid/Node3D/Area3D"][0]
