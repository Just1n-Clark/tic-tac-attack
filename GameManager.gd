extends Node

@export var player: PackedScene = preload("res://Scenes/Player.tscn");
@export var enemy_spawner: PackedScene = preload("res://Scenes/EnemySpawner.tscn");

@export var health_bar: ProgressBar;

var player_instance: Player;
var enemy_spawner_instance: EnemySpawner;

func _ready() -> void:
	initialize_game();
	
func initialize_game():
	player_instance = player.instantiate();
	enemy_spawner_instance = enemy_spawner.instantiate();
	
	# Set spawn position
	player_instance.position = Vector3(0, 2, 0);
	
	# Listen for game_over
	player_instance.game_over.connect(_restart_game);
	
	# Add to tree
	add_child(player_instance);
	add_child(enemy_spawner_instance);
	
	# Set in Global for other scripts to access
	Global.set_player(player_instance);
	
	health_bar.init();
	
func _restart_game():
	# Remove spawned nodes
	player_instance.queue_free();
	enemy_spawner_instance.queue_free();
	
	# Clean up enemies
	var enemies = get_tree().get_nodes_in_group("enemy");
	for enemy in enemies:
		enemy.queue_free();
	
	# Respawn nodes
	# Call at end of frame to avoid initializing and deleting in same frame
	call_deferred("initialize_game");
