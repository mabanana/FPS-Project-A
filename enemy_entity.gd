extends CharacterBody3D
class_name EnemyEntity

const POSITION_FORESHORTEN = 1
var rid: int
var core: CoreModel
var core_changed: Signal
var contexts

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context

func take_damage(damage_number, damage_scale, dealer, damage_position):
	_add_damage_number_to_map(dealer, damage_position, damage_number, damage_scale)

func _on_core_changed(context: CoreServices.Context, payload):
	pass

func _add_damage_number_to_map(dealer, damage_position, damage_number, damage_scale):
	var direction_to_dealer = position.direction_to(dealer.position)
	var node_position = (damage_position) + (direction_to_dealer * POSITION_FORESHORTEN)
	
	var payload = {
		"damage_number" : damage_number,
		"damage_scale" : damage_scale,
		"dealer" : dealer.rid,
		"target" : self.rid,
		"position" : node_position,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.DAMAGE_NUMBER),
		"rid" : core.services.generate_rid()
		}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.damage_dealt, payload)
