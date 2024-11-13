extends CharacterBody3D
class_name PlayerEntity

@export var camera: Camera3D
@export var gun_slot: GunSlotController
@export var anim: AnimationPlayer
@export var head_joint: Node3D

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

var eye_pos
var max_gun_slots = 4
var rid: int
var object_in_view
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
var input_handler: InputHandler

func _ready():
	jump_cd = Countdown.new(JUMP_BUFFER)
	sprint_cd = Countdown.new(SPRINT_FOV_CD)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_dir = Vector2.ZERO
	eye_pos = camera.position
	head_joint = %HeadJoint
	gun_slot.character = self

# TODO: Move all gun_slot logic away from input
	# e.g. hold trigger through reload moves state back to triggering 
# BUG: Camera rotation tied to pixels travelled by mouse instead of % viewport travelled
func _rotate_camera(x, y, z):
	head_joint.rotate_x(-y * MOUSE_SENSITIVITY)
	head_joint.rotation.x = clampf(head_joint.rotation.x, -VERTICAL_LOOK_LIMIT, VERTICAL_LOOK_LIMIT)
	rotate_object_local(Vector3.UP, -x * MOUSE_SENSITIVITY)

func _input(event: InputEvent):
	input_handler.handle_input(event)
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

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
	if object_in_view and object_in_view is InteractableEntity:
		_set_interact_target(object_in_view.rid)
	else:
		_set_interact_target(-1)
	
	
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
	# TODO make input handler child of game manager instead of player
	input_handler = InputHandler.new()
	input_handler.bind(core, core_changed)
	gun_slot.bind(core, core_changed)

func _on_core_changed(context, payload):
	if context == contexts.gun_dropped:
		set_action_state(PlayerModel.ActionState.idling)
	elif context == contexts.event_mouse_moved:
		var relative = payload["relative"]
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_rotate_camera(relative.x, relative.y, 0)
	elif context == contexts.event_input_pressed:
		var action_pressed = payload["action"]
		match action_pressed:
			InputHandler.PlayerActions.FIRE:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					trigger_down = true
					if !is_as(PlayerModel.ActionState.reloading) and !is_as(PlayerModel.ActionState.throwing):
						set_action_state(PlayerModel.ActionState.triggering)
			InputHandler.PlayerActions.NEXT_WEAPON:
				set_action_state(PlayerModel.ActionState.idling)
				set_active_gun_index(core.inventory.active_gun_index + 1, true)
			InputHandler.PlayerActions.PREV_WEAPON:
				set_action_state(PlayerModel.ActionState.idling)
				set_active_gun_index(core.inventory.active_gun_index - 1, true)
			InputHandler.PlayerActions.MOVE_FORWARD:
				print("move forward")
			InputHandler.PlayerActions.MOVE_BACKWARD:
				print("move backward")
			InputHandler.PlayerActions.MOVE_LEFT:
				print("move left")
			InputHandler.PlayerActions.MOVE_RIGHT:
				print("move right")
			InputHandler.PlayerActions.JUMP:
				set_jump(true)
			InputHandler.PlayerActions.SPRINT:
				if !core.player.is_ads and is_ms(PlayerModel.MovementState.walking):
					set_movement_state(PlayerModel.MovementState.sprinting)
			InputHandler.PlayerActions.CROUCH:
				print("crouch")
			InputHandler.PlayerActions.RELOAD:
				if gun_slot.active_gun:
					if core.inventory.active_gun.mag_curr < core.inventory.active_gun.metadata.mag_size:
						set_action_state(PlayerModel.ActionState.reloading)
					else:
						print("Mag already full")
				else:
					print("Can't reload without a gun in hand.")
			InputHandler.PlayerActions.ADS:
				set_ads(true)
			InputHandler.PlayerActions.INTERACT:
				# TODO: interact through signal emit instead of direct reference of object
				if object_in_view and object_in_view.has_method("on_interact"):
					core_changed.emit(contexts.gun_pickup_started, 
					{"gun_model": object_in_view.gun_model, "rid": rid, "target_rid": object_in_view.rid})
					var linear_velocity = GunSlotController.inaccuratize_vector(Vector3.UP, 60) * 5
					var angular_velocity = linear_velocity.cross(Vector3.UP).normalized() * 5
					object_in_view.linear_velocity = linear_velocity
					object_in_view.angular_velocity = angular_velocity
				else:
					print("Nothing to interact with...")
			InputHandler.PlayerActions.MELEE:
				print("melee")
			InputHandler.PlayerActions.SELECT_SlOT_1:
				set_active_gun_index(0)
			InputHandler.PlayerActions.SELECT_SlOT_2:
				set_active_gun_index(1)
			InputHandler.PlayerActions.SELECT_SlOT_3:
				set_active_gun_index(2)
			InputHandler.PlayerActions.SELECT_SlOT_4:
				set_active_gun_index(3)
			InputHandler.PlayerActions.ESC_MENU:
				# TODO: implement pause functionality
				core_changed.emit(contexts.mouse_capture_toggled, null)
			InputHandler.PlayerActions.GAME_MENU:
				print("open game menu")
			InputHandler.PlayerActions.DROP_GUN:
				set_action_state(PlayerModel.ActionState.throwing)
				core_changed.emit(contexts.gun_drop_started, {"rid": rid})
			_:
				print("unhandled action press")
	elif context == contexts.event_input_released:
		var action_released = payload["action"]
		match action_released:
			InputHandler.PlayerActions.FIRE:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					trigger_down = false
					if is_as(PlayerModel.ActionState.triggering):
						set_action_state(PlayerModel.ActionState.idling)
			InputHandler.PlayerActions.MOVE_FORWARD:
				print("stop move forward")
			InputHandler.PlayerActions.MOVE_BACKWARD:
				print("stop move backward")
			InputHandler.PlayerActions.MOVE_LEFT:
				print("stop move left")
			InputHandler.PlayerActions.MOVE_RIGHT:
				print("stop move right")
			InputHandler.PlayerActions.JUMP:
				print("jump released")
			InputHandler.PlayerActions.SPRINT:
				print("sprint released")
			InputHandler.PlayerActions.CROUCH:
				print("crouch released")
			InputHandler.PlayerActions.RELOAD:
				print("reload released")
			InputHandler.PlayerActions.ADS:
				set_ads(false)
			InputHandler.PlayerActions.INTERACT:
				print("interact released")
			InputHandler.PlayerActions.MELEE:
				print("melee released")
			InputHandler.PlayerActions.DROP_GUN:
				print("drop gun released")
			_:
				pass
				#print("unhandled action release")


func set_ads(boo: bool):
	if core.player.is_ads == boo:
		return
	if !(is_as(PlayerModel.ActionState.triggering) or is_as(PlayerModel.ActionState.idling)):
		core.player.is_ads = false
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
	
func _set_interact_target(rid):
	core.player.interact_rid = rid
	core_changed.emit(contexts.none, null)

func set_active_gun_index(index: int, cycle = false):
	if index > max_gun_slots - 1 or index > len(core.inventory.guns) - 1:
		if cycle:
			index = 0
		else:
			return
	if core.inventory.active_gun_index == index:
		return
	elif index < 0:
		if cycle:
			index = min(len(core.inventory.guns) - 1, max_gun_slots - 1)
		else:
			return
	core.inventory.active_gun_index = index
	set_ads(false)
	core_changed.emit(contexts.gun_swap_started, null)

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
	if !(next_state == PlayerModel.ActionState.triggering or next_state == PlayerModel.ActionState.idling):
		set_ads(false)

func _on_movement_change(next_state: PlayerModel.MovementState, prev_state: PlayerModel.MovementState):
	prints("Movement state changed to " + str(next_state))
	if next_state == PlayerModel.MovementState.sprinting:
		sprint_cd.reset_cd()
		set_ads(false)
		set_action_state(PlayerModel.ActionState.idling)
		#anim.play("sprint_fov")
	
	if prev_state == PlayerModel.MovementState.sprinting:
		if anim.current_animation:
			anim.seek(anim.get_animation(anim.current_animation).length)
	pass
