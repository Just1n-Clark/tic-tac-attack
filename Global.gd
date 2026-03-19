extends Node

signal score_updated;
signal wave_updated;
signal all_enemies_dead;

var player: CharacterBody3D

var score: int = 0;
var current_wave: int = 0;
var enemy_count: int = 0;

var game_win: bool = false;
var game_over: bool = false;

func add_score(amount: int):
	score += amount;
	score_updated.emit();
	
func increment_wave() -> void:
	current_wave += 1;
	wave_updated.emit();

#region enemy_count
func increment_enemy_count() -> void:
	enemy_count += 1;

func decrement_enemy_count() -> void:
	enemy_count -= 1;
	
	if enemy_count == 0:
		all_enemies_dead.emit();
#endregion
