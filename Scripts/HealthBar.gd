extends ProgressBar

@export var player: Player;

func init():
	player = Global.player;
	
	player.health_changed.connect(_update);
	_update();

func _update():
	value = player.current_health * 100 / player.MAX_HEALTH;
