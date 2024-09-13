extends CharacterBody3D
class_name PlayerEntity

var camera: Camera3D
var gun_slot: GunSlotController
var untracked_entities: Node3D

@export var MOUSE_SENSITIVITY = 0.001
# TODO: change these constants to variables that can be affected by character stats
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const VERTICAL_LOOK_LIMIT = deg_to_rad(90)
const RAY_LENGTH = 1000
const SPRINT_MULTIPLIER = 1.6
var id: int
var object_in_view
var hp : int = 100
var input_dir

var core: CoreModel
var core_changed: Signal

var contexts

func _ready():
	camera = %Camera3D
	gun_slot = %GunSlot
	untracked_entities = %UntrackedEntities
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_dir = Vector2.ZERO

# TODO: Create input handler class not coupled with player entity
func _input(event):
	# Camera Controls via mouse
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clampf(camera.rotation.x, -VERTICAL_LOOK_LIMIT, VERTICAL_LOOK_LIMIT)
		rotate_object_local(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)
	
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# TODO: implement pause functionality
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Button Inputs
	# TODO: add number button weapon swap
	# TODO: add sprint
	elif event.is_action_pressed("reload"):
		if gun_slot.active_gun:
			set_action_state(PlayerModel.ActionState.reloading)
		else:
			print("Can't reload without a gun in hand.")
	elif event.is_action_pressed("drop_equip"):
		set_action_state(PlayerModel.ActionState.idling)
		gun_slot.drop_gun()
	elif event.is_action_pressed("interact"):
		if object_in_view.has_method("on_interact"):
			gun_slot.pickup_gun(object_in_view.on_interact(), object_in_view.id)
		else:
			print("Nothing to interact with...")
	elif event.is_action_pressed("cycle_inventory"):
		set_action_state(PlayerModel.ActionState.idling)
		gun_slot.cycle_next_active_gun()
	elif event.is_action_pressed("ui_accept") and is_on_floor():
		set_jump(true)
	elif event.is_action_pressed("sprint"):
		set_movement_state(PlayerModel.MovementState.sprinting)
	
	if event.is_action_pressed("left_click"):
		if core.player.action_state != PlayerModel.ActionState.reloading:
			set_action_state(PlayerModel.ActionState.triggering)
	elif event.is_action_released("left_click"):
		if core.player.action_state == PlayerModel.ActionState.triggering:
			set_action_state(PlayerModel.ActionState.idling)
	if event.is_action_pressed("right_click"):
		set_ads(true)
	elif event.is_action_released("right_click"):
		set_ads(false)

# Default Godot Template movement
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_ms(PlayerModel.MovementState.sprinting):
			velocity.x = direction.x * SPEED * SPRINT_MULTIPLIER
			velocity.z = direction.z * SPEED * SPRINT_MULTIPLIER
		else:
			set_movement_state(PlayerModel.MovementState.walking)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		set_movement_state(PlayerModel.MovementState.standing)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# Avoid putting state logic into _process
func _process(delta):
	object_in_view = get_object_in_view()

func get_object_in_view():
	var query = gun_slot.cast_ray_towards_mouse()
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.has("collider"):
		return result["collider"]

# Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context

	core_changed.connect(_on_core_changed)
	gun_slot.bind(core, core_changed)

func _on_core_changed(context, payload):
	if core.player.is_jump:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		set_jump(false)

func set_ads(boo: bool):
	core.player.is_ads = boo
	core_changed.emit(contexts.none, null)
	
func set_jump(boo: bool):
	core.player.is_jump = boo
	core_changed.emit(contexts.none, null)

func set_action_state(state: PlayerModel.ActionState):
	_on_action_change(state)
	core.player.action_state = state
	if state == PlayerModel.ActionState.reloading:
		core_changed.emit(contexts.reload_start, null)
	else:
		core_changed.emit(contexts.none, null)

func set_movement_state(state: PlayerModel.MovementState):
	if core.player.movement_state == state:
		return
	_on_movement_change(state)
	core.player.movement_state = state
	core_changed.emit(contexts.none, null)

func is_ms(state: PlayerModel.MovementState):
	return core.player.movement_state == state

func is_as(state: PlayerModel.MovementState):
	return core.player.action_state == state

func _on_action_change(state: PlayerModel.ActionState):
	prints("Action state changed to " + str(state))
	pass

func _on_movement_change(state: PlayerModel.MovementState):
	prints("Movement state changed to " + str(state))
	pass
