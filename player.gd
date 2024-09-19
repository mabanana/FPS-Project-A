extends CharacterBody3D
class_name PlayerEntity

@export var camera: Camera3D
@export var gun_slot: GunSlotController
@export var anim: AnimationPlayer

@export var MOUSE_SENSITIVITY = 0.001
# TODO: setup collision layers
# TODO: make proper state machine class for both player and enemy entities
# TODO: setup placeholder sprites & animations for gunplay
# TODO: add LOS points on player model for AISight to cast towards

# TODO: change these constants to variables that can be affected by character stats
const JUMP_VELOCITY = 4.5
const VERTICAL_LOOK_LIMIT = deg_to_rad(90)
const RAY_LENGTH = 1000
const SPRINT_MULTIPLIER = 1.6
const JUMP_BUFFER = 20
const SPRINT_FOV_CD = 100
const DEFAULT_CAMERA_ZOOM = 75
var rid: int
var object_in_view
var hp : int
var movement_speed: float
var input_dir: Vector2
var trigger_down : bool
@export var fov_multiplier: float
@export var fov_modifier: float

var jump_cd: Countdown
var sprint_cd: Countdown

var core: CoreModel
var core_changed: Signal

var contexts

func _ready():
	jump_cd = Countdown.new(JUMP_BUFFER)
	sprint_cd = Countdown.new(SPRINT_FOV_CD)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_dir = Vector2.ZERO

# TODO: Create input handler class not coupled with player entity
# TODO: Move all gun_slot logic away from input
	# e.g. hold trigger through reload moves state back to triggering 

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
	elif event.is_action_pressed("reload"):
		if gun_slot.active_gun:
			set_action_state(PlayerModel.ActionState.reloading)
		else:
			print("Can't reload without a gun in hand.")
	elif event.is_action_pressed("drop_equip"):
		set_action_state(PlayerModel.ActionState.throwing)
		gun_slot.drop_gun()
	elif event.is_action_pressed("interact"):
		if object_in_view.has_method("on_interact"):
			gun_slot.pickup_gun(object_in_view.on_interact(), object_in_view.rid)
		else:
			print("Nothing to interact with...")
	elif event.is_action_pressed("cycle_inventory"):
		set_action_state(PlayerModel.ActionState.idling)
		set_active_gun_index(core.inventory.active_gun_index + 1, true)
	elif event.is_action_pressed("hotkey_1"): 
		set_active_gun_index(0)
	elif event.is_action_pressed("hotkey_2"): 
		set_active_gun_index(1)
	elif event.is_action_pressed("hotkey_3"): 
		set_active_gun_index(2)
	elif event.is_action_pressed("hotkey_4"): 
		set_active_gun_index(3)
	elif event.is_action_pressed("ui_accept"):
		set_jump(true)
	elif event.is_action_pressed("sprint"):
		if !core.player.is_ads and is_ms(PlayerModel.MovementState.walking):
			set_movement_state(PlayerModel.MovementState.sprinting)
	
	if event.is_action_pressed("left_click"):
		trigger_down = true
		if !is_as(PlayerModel.ActionState.reloading) and !is_as(PlayerModel.ActionState.throwing):
			set_action_state(PlayerModel.ActionState.triggering)
	elif event.is_action_released("left_click"):
		trigger_down = false
		if is_as(PlayerModel.ActionState.triggering):
			set_action_state(PlayerModel.ActionState.idling)
	if event.is_action_pressed("right_click"):
		set_ads(true)
	elif event.is_action_released("right_click"):
		set_ads(false)

# Default Godot Template movement
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif core.player.is_jump:
		velocity.y += JUMP_VELOCITY
		set_jump(false)
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_ms(PlayerModel.MovementState.sprinting) and input_dir.y < 0:
			velocity.x = direction.x * movement_speed * SPRINT_MULTIPLIER
			velocity.z = direction.z * movement_speed * SPRINT_MULTIPLIER
		else:
			set_movement_state(PlayerModel.MovementState.walking)
			velocity.x = direction.x * movement_speed
			velocity.z = direction.z * movement_speed
	else:
		set_movement_state(PlayerModel.MovementState.standing)
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	move_and_slide()

# Avoid putting state logic into _process
func _process(delta):
	object_in_view = get_object_in_view()
	if object_in_view and object_in_view.has_method("take_damage"):
		_set_target(object_in_view.rid)
	else:
		_set_target(-1)
	if jump_cd.tick(delta) <= 0:
		set_jump(false)
	camera.fov = move_toward(camera.fov, fov_modifier + DEFAULT_CAMERA_ZOOM * fov_multiplier, 10 / fov_multiplier)

func get_object_in_view():
	var query = gun_slot.cast_ray_towards_mouse()
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.has("collider"):
		return result["collider"]

# Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed

	core_changed.connect(_on_core_changed)
	
	_on_bind()

func _on_bind():
	contexts = core.services.Context
	gun_slot.bind(core, core_changed)

func _on_core_changed(context, payload):
	if context == contexts.gun_dropped:
		set_action_state(PlayerModel.ActionState.idling)

func set_ads(boo: bool):
	if core.player.is_ads == boo:
		return
	if !(is_as(PlayerModel.ActionState.triggering) or is_as(PlayerModel.ActionState.idling)):
		core.player.is_ads = false
		return
	print("Aiming down sights set to " + ("true" if boo else "false"))
	
	if boo:
		gun_slot.set_camera_zoom(gun_slot.active_gun.metadata.zoom, true)
	else:
		gun_slot.set_camera_zoom(0, false)
	
	core.player.is_ads = boo
	core_changed.emit(contexts.none, null)
	
func set_jump(boo: bool):
	if core.player.is_jump == boo:
		return
	core.player.is_jump = boo
	if boo:
		jump_cd.reset_cd()
	core_changed.emit(contexts.none, null)

func _set_target(rid):
	core.player.target_rid = rid
	core_changed.emit(contexts.none, null)

func set_active_gun_index(index: int, is_cycle: bool = false):
	var prev_index = core.inventory.active_gun_index
	if core.inventory.active_gun_index == index:
		return
	core.inventory.active_gun_index = index
	core_changed.emit(contexts.gun_swap_started, {"is_cycle": is_cycle, "prev_index" : prev_index})

func set_action_state(state: PlayerModel.ActionState):
	if core.player.action_state == state:
		return
	var prev_state = core.player.action_state
	core.player.action_state = state
	_on_action_change(state, prev_state)
	if state == PlayerModel.ActionState.reloading:
		core_changed.emit(contexts.reload_started, null)
	else:
		core_changed.emit(contexts.none, null)

func set_movement_state(state: PlayerModel.MovementState):
	if core.player.movement_state == state:
		return
	var prev_state = core.player.movement_state
	core.player.movement_state = state
	_on_movement_change(state,  prev_state)
	core_changed.emit(contexts.none, null)

func is_ms(state: PlayerModel.MovementState):
	return core.player.movement_state == state

func is_as(state: PlayerModel.ActionState):
	return core.player.action_state == state

func _on_action_change(next_state: PlayerModel.ActionState, prev_state: PlayerModel.ActionState):
	prints("Action state changed to " + str(next_state))
	if next_state != PlayerModel.ActionState.idling:
		set_movement_state(PlayerModel.MovementState.standing)
	elif trigger_down:
		set_action_state(PlayerModel.ActionState.triggering)
	pass

func _on_movement_change(next_state: PlayerModel.MovementState, prev_state: PlayerModel.MovementState):
	prints("Movement state changed to " + str(next_state))
	if next_state == PlayerModel.MovementState.sprinting:
		sprint_cd.reset_cd()
		set_ads(false)
		set_action_state(PlayerModel.ActionState.idling)
		anim.play("sprint_fov")
	
	if prev_state == PlayerModel.MovementState.sprinting:
		if anim.current_animation:
			anim.seek(anim.get_animation(anim.current_animation).length)
	pass
