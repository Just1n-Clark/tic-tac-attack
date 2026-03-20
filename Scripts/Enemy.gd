class_name Enemy
extends CharacterBody3D

var move_speed = 3
var ATTACK_DISTANCE = 2;

var attack_cooldown = 1;
var pre_attack_timer = 1.5;
var next_attack = 0;

var attack_damage = 5;
var score_value = 15;
var attack_range = 2;

var MAX_HEALTH = 20;
var current_health: float = MAX_HEALTH;

var pre_attack_state: bool = false;

var label: Label3D;

@export var player : CharacterBody3D;

@onready var nav_agent = $NavigationAgent3D;

#region private methods
func _ready() -> void:
	player = Global.player;
	current_health = MAX_HEALTH;
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	if player == null:
		print("Player is null!");
		return;

	velocity = Vector3.ZERO;
	
	nav_agent.set_target_position(player.global_position);
	var next_nav_postion = nav_agent.get_next_path_position();
	velocity = (next_nav_postion - global_position).normalized() * move_speed;
	
	move_and_slide();
	
	next_attack += delta;
	
	# Check if able to damage player
	if global_position.distance_to(player.global_position) < ATTACK_DISTANCE:
		if not pre_attack_state:
			pre_attack_state = true;
			await get_tree().create_timer(pre_attack_timer).timeout;
			
			if is_instance_valid(self):
				pre_attack_state = false;
		
			if global_position.distance_to(player.global_position) < ATTACK_DISTANCE:
				if next_attack > attack_cooldown:
					next_attack = 0;
					player.take_damage(attack_damage);
				
	# Face label at player
	var direction = Vector3(player.position.x, label.position.y, player.position.z);
	label.look_at(direction, Vector3.UP);
		
func die():
	Global.decrement_enemy_count();
	Global.add_score(score_value);
	queue_free();
#endregion

#region public methods
func take_damage(damage: float):
	current_health -= damage;
	current_health = clamp(current_health, 0, MAX_HEALTH);
	
	if (current_health < 1):
		die();
		
func initialize(stats: EnemyStats) -> void:
	self.name = stats.name;
	self.MAX_HEALTH = stats.MAX_HEALTH;
	self.attack_damage = stats.attack_damage;
	self.attack_range = stats.attack_range;
	self.attack_cooldown = stats.attack_cooldown;
	self.move_speed = stats.move_speed;
	self.score_value = stats.score_value;
	self.scale = Vector3(stats.size, stats.size, stats.size);
	
	_spawn_label();

func _spawn_label():
	label = Label3D.new();
	add_child(label);
	
	label.global_position = global_position + Vector3(0, 3, 0);
	label.text = "%d | " % current_health + name;
