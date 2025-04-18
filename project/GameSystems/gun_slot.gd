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
var contexts

var core: CoreModel
var core_changed: Signal

func _ready():
	shoot_cd = Countdown.new(0)
	reload_cd = Countdown.new(0)
	_set_active_gun(0)
	

func _process(delta):
	# Only timers
	if shoot_cd.tick(delta) <= 0:
		_finish_cd()
	if character.is_as(PlayerModel.ActionState.reloading) and reload_cd.tick(delta) <= 0:
		_finish_cd(contexts.reload_ended)

func reload():
	if not active_gun or active_gun.metadata.mag_size == active_gun.mag_curr:
		return
	reload_cd.reset_cd(UNIT * active_gun.metadata.reload_time)

func shoot():
	shoot_cd.reset_cd(UNIT / active_gun.metadata.fire_rate)
	for i in range(core.inventory.active_gun.metadata.pellet_count):
		var acc: float
		var cast_vector: Vector3
		if core.player.is_ads:
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
	core_changed.emit(contexts.gun_shot, {"position": position})


func pickup_gun(gun_model: GunModel, gun_id: int):
	_add_gun_to_inventory(gun_model)
	_pickup_gun_from_map(gun_id)

func drop_gun(index = core.inventory.active_gun_index):
	if not core.inventory.guns[index]:
		return
	var throw_vector = -character.camera.get_global_transform().basis.z.normalized()
	throw_vector = inaccuratize_vector(throw_vector, THROW_ACCURACY)
	_drop_gun_on_map(core.inventory.guns[index], throw_vector)
	_remove_gun_at(index)
	if index == core.inventory.active_gun_index:
		update_gun_mesh()

func cast_spell():
	var throw_vector = -character.camera.get_global_transform().basis.z.normalized()
	var acc = ADS_CAST_ACCURACY if core.player.is_ads else CAST_ACCURACY
	throw_vector = inaccuratize_vector(throw_vector, acc)
	_add_spell_on_map(throw_vector)

func update_gun_mesh():
	var gun_model = core.inventory.active_gun
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
		core_changed.emit(contexts.gun_swapped, {"array_mesh" : mesh_instance.mesh})

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
	var new_mag = min(core.inventory.ammo, active_gun.metadata.mag_size)
	_set_ammo(core.inventory.ammo - new_mag + active_gun.mag_curr)
	_update_mag(new_mag)
	character.set_action_state(PlayerModel.ActionState.idling)

func reset_gun_slot():
	shoot_cd.reset_cd(0)
	reload_cd.reset_cd(0)

# Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed

	core_changed.connect(_on_core_changed)
	_on_bind()

func _on_bind():
	contexts = core.services.Context


func _on_core_changed(context, payload):
	# Actions
	if len(core.inventory.guns) > 0:
		if context == contexts.gun_swap_started:
			_set_active_gun(core.inventory.active_gun_index)
			update_gun_mesh()
		elif context == contexts.reload_started:
			reload()
		elif context == contexts.reload_ended:
			finish_reload()
		elif context == contexts.gun_drop_started:
			drop_gun()
		elif context == contexts.drag_ended and payload["gui_hover"] is GuiDragSpace:
			var gun_index = payload["gui_drag"].index
			drop_gun(gun_index)
		elif context == contexts.spell_cast:
			cast_spell()
			
		if core.player.action_state == PlayerModel.ActionState.triggering and shoot_cd.tick(0) <= 0:
			if active_gun.mag_curr > 0:
				shoot()
			if active_gun.mag_curr <= 0:
				character.set_action_state(PlayerModel.ActionState.reloading)
		
	# Logs
	if context == contexts.gun_dropped and not active_gun:
		print("No gun equipped")
	elif context == contexts.gun_shot and active_gun.mag_curr == 0:
		print("Need to reload")
	elif context == contexts.gun_pickup_started and payload["rid"] == character.rid:
		if len(core.inventory.guns) < core.player.inventory_size:
			pickup_gun(payload["gun_model"], payload["target_rid"])
		else:
			print("Inventory full")


# Actions

func _add_gun_to_inventory(gun_model: GunModel) -> void:
	core.inventory.guns.append(gun_model)
	if len(core.inventory.guns) == 1:
		_set_active_gun(0)
	core_changed.emit(contexts.none, null)

func _remove_gun_at(index = core.inventory.active_gun_index) -> void:
	if len(core.inventory.guns) == 1:
		_set_active_gun(0)
	elif index == core.inventory.active_gun_index:
		_set_active_gun(core.inventory.active_gun_index - 1)
	core.inventory.guns.remove_at(index)
	core_changed.emit(contexts.inventory_accessed, null)

func _set_active_gun(index: int) -> void:
	var new_index = index
	if new_index < 0 or new_index > len(core.inventory.guns) - 1:
		new_index = 0
	reset_gun_slot()
	core.inventory.active_gun_index = new_index
	active_gun = core.inventory.active_gun
	update_gun_mesh()
	prints("Active gun is", str(core.inventory.active_gun_index))
	core_changed.emit(contexts.none, null)

func _drop_gun_on_map(active_gun: GunModel, throw_vector) -> void:
	var payload = {
		"rid" : core.services.generate_rid(),
		"position" : character.position + character.eye_pos + throw_vector,
		"gun_model" : active_gun,
		"linear_velocity" : throw_vector * THROW_FORCE / active_gun.metadata.mass,
		"angular_velocity" : throw_vector.cross(Vector3.UP) * THROW_FORCE / active_gun.metadata.mass,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.GUN_ON_FLOOR)
	}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.gun_dropped, payload)

func _add_spell_on_map(throw_vector):
	var payload = {
		"rid" : core.services.generate_rid(),
		"position" : character.position + character.eye_pos + throw_vector,
		"linear_velocity" : throw_vector * THROW_FORCE,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.FIRE_BALL),
		"caster": character.rid,
	}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.spell_entity_added, payload)

func _pickup_gun_from_map(gun_id: int) -> void:
	core_changed.emit(contexts.gun_picked_up, {"target_rid": gun_id})

func _update_mag(mag_curr: int) -> void:
	core.inventory.active_gun.mag_curr = mag_curr
	core_changed.emit(contexts.none, null)

func _set_ammo(new_ammo: int) -> void:
	if core.inventory.ammo == new_ammo:
		return
	core.inventory.ammo = new_ammo
	core_changed.emit(contexts.none, null)

func _add_bullet_hole(node_position: Vector3):
	var payload = {
		"rid" : core.services.generate_rid(),
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.BULLET_HOLE),
		"position" : node_position
	}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.bullet_hole_added, payload)
	
func _add_ray_trail(node_position: Vector3, trail_direction: Vector3):
	var payload = {
		"rid" : core.services.generate_rid(),
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.RAY_TRAIL),
		"position" : node_position,
		"direction" : trail_direction,
	}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.ray_trail_added, payload)

func _add_bullet_particle(node_position, facing):
	var payload = {
		"rid" : core.services.generate_rid(),
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.BULLET_PARTICLE),
		"position" : node_position,
		"facing" : facing,
	}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.bullet_particle_added, payload)

func _finish_cd(context = contexts.none):
	core_changed.emit(context, null)
