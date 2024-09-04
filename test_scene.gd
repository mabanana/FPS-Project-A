extends Node3D

var core: CoreModel
signal core_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate core
	core = CoreModel.new()
	# Add bindings to all relevant observers
	%Player.bind(core, core_changed)
	# Set up initial state
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_A))
	# Emit initial state to all observers
	core_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
