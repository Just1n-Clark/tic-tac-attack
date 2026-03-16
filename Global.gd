extends Node

signal score_updated;

var player: CharacterBody3D

var score: int = 0;

func add_score(amount: int):
	score += amount;
	score_updated.emit();
