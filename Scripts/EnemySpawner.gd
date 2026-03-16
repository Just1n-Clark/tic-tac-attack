extends Node

var enemy_types: Array[EnemyAttributes];
const enemy_prefab := preload("res://Scenes/Enemy.tscn");

var max_enemies = 10;
var wave_count = 0;
var max_wave = 10;
var wave_cooldown_time = 10;

func _ready() -> void:
	# Spawn enemy
	# Check if wave_unlock < current_wave
	_spawn_waves();
	
	# Spawn Boss
	# Check if wave_unlock < current_wave
	_spawn_boss();
	
func _spawn_waves():
	pass;
	
func _spawn_enemy():
	var enemy_instance = enemy_prefab.instantiate();
	add_child(enemy_instance);
	
func _spawn_boss():
	pass;
