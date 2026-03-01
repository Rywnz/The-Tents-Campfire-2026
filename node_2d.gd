extends Node2D

var unlocked = false

func unlock():
	unlocked = true
	$StaticBody2D.CollisionShape2D.disabled = true
	$Sprite.modulate = Color(1,1,1,0.5)  # optional fade effect
