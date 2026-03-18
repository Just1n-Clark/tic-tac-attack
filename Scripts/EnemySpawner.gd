extends Node

class_name EnemySpawner

var enemy_types: Array[EnemyStats] = [
	preload("res://EnemyTypes/Classic.tres"),
	preload("res://EnemyTypes/Mini.tres"),
	preload("res://EnemyTypes/Goopy.tres"),
	preload("res://EnemyTypes/Shattered.tres"),
	preload("res://EnemyTypes/Boss_Melee.tres")
]

const enemy_prefab: PackedScene = preload("res://Scenes/Enemy.tscn");

var max_enemies = 10;
var current_wave = 0;
var max_wave = 10;
var wave_cooldown_time = 5;
var enemies_per_wave = max_enemies;

#region References
@export var nav_region: NavigationRegion3D;
#endregion

func _ready() -> void:
	# Spawn enemy
	# Check if wave_unlock < current_wave
	_spawn_waves();
	
	# Spawn Boss
	# Check if wave_unlock < current_wave
	_spawn_boss();

func _spawn_waves():
	while (current_wave < max_wave):
		current_wave += 1;
		
		Global.increment_wave();
		
		print("Starting wave %d " % current_wave);
		
		var i = 0;
		while i < enemies_per_wave:
			_spawn_enemy(_valid_spawnables());
			i += 1;
			
		# Spawn boss enemies
		
		# Check all enemies dead
		if Global.enemy_count > 0:
			await Global.all_enemies_dead;
		
		# Cooldown timer
		await get_tree().create_timer(wave_cooldown_time).timeout;
	
func _spawn_enemy(valid_spawnables: Array[EnemyStats]):
	var enemy_instance = enemy_prefab.instantiate();
	nav_region.add_child(enemy_instance);
	
	# Move away from world center to random location within bounds
	enemy_instance.position = Vector3(
		randi_range(-10, 10),
		3,
		randi_range(-10, 10)
	);
	
	# Spawn classic enemy
	var enemy_type = valid_spawnables[randi_range(0, valid_spawnables.size() - 1)];
	enemy_instance.initialize(enemy_type);
	enemy_instance.name = enemy_type.name;
	
	Global.increment_enemy_count();
	
func _spawn_boss():
	pass;
	
func _valid_spawnables() -> Array[EnemyStats]:
	var valid_spawnables: Array[EnemyStats] = [];
	for type in enemy_types:
		if (type.wave_unlock <= current_wave && not type.is_boss):
			valid_spawnables.push_back(type);
	
	return valid_spawnables;
