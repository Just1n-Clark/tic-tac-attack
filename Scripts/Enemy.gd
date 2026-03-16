extends CharacterBody3D

class_name Enemy

const SPEED = 2.5
const ATTACK_DISTANCE = 2;

var attack_cooldown = 1;
var next_attack = 0;

var damage = 5;

const MAX_HEALTH = 40;
var current_health = 0;

@export var player : CharacterBody3D;

@onready var nav_agent = $NavigationAgent3D;

func _ready() -> void:
	player = Global.player;
	current_health = MAX_HEALTH;

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

func take_damage(damage: float):
	current_health -= damage;
	current_health = clamp(current_health, 0, MAX_HEALTH);
	
	print("Enemy health: %d" % current_health);
	
	if (current_health < 1):
		die();
		
func die():
	print("Enemy died!");
	Global.add_score(10);
	queue_free();
