extends CharacterBody2D

@export var speed: int = 50
@export var health: int = 300
@export var damage: int = 20
@export var attack_cooldown: float = 1.5

var player_in_range = false
var can_attack = true
var is_hurt = false
var player = null

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):

	if is_hurt:
		return

	if player_in_range and player != null:
		velocity = Vector2.ZERO
		
		if can_attack:
			sprite.play("attack")
			attack_player()
		else:
			sprite.play("idle")
	else:
		# Move toward player
		if player != null:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			sprite.play("move")

	move_and_slide()


func attack_player():
	if can_attack and player.has_method("take_damage"):
		can_attack = false
		player.take_damage(damage)
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true


func take_damage(amount):
	if is_hurt:
		return

	health -= amount
	print("Boss Health:", health)

	if health <= 0:
		die()
	else:
		play_hurt_animation()


func play_hurt_animation():
	is_hurt = true
	velocity = Vector2.ZERO
	sprite.play("hurt")
	await sprite.animation_finished
	is_hurt = false


func die():
	print("Boss Defeated")
	queue_free()


# 🔥 Area2D Signals (connect these!)

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player = body


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
