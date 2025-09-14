extends Node3D
# TODO: move this entire node into a instance in PlayerEntity
class_name GunSlotController

# TODO: Move constants to singleton
const UNIT = 100
const RAY_LENGTH = 1000
const MAX_ACCURACY = 100
const ACCURACY_FLOOR = 25
const THROW_FORCE = 50
const THROW_ACCURACY = 69
const CAST_ACCURACY = 85
const ADS_CAST_ACCURACY = 92

var shoot_cd: Countdown
var reload_cd: Countdown
var character: PlayerEntity
var active_gun: GunModel

func _ready():
	shoot_cd = Countdown.new(0)
	reload_cd = Countdown.new(0)
	_set_active_gun(0)
	Signals.gun_swap_started.connect(_on_gun_swap_started)
	Signals.reload_started.connect(_on_reload_started)
	Signals.reload_ended.connect(_on_reload_ended)
	Signals.gun_drop_started.connect(_on_gun_drop_started)
	Signals.gun_dropped.connect(_on_gun_dropped)
	Signals.gun_shot.connect(_on_gun_shot)
	Signals.gun_pickup_started.connect(_on_gun_pickup_started)
	Signals.drag_ended.connect(_on_drag_ended)
	Signals.spell_cast.connect(_on_spell_cast)
	Signals.core_changed.connect(_on_core_changed)
	

func _process(delta):
	# Only timers
	if shoot_cd.tick(delta) <= 0:
		_finish_cd()
	if character.is_as(PlayerModel.ActionState.reloading) and reload_cd.tick(delta) <= 0:
		Signals.reload_ended.emit(null)

func reload():
	if not active_gun or active_gun.metadata.mag_size == active_gun.mag_curr:
		return
	reload_cd.reset_cd(UNIT * active_gun.metadata.reload_time)

func shoot():
	shoot_cd.reset_cd(UNIT / active_gun.metadata.fire_rate)
	for i in range(Core.inventory.active_gun.metadata.pellet_count):
		var acc: float
		var cast_vector: Vector3
		if Core.player.is_ads:
			acc = MAX_ACCURACY - (MAX_ACCURACY - active_gun.metadata.accuracy) / active_gun.metadata.zoom
		else:
			acc = active_gun.metadata.accuracy
		var query: PhysicsRayQueryParameters3D = cast_ray_towards_mouse(acc)
		_add_ray_trail(global_position, query.to - global_position)
		query.set_exclude([character.get_rid()])
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result:
			if result.collider.has_method("take_damage"):
				var damage_number = randf_range(active_gun.metadata.damage_floor, active_gun.metadata.damage_ceiling)
				var damage_scale = float(damage_number - active_gun.metadata.damage_floor) / (active_gun.metadata.damage_ceiling - active_gun.metadata.damage_floor)
				result.collider.take_damage(damage_number, damage_scale, character.rid, result.position)
			elif !(result.collider is RigidBody3D):
				_add_bullet_hole(result.position)
			_add_bullet_particle(result.position, -character.camera.get_global_transform().basis.z.normalized())
	_update_mag(active_gun.mag_curr - active_gun.metadata.ammo_per_shot)
	Signals.gun_shot.emit({"position": position})

func pickup_gun(gun_model: GunModel, gun_id: int):
	_add_gun_to_inventory(gun_model)
	_pickup_gun_from_map(gun_id)

func drop_gun(index = Core.inventory.active_gun_index):
	if not Core.inventory.guns[index]:
		return
	var throw_vector = -character.camera.get_global_transform().basis.z.normalized()
	throw_vector = inaccuratize_vector(throw_vector, THROW_ACCURACY)
	_drop_gun_on_map(Core.inventory.guns[index], throw_vector)
	_remove_gun_at(index)
	if index == Core.inventory.active_gun_index:
		update_gun_mesh()

func cast_spell():
	var throw_vector = -character.camera.get_global_transform().basis.z.normalized()
	var acc = ADS_CAST_ACCURACY if Core.player.is_ads else CAST_ACCURACY
	throw_vector = inaccuratize_vector(throw_vector, acc)
	_add_spell_on_map(throw_vector)

func update_gun_mesh():
	var gun_model = Core.inventory.active_gun
	var mesh_instance = %GunMesh
	if gun_model:
		match gun_model.type:
			GunMetadataModel.GunType.TEST_GUN_A:
				mesh_instance.mesh = load("res://Assets/Models/test_smg.obj")
			GunMetadataModel.GunType.TEST_GUN_B:
				mesh_instance.mesh = load("res://Assets/Models/test_pistol.obj")
			GunMetadataModel.GunType.TEST_GUN_C:
				mesh_instance.mesh = load("res://Assets/Models/test_shotgun.obj")
			GunMetadataModel.GunType.TEST_GUN_D:
				mesh_instance.mesh = load("res://Assets/Models/test_sniper.obj")
			GunMetadataModel.GunType.RARE_GUN_A:
				mesh_instance.mesh = load("res://Assets/Models/bullet_sprinkler.obj")
			_:
				mesh_instance.mesh = null
	else:
		mesh_instance.mesh = null
	# TODO: use asset loader instead of directly loading mesh
	if mesh_instance.mesh:
		Signals.gun_swapped.emit({"array_mesh" : mesh_instance.mesh})

# TODO: move utilities to services or player script
static func inaccuratize_vector(vector, acc):
	var rot = deg_to_rad(ACCURACY_FLOOR * (MAX_ACCURACY - acc) / 100)
	return vector.rotated(Vector3.UP, randf_range(-rot,rot)).rotated(Vector3.BACK, randf_range(-rot,rot)).rotated(Vector3.RIGHT, randf_range(-rot,rot)) 

func cast_ray_towards_mouse(accuracy: int = MAX_ACCURACY, ray_length: int = RAY_LENGTH):
	var origin = character.camera.global_position
	var cast_vector = -character.camera.get_global_transform().basis.z.normalized() * RAY_LENGTH
	var end = origin + inaccuratize_vector(cast_vector, accuracy)
	return PhysicsRayQueryParameters3D.create(origin, end)

func set_camera_zoom(gun_zoom: float, boo: bool):
	if boo:
		character.fov_multiplier = 1 / gun_zoom
	else:
		character.fov_multiplier = 1

func finish_reload():
	reset_gun_slot()
	var new_mag = min(Core.inventory.ammo, active_gun.metadata.mag_size)
	_set_ammo(Core.inventory.ammo - new_mag + active_gun.mag_curr)
	_update_mag(new_mag)
	character.set_action_state(PlayerModel.ActionState.idling)

func reset_gun_slot():
	shoot_cd.reset_cd(0)
	reload_cd.reset_cd(0)

# Signals
func _on_gun_swap_started(payload = null):
	if len(Core.inventory.guns) > 0:
		_set_active_gun(Core.inventory.active_gun_index)
		update_gun_mesh()
func _on_reload_started(payload = null):
	if len(Core.inventory.guns) > 0:
		reload()
func _on_reload_ended(payload = null):
	if len(Core.inventory.guns) > 0:
		finish_reload()
func _on_gun_drop_started(payload = null):
	if len(Core.inventory.guns) > 0:
		drop_gun()
func _on_drag_ended(payload = null):
	if len(Core.inventory.guns) > 0 and payload["gui_hover"] is GuiDragSpace:
		var gun_index = payload["gui_drag"].index
		drop_gun(gun_index)
func _on_spell_cast(payload = null):
	cast_spell()
func _on_core_changed(payload = null):
	if Core.player.action_state == PlayerModel.ActionState.triggering and shoot_cd.tick(0) <= 0:
		if active_gun.mag_curr > 0:
			shoot()
		if active_gun.mag_curr <= 0:
			character.set_action_state(
				PlayerModel.ActionState.reloading)
func _on_gun_dropped(payload = null):
	if not active_gun:
		print("No gun equipped")
func _on_gun_shot(payload = null):
	if active_gun.mag_curr == 0:
		print("Need to reload")
func _on_gun_pickup_started(payload = null):
	if payload["rid"] == character.rid:
		if len(Core.inventory.guns) < Core.player.inventory_size:
			pickup_gun(payload["gun_model"], payload["target_rid"])
		else:
			print("Inventory full")


# Actions

func _add_gun_to_inventory(gun_model: GunModel) -> void:
	Core.inventory.guns.append(gun_model)
	if len(Core.inventory.guns) == 1:
		_set_active_gun(0)
	Signals.core_changed.emit(null)

func _remove_gun_at(index = Core.inventory.active_gun_index) -> void:
	if len(Core.inventory.guns) == 1:
		_set_active_gun(0)
	elif index == Core.inventory.active_gun_index:
		_set_active_gun(Core.inventory.active_gun_index - 1)
	Core.inventory.guns.remove_at(index)
	Signals.inventory_accessed.emit(null)

func _set_active_gun(index: int) -> void:
	var new_index = index
	if new_index < 0 or new_index > len(Core.inventory.guns) - 1:
		new_index = 0
	reset_gun_slot()
	Core.inventory.active_gun_index = new_index
	active_gun = Core.inventory.active_gun
	update_gun_mesh()
	prints("Active gun is", str(Core.inventory.active_gun_index))
	Signals.core_changed.emit(null)

func _drop_gun_on_map(active_gun: GunModel, throw_vector) -> void:
	var payload = {
		"rid" : Core.services.generate_rid(),
		"position" : character.position + character.eye_pos + throw_vector,
		"gun_model" : active_gun,
		"linear_velocity" : throw_vector * THROW_FORCE / active_gun.metadata.mass,
		"angular_velocity" : throw_vector.cross(Vector3.UP) * THROW_FORCE / active_gun.metadata.mass,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.GUN_ON_FLOOR)
	}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.gun_dropped.emit(payload)

func _add_spell_on_map(throw_vector):
	var payload = {
		"rid" : Core.services.generate_rid(),
		"position" : character.position + character.eye_pos + throw_vector,
		"linear_velocity" : throw_vector * THROW_FORCE,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.FIRE_BALL),
		"caster": character.rid,
	}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.spell_entity_added.emit(payload)

func _pickup_gun_from_map(gun_id: int) -> void:
	Signals.gun_picked_up.emit({"target_rid": gun_id})

func _update_mag(mag_curr: int) -> void:
	Core.inventory.active_gun.mag_curr = mag_curr
	Signals.core_changed.emit(null)

func _set_ammo(new_ammo: int) -> void:
	if Core.inventory.ammo == new_ammo:
		return
	Core.inventory.ammo = new_ammo
	Signals.core_changed.emit(null)

func _add_bullet_hole(node_position: Vector3):
	var payload = {
		"rid" : Core.services.generate_rid(),
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.BULLET_HOLE),
		"position" : node_position
	}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.bullet_hole_added.emit(payload)
	
func _add_ray_trail(node_position: Vector3, trail_direction: Vector3):
	var payload = {
		"rid" : Core.services.generate_rid(),
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.RAY_TRAIL),
		"position" : node_position,
		"direction" : trail_direction,
	}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.ray_trail_added.emit(payload)

func _add_bullet_particle(node_position, facing):
	var payload = {
		"rid" : Core.services.generate_rid(),
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.BULLET_PARTICLE),
		"position" : node_position,
		"facing" : facing,
	}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.bullet_particle_added.emit(payload)

func _finish_cd():
	Signals.core_changed.emit(null)
