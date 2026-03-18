extends Label

func _ready() -> void:
	Global.wave_updated.connect(_update);
	_update();

func _update():
	text = str("Wave: %d " % Global.current_wave);
