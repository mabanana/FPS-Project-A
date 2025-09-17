class_name HitboxManager

var scene: GameScene
const POSITION_FORESHORTEN = 1

func _init(scene):
	self.scene = scene
	Signals.hitbox_collided.connect(_on_hitbox_collided)
	Signals.damage_dealt.connect(_deal_damage_to_entity)
	Signals.damage_dealt.connect(_on_damage_dealt)

func _on_hitbox_collided(payload = null):
		var hitbox_entity_type = payload["hitbox_entity_model"].entity_type
		match hitbox_entity_type:
			EntityMetadataModel.EntityType.FIRE_BALL:
				_deal_damage_to_entity(
					100,
					payload["damage_scale"],
					payload["dealer_rid"],
					payload["target_rid"],
					payload["damage_position"],
					payload["target_position"],
				)
			_:
				print("no effect from hitbox")

func _deal_damage_to_entity(damage_amount: int, damage_scale: float, dealer_rid: int, target_rid: int, damage_position: Vector3, target_position: Vector3):
	var payload = {
		"dealer_rid" : dealer_rid,
		"target_rid" : target_rid,
		"damage_amount" : damage_amount,
		"damage_position": damage_position,
		"damage_scale": damage_scale,
	}
	payload = PerkController.apply_perks(Signals.damage_dealt, payload)
	Signals.damage_dealt.emit(payload)
	print("HitboxManager: damage dealt emitted")

func _on_damage_dealt(payload = null):
	if not scene.entity_hash.has(payload["target_rid"]) or scene.entity_hash[payload["target_rid"]].is_queued_for_deletion():
		return
	var target_node = scene.entity_hash[payload["target_rid"]]
	var hp_change = -payload["damage_amount"]
	_add_damage_number_to_map(hp_change, payload["damage_scale"], payload["dealer_rid"], payload["damage_position"], target_node.position)
	_change_hp(hp_change, payload["dealer_rid"], payload["target_rid"])

func _add_damage_number_to_map(hp_change: int, damage_scale: float, dealer_rid: int, damage_position: Vector3, target_position):
	var direction_to_dealer = target_position.direction_to(Core.map.entities[dealer_rid].position)
	var node_position = (damage_position) + (direction_to_dealer * POSITION_FORESHORTEN)
	var payload = {
		"hp_change" : abs(hp_change),
		"damage_scale" : damage_scale,
		"position" : node_position,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.DAMAGE_NUMBER),
		"rid" : Core.services.generate_rid()
		}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.damage_taken.emit(payload)

func _change_hp(hp_change, dealer_rid, target_rid):
	Core.map.entities[target_rid].hp += hp_change
	var payload = {
			"dealer_rid" : dealer_rid,
			"target_name" : Core.map.entities[target_rid].name,
			"target_rid" : target_rid,
			"hp_change" : hp_change,
			"loot_class" : Core.map.entities[target_rid].loot_class,
			"target_position": scene.entity_hash[target_rid].global_position + scene.entity_hash[target_rid].eye_pos
	}
	if Core.map.entities[target_rid].hp <= 0:
		Core.map.entities[target_rid].alive = false
		payload = PerkController.apply_perks(Signals.entity_died, payload)
		Signals.entity_died.emit(payload)
	else:
		Signals.health_changed.emit(payload)
