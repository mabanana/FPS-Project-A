extends Node3D
class_name GunSlot

const UNIT = 100
const RAY_LENGTH = 1000
const MAX_ACCURACY = 100
const THROW_FORCE = 10

@export var bullet_hole: PackedScene
@export var dropped_gun: PackedScene
@export var scene_entities: Node3D
var shoot_cd: int
var reload_cd: int
var reloading: bool
var new_mag: int
var trigger: bool = false
var ammo_count: int = 999999
var character: CharacterBody3D

var core: CoreModel
var core_changed: Signal

func _ready():
	reload_cd = 0
	reloading = false
	shoot_cd = 0
	character = get_parent()

func set_shoot_cd():
	shoot_cd = 100/core.inventory.active_gun.metadata.fire_rate

func _process(delta):
	if not core.inventory.active_gun:
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
	if shoot_cd <= 0 and core.inventory.active_gun.ammo_count > 0 and not reloading:
		set_shoot_cd()
		return true
	else:
		return false

func finish_reload():
	_update_ammo(new_mag)
	new_mag = 0

func reload():
	if not core.inventory.active_gun:
		return
	new_mag = min(ammo_count, core.inventory.active_gun.metadata.ammo_capacity)
	ammo_count -= new_mag - core.inventory.active_gun.ammo_count
	reloading = true
	reload_cd = UNIT * core.inventory.active_gun.metadata.reload_time

func handle_gun_shot(view_direction):
	if not (core.inventory.active_gun and shoot()):
		return
	_update_ammo(core.inventory.active_gun.ammo_count - 1)
	var space_state = get_world_3d().direct_space_state
	var mousepos = bullet_spread(get_viewport().get_mouse_position(), core.inventory.active_gun.metadata.accuracy)
	var query_vector = get_vector_points_towards_camera_direction(mousepos, RAY_LENGTH)
	var query = PhysicsRayQueryParameters3D.create(query_vector["origin"], query_vector["end"])
	query.collide_with_areas = false
	var result = space_state.intersect_ray(query)
	if result:
		var new_bullet_hole = bullet_hole.instantiate()
		new_bullet_hole.position = result.position
		# TODO: create node for decals like bullet hole instances to spawn in.
		scene_entities.add_child(new_bullet_hole)
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(randf_range(core.inventory.active_gun.metadata.damage_floor, core.inventory.active_gun.metadata.damage_ceiling), self, result.position)

func bullet_spread(mousepos, acc):
	var spread = MAX_ACCURACY - acc
	return Vector2(mousepos.x + randf_range(-spread,spread), mousepos.y + randf_range(-spread,spread))

func drop_gun():
	if not core.inventory.active_gun:
		return
	var new_dropped_gun: Interactable = dropped_gun.instantiate()
	new_dropped_gun.gun_model = core.inventory.active_gun
	_remove_active_gun()
	var throw_vector_dict = get_vector_points_towards_camera_direction(get_viewport().get_mouse_position(),THROW_FORCE)
	var throw_vector = throw_vector_dict["end"] - throw_vector_dict["origin"]
	new_dropped_gun.position = character.position + throw_vector.normalized()
	new_dropped_gun.apply_central_impulse(throw_vector)
	scene_entities.add_child(new_dropped_gun)
	reloading = false
	shoot_cd = false
	trigger = false

func get_vector_points_towards_camera_direction(dir: Vector2, magnitude: int) -> Dictionary:
	var output = {}
	output["origin"] = character.camera.project_ray_origin(dir)
	output["end"] = output["origin"] + character.camera.project_ray_normal(dir) * magnitude
	return output

# MARK: - Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed

	core_changed.connect(_on_core_changed)

func _on_core_changed():
	if core.inventory.active_gun:
		print("Ammo is currently at: ", core.inventory.active_gun.ammo_count)
	else:
		print("No gun equipped")

# MARK: - Actions

func _add_active_gun(gun_model: GunModel) -> void:
	core.inventory.guns.insert(0, gun_model)
	core_changed.emit()

func _remove_active_gun() -> void:
	core.inventory.guns.remove_at(0)
	core_changed.emit()

func _update_ammo(ammo_count: int) -> void:
	core.inventory.active_gun.ammo_count = ammo_count
	core_changed.emit()
