extends Node3D
class_name GunSlot

const UNIT = 100
const RAY_LENGTH = 1000
const MAX_ACCURACY = 100
const ACCURACY_FLOOR = 25
const THROW_FORCE = 50
const THROW_ACCURACY = 69

@export var bullet_hole: PackedScene
@export var dropped_gun: PackedScene
@onready var scene_entities: Node3D = %SceneEntities
var shoot_cd: int
var reload_cd: int
var reloading: bool
var trigger: bool = false
var character: CharacterBody3D

var core: CoreModel
var core_changed: Signal

func _ready():
	reload_cd = 0
	reloading = false
	shoot_cd = 0
	character = get_parent()

func _process(delta):
	if not core.inventory.active_gun:
		return
	if shoot_cd > 0:
		shoot_cd -= UNIT * delta
	if reloading:
		if reload_cd > 0:
			reload_cd -= UNIT * delta
		else:
			finish_reload()
	if trigger:
		shoot()

func finish_reload():
	var new_mag = min(core.inventory.ammo, core.inventory.active_gun.metadata.mag_size)
	_set_ammo(core.inventory.ammo - new_mag + core.inventory.active_gun.mag_curr)
	_set_reload(false)
	_update_ammo(new_mag)

func reload():
	if not core.inventory.active_gun or core.inventory.active_gun.metadata.mag_size == core.inventory.active_gun.mag_curr:
		return
	_set_reload(true)
	reload_cd = UNIT * core.inventory.active_gun.metadata.reload_time

func shoot():
	if shoot_cd <= 0 and core.inventory.active_gun.mag_curr > 0 and not reloading:
		shoot_cd = 100/core.inventory.active_gun.metadata.fire_rate
	else:
		return
	_update_ammo(core.inventory.active_gun.mag_curr - 1)
	var query = cast_ray_towards_mouse(core.inventory.active_gun.metadata.accuracy)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		var new_bullet_hole = bullet_hole.instantiate()
		new_bullet_hole.position = result.position
		%UntrackedEntities.add_child(new_bullet_hole)
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(core.inventory.active_gun.metadata.damage_floor, core.inventory.active_gun.metadata.damage_ceiling, character, result.position)

func pickup_gun(gun):
	_add_to_guns(gun)

func drop_gun():
	if not core.inventory.active_gun:
		return
	var new_dropped_gun = dropped_gun.instantiate()
	new_dropped_gun.gun_model = core.inventory.active_gun
	_remove_active_gun()
	cycle_next_active_gun()
	var throw_vector = inaccuratize_vector(-character.camera.get_global_transform().basis.z.normalized(), THROW_ACCURACY)
	new_dropped_gun.position = character.position + throw_vector
	new_dropped_gun.linear_velocity = throw_vector * THROW_FORCE / new_dropped_gun.mass
	new_dropped_gun.angular_velocity = throw_vector.cross(Vector3.UP) * THROW_FORCE / new_dropped_gun.mass
	scene_entities.add_child(new_dropped_gun)
	
func cycle_next_active_gun():
	_set_active_gun(core.inventory.active_gun_index + 1)
	_set_reload(false)
	shoot_cd = false
	trigger = false

func inaccuratize_vector(vector, acc):
	var rot = deg_to_rad(ACCURACY_FLOOR * (MAX_ACCURACY - acc) / 100)
	return vector.rotated(Vector3.UP, randf_range(-rot,rot)).rotated(Vector3.BACK, randf_range(-rot,rot)).rotated(Vector3.RIGHT, randf_range(-rot,rot)) 

func cast_ray_towards_mouse(accuracy: int = MAX_ACCURACY, ray_length: int = RAY_LENGTH):
	var mousepos = get_viewport().get_mouse_position()
	var origin = character.camera.project_ray_origin(mousepos)
	var cast_vector = character.camera.project_ray_normal(mousepos) * RAY_LENGTH
	var end = origin + inaccuratize_vector(cast_vector, accuracy)
	return PhysicsRayQueryParameters3D.create(origin, end)

# MARK: - Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed

	core_changed.connect(_on_core_changed)

func _on_core_changed():
	if not core.inventory.active_gun:
		print("No gun equipped")

# MARK: - Actions

func _add_to_guns(gun_model: GunModel) -> void:
	core.inventory.guns.append(gun_model)
	core_changed.emit()

func _remove_active_gun() -> void:
	core.inventory.guns.remove_at(core.inventory.active_gun_index)
	while core.inventory.active_gun_index > len(core.inventory.guns) - 1 and core.inventory.active_gun_index > 0:
		core.inventory.active_gun_index -= 1
	core_changed.emit()

func _update_ammo(mag_curr: int) -> void:
	core.inventory.active_gun.mag_curr = mag_curr
	core_changed.emit()

func _set_reload(boo: bool = true):
	reloading = boo
	core.player.reloading = boo
	core_changed.emit()

func _set_ammo(new_ammo: int):
	core.inventory.ammo = new_ammo
	core_changed.emit()

func _set_active_gun(index: int):
	core.inventory.active_gun_index = index if index <= len(core.inventory.guns) - 1 and index >= 0 else 0
	core_changed.emit()
