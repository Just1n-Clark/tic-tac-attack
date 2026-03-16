extends Label

func _ready() -> void:
	Global.score_updated.connect(_update);
	_update();

func _update():
	text = str(Global.score);
