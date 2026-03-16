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
var wave_count = 0;
var max_wave = 10;
var wave_cooldown_time = 10;

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
	for i in max_enemies:
		_spawn_enemy();
	
func _spawn_enemy():
	var enemy_instance = enemy_prefab.instantiate();
	nav_region.add_child(enemy_instance);
	
	# Move away from world center
	enemy_instance.position = Vector3(
		randi_range(-10, 10),
		3,
		randi_range(-10, 10)
	);
	
	# Spawn classic enemy
	enemy_instance.initialize(enemy_types[0]);
	
func _spawn_boss():
	pass;
