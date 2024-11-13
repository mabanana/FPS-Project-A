class_name GunPreviewViewport
extends SubViewportContainer

var is_pressed: bool
var click_pos: Vector2
var gun_mesh: MeshInstance3D
var prev_rotation: Vector3
var current_mesh: ArrayMesh

const DEFAULT_ROTATION = Vector3(0,deg_to_rad(90),0)

# Called when the node enters the scene tree for the first time.
func _ready():
	gun_mesh = %TutorialModel
	$SubViewport.own_world_3d = true
	visibility_changed.connect(reset_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_pressed:
		var mouse_rel = (get_viewport().get_mouse_position() - click_pos) * 0.05 * delta
		mouse_rel = Vector3(0, mouse_rel.x, mouse_rel.y)
		var rel = gun_mesh.rotation - (mouse_rel+prev_rotation)
		gun_mesh.rotate_y(mouse_rel.y)
		gun_mesh.rotate_x(mouse_rel.z)

func _on_mouse_pressed(event):
	is_pressed = true
	prev_rotation = gun_mesh.rotation
	click_pos = get_viewport().get_mouse_position()

func _on_mouse_released(event):
	is_pressed = false

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			_on_mouse_released(event)
		elif event.is_pressed():
			_on_mouse_pressed(event)

func update_mesh(mesh):
	%TutorialModel.mesh = mesh

func reset_rotation():
	gun_mesh.rotation = DEFAULT_ROTATION
