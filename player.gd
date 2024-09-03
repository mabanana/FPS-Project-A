extends CharacterBody3D

@onready var camera = %Camera3D
@onready var gun_slot = %GunSlot
@onready var hud = $"../UI"
@export var MOUSE_SENSITIVITY = 0.001
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const VERTICAL_LOOK_LIMIT = 89.0
const RAY_LENGTH = 1000

var hp : int = 100


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		rotate_object_local(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("left_click"):
		gun_slot.trigger = true
		
	elif event.is_action_released("left_click"):
		gun_slot.trigger = false
	elif event.is_action_pressed("reload"):
		gun_slot.reload()
		

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
	
func _process(delta):
	hud.mag = gun_slot.gun.mag_curr
	hud.ammo = gun_slot.ammo_count
	hud.hp = hp
	hud.reload = gun_slot.reloading
	hud.update()
	var object_in_view = get_object_in_view()

func get_object_in_view():
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if result:
		return result["collider"].name
