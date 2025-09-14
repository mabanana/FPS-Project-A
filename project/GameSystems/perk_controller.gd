extends Node
class_name PerkController
	
enum Perk {
	double_damage,
	heal_on_kill,
}

static func apply_perks(context: Signal, payload = null):
	var entities = Core.map.entities
	var entity_type = EntityModel.EntityType
	var new_payload = payload
	
	if Perk.double_damage in Core.player.perks:
		if context == Signals.damage_dealt and entities[payload["dealer_rid"]].type == entity_type.player:
			new_payload["damage_amount"] = payload["damage_amount"] * 2
			prints("double_damage: damage doubled to", new_payload["damage_amount"])
			
	if Perk.heal_on_kill in Core.player.perks:
		if context == Signals.entity_died and entities[payload["dealer_rid"]].type == entity_type.player:
			Core.player.hp += 5
			prints("heal_on_kill: player health increased to", Core.player.hp)
			Signals.health_changed.emit({
				"target_rid": payload["dealer_rid"],
				"hp_change": 5,
				"dealer_rid" : payload["dealer_rid"],
				"target_name" : Core.map.entities[payload["dealer_rid"]].name,
			})
	
	return new_payload
