extends Area2D

func _ready():
	self.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("enter")
	if body.is_in_group("Player"):
		print("good")
		get_tree().change_scene_to_file("res://level_2.tscn")
