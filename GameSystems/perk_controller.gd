extends Node
class_name PerkController
	
enum Perk {
	double_damage,
	heal_on_kill,
}

static func apply_perks(context: CoreServices.Context, payload, core: CoreModel, core_changed: Signal):
	var contexts = core.services.Context
	var entities = core.map.entities
	var entity_type = EntityModel.EntityType
	var new_payload = payload
	
	if Perk.double_damage in core.player.perks:
		if context == contexts.damage_dealt and entities[payload["dealer_rid"]].type == entity_type.player:
			new_payload["damage_amount"] = payload["damage_amount"] * 2
			prints("double_damage: damage doubled to", new_payload["damage_amount"])
			
	if Perk.heal_on_kill in core.player.perks:
		if context == contexts.entity_died and entities[payload["dealer_rid"]].type == entity_type.player:
			core.player.hp += 5
			prints("heal_on_kill: player health increased to", core.player.hp)
			core_changed.emit(contexts.health_changed, {
				"target_rid": payload["dealer_rid"],
				"hp_change": 5,
				"dealer_rid" : payload["dealer_rid"],
				"target_name" : core.map.entities[payload["dealer_rid"]].name,
			})
	
	return new_payload
