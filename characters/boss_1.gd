extends CharacterBody2D

signal boss_defeated

@export var health: int = 200
@export var speed: int = 60
@export var follow_range: float = 250.0
@export var attack_range: float = 50.0
@export var damage: int = 12

var is_attacking = false
var can_attack = true
var is_hurt = false
var attack_counter = 0   # 🔥 track attacks

@onready var sprite = $AnimatedSprite2D
@onready var player = null


func _ready():
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var dx = player.global_position.x - global_position.x
	var dy = abs(player.global_position.y - global_position.y)
	var horizontal_distance = abs(dx)

	sprite.flip_h = dx < 0

	# Movement
	if not is_attacking and not is_hurt:
		if horizontal_distance > attack_range and horizontal_distance <= follow_range:
			velocity.x = sign(dx) * speed
			sprite.play("move")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# Attack trigger
		if horizontal_distance <= attack_range and dy < 40 and can_attack and not is_attacking and not is_hurt:
			attack()

	move_and_slide()

	if velocity.x == 0 and not is_attacking and not is_hurt:
		sprite.play("idle")


func attack():
	is_attacking = true
	can_attack = false
	attack_counter += 1

	var atk_damage = damage
	var atk_anim = "attack"

	# Heavy attack every 5th
	if attack_counter % 5 == 0:
		atk_anim = "attack_heavy"
		atk_damage = damage + 6

	sprite.play(atk_anim)

	# Wait a short wind-up before damage happens
	await get_tree().create_timer(0.4).timeout

	# Damage check
	if player and is_instance_valid(player):
		var dx = abs(player.global_position.x - global_position.x)
		var dy = abs(player.global_position.y - global_position.y)

		if dx <= attack_range and dy < 40:
			player.take_damage(atk_damage)

	# 🔥 Wait for animation to fully finish
	await sprite.animation_finished

	is_attacking = false

	await get_tree().create_timer(1.0).timeout
	can_attack = true

func take_damage(amount):
	if is_hurt:
		return

	health -= amount

	if health > 0:
		is_hurt = true
		sprite.play("hurt")
		await get_tree().create_timer(0.3).timeout
		emit_signal("boss_defeated")
		is_hurt = false
	else:
		emit_signal("boss_defeated")
		queue_free()
