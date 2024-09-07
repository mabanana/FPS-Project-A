extends CharacterBody3D
class_name PlayerEntity

@onready var camera = %Camera3D
@onready var gun_slot = %GunSlot
@onready var inventory = %Inventory
@export var MOUSE_SENSITIVITY = 0.001
# TODO: change these constants to variables that can be affected by character stats
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const VERTICAL_LOOK_LIMIT = 89.0
const RAY_LENGTH = 1000
var id: int
var object_in_view
var hp : int = 100

var core: CoreModel
var core_changed: Signal

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# TODO: Create input handler class not coupled with player entity
func _input(event):
	# Camera Controls via mouse
	# TODO: remove redundant CameraControl Node
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		rotate_object_local(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)
		
	# TODO: implement pause functionality
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Button Inputs
	elif event.is_action_pressed("reload"):
		gun_slot.reload()
	elif event.is_action_pressed("drop_equip"):
		gun_slot.drop_gun()
	elif event.is_action_pressed("interact"):
		if object_in_view.has_method("on_interact"):
			gun_slot.pickup_gun(object_in_view.on_interact(), object_in_view.id)
	elif event.is_action_pressed("cycle_inventory"):
		gun_slot.cycle_next_active_gun()
	if event.is_action_pressed("left_click"):
		gun_slot.trigger = true
	elif event.is_action_released("left_click"):
		gun_slot.trigger = false

# Default Godot Template movement
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# Avoid putting state logic into _process
func _process(delta):
	object_in_view = get_object_in_view()

func get_object_in_view():
	var query = gun_slot.cast_ray_towards_mouse()
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		return result["collider"]

# MARK: - Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed

	core_changed.connect(_on_core_changed)
	gun_slot.bind(core, core_changed)

func _on_core_changed(context, payload):
	pass
