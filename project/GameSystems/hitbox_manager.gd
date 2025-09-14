class_name HitboxManager

var scene: GameScene

func _init(scene):
	self.scene = scene

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
