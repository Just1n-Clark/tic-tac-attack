extends CharacterBody3D

const SPEED = 2.5
const ATTACK_DISTANCE = 2;

var attack_cooldown = 1;
var next_attack = 0;

var damage = 5;

@export var player : CharacterBody3D;

@onready var nav_agent = $NavigationAgent3D;
	
func _physics_process(delta: float) -> void:
	if player == null:
		print("Player is null!");
		return;

	velocity = Vector3.ZERO;
	
	nav_agent.set_target_position(player.global_position);
	var next_nav_postion = nav_agent.get_next_path_position();
	velocity = (next_nav_postion - global_position).normalized() * SPEED;
	
	move_and_slide();
	
	next_attack += delta;
	
	# Check if able to damage player
	if global_position.distance_to(player.global_position) < ATTACK_DISTANCE:
		if next_attack > attack_cooldown:
			next_attack = 0;
			player.take_damage(damage);
