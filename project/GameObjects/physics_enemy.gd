extends EnemyEntity
class_name PhysicsEnemy

var sight: AiSightController
var player_pos: Vector3
var turn_dir: int
var avoid_radius: float = 3.0

func _ready():
	current_state = EnemyState.idling
	sight = AiSightController.new(self, Vector3(0, 1.5, 0), vision_range)
	Signals.player_spotted.connect(_on_player_spotted)
	turn_dir = -1 if randi_range(0,1) == 1 else 1

func _physics_process(delta):
	if current_state == EnemyState.chasing:
		dir = sight.player_pos - position
		velocity = dir.normalized() * movement_speed
	else:
		velocity = Vector3.ZERO
	
	if !is_on_floor():
		velocity.y += get_gravity().y
	
	avoid_obstacles()
	move_and_slide()

func _on_player_spotted(payload = null):
	# Temporary state logic
	if payload["observer_rid"] == rid:
		current_state = EnemyState.chasing
		$AnimationPlayer.play("Idle")

func avoid_obstacles(payload=null):
	player_pos = sight.player_pos
	var ray = (player_pos - position).normalized()
	var result = sight.cast_ray_towards_target(player_pos, avoid_radius)
	var turn_angle := 0.0
	var turn_amount = 0.0
	while result and result["collider"] and not result["collider"] is PlayerEntity:
		velocity.rotated(Vector3.UP, 45 * turn_dir)
		return
		
		var normal = result["normal"].normalized()
		normal.y = 0
		var tangent: Vector3 = ray + normal
		turn_angle = ray.signed_angle_to(tangent, Vector3.UP)
		turn_amount += turn_angle
		if abs(turn_amount) > 180:
			velocity = Vector3.ZERO
			return
	
		
