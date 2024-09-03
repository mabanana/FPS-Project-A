extends Node3D
class_name GunSlot

const UNIT = 100
const RAY_LENGTH = 1000
const MAX_ACCURACY = 100
const THROW_FORCE = 10

@export var gun: Gun
@export var dropped_gun: PackedScene
@export var scene_entities: Node3D
var shoot_cd: int
var reload_cd: int
var reloading: bool
var new_mag: int
var trigger: bool = false
var ammo_count: int = 999999
var character: CharacterBody3D

func _ready():
	reload_cd = UNIT * gun.gun_resource.reload_time
	reloading = false
	shoot_cd = 0
	character = get_parent()

func set_shoot_cd():
	shoot_cd = 100/gun.gun_resource.fire_rate

func _process(delta):
	if not gun:
		return
	if shoot_cd > 0:
		shoot_cd -= UNIT * delta
	if reloading:
		if reload_cd > 0:
			reload_cd -= UNIT * delta
		else:
			reloading = false
			finish_reload()
	if trigger:
		handle_gun_shot((Vector3(character.camera.rotation.x, rotation.y, 0)))

func shoot():
	if shoot_cd <= 0 and gun.mag_curr > 0 and not reloading:
		set_shoot_cd()
		return true
	else:
		return false

func finish_reload():
	gun.mag_curr = new_mag
	new_mag = 0

func reload():
	if not gun:
		return
	new_mag = min(ammo_count, gun.gun_resource.mag_size)
	ammo_count -= new_mag - gun.mag_curr
	reloading = true
	reload_cd = UNIT * gun.gun_resource.reload_time
	
func handle_gun_shot(view_direction):
	if not (gun and shoot()):
		return
	gun.mag_curr -= 1
	var space_state = get_world_3d().direct_space_state
	var mousepos = bullet_spread(get_viewport().get_mouse_position(), gun.gun_resource.accuracy)
	var query_vector = get_vector_points_towards_camera_direction(mousepos, RAY_LENGTH)
	var query = PhysicsRayQueryParameters3D.create(query_vector["origin"], query_vector["end"])
	query.collide_with_areas = false
	var result = space_state.intersect_ray(query)
	if result:
		var new_bullet_hole = gun.gun_resource.bullet_hole.instantiate()
		new_bullet_hole.position = result.position
		# TODO: create node for decals like bullet hole instances to spawn in.
		scene_entities.add_child(new_bullet_hole)
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(randf_range(gun.gun_resource.damage_floor, gun.gun_resource.damage_ceiling), self, result.position)

func bullet_spread(mousepos, acc):
	var spread = MAX_ACCURACY - acc
	return Vector2(mousepos.x + randf_range(-spread,spread), mousepos.y + randf_range(-spread,spread))

func drop_gun():
	if not gun:
		return
	var new_dropped_gun: Interactable = dropped_gun.instantiate()
	gun.reparent(new_dropped_gun)
	new_dropped_gun.resource_node = gun
	var throw_vector_dict = get_vector_points_towards_camera_direction(get_viewport().get_mouse_position(),THROW_FORCE)
	var throw_vector = throw_vector_dict["end"] - throw_vector_dict["origin"]
	new_dropped_gun.position = character.position + throw_vector.normalized()
	new_dropped_gun.apply_central_impulse(throw_vector)
	print("Gun Slot: ", gun.name, " has been dropped.")
	gun = null
	scene_entities.add_child(new_dropped_gun)
	reloading = false
	shoot_cd = false
	trigger = false


func pickup_and_equip_gun(new_gun: Gun):
	new_gun.reparent(character.inventory)
	gun = new_gun
	print("Gun Slot: ", gun.name, " has been equipped.")

func get_vector_points_towards_camera_direction(dir: Vector2, magnitude: int) -> Dictionary:
	var output = {}
	output["origin"] = character.camera.project_ray_origin(dir)
	output["end"] = output["origin"] + character.camera.project_ray_normal(dir) * magnitude
	return output
