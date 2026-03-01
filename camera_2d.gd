extends Camera2D

func _ready():
	make_current()
	zoom = Vector2(0.7, 0.7)   # Zooms *in*
