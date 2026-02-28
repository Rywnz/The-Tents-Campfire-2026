extends CharacterBody2D

@export var health: int
@export var speed: int
@export var attack_range: float
@export var follow_range: float

var is_attacking = false
var can_attack = true
var attack_counter = 0
var is_hurt = false

@onready var sprite = $AnimatedSprite2D
@onready var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Horizontal distance
	var dx = player.global_position.x - global_position.x
	var horizontal_distance = abs(dx)

	# Face player horizontally
	if horizontal_distance > 1:
		sprite.flip_h = dx < 0

	# Movement (only if not attacking or hurt)
	if not is_attacking and not is_hurt:
		if horizontal_distance <= follow_range and horizontal_distance > attack_range:
			velocity.x = sign(dx) * speed
			sprite.play("move")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# Attack if in range
	if horizontal_distance <= attack_range and horizontal_distance <= follow_range and can_attack and not is_attacking and not is_hurt:
		attack_async()

	move_and_slide()

	# Idle animation if stopped (not attacking or hurt)
	if velocity.x == 0 and not is_attacking and not is_hurt:
		sprite.play("idle")

func attack_async() -> void:
	if is_attacking or not can_attack:
		return

	is_attacking = true
	can_attack = false
	attack_counter += 1

	var atk_anim = "attack"
	var atk_damage = 10
	var atk_range = attack_range
	var atk_delay = 0.6
	var atk_cooldown = 1.2

	# Every 5th attack is heavy
	if attack_counter % 5 == 0:
		atk_anim = "attack_heavy"
		atk_damage = 15
		atk_range = attack_range + 20
		atk_delay = 1.0
		atk_cooldown = 1.8

	# Play attack animation
	sprite.play(atk_anim)

	# Wait before applying damage
	await get_tree().create_timer(atk_delay).timeout

	# Apply damage if player is still in range
	if player and is_instance_valid(player):
		var dx = abs(player.global_position.x - global_position.x)
		if dx <= atk_range:
			player.take_damage(atk_damage)
			print("Boss hit player! Player HP:", player.health)

	is_attacking = false

	# Attack cooldown
	await get_tree().create_timer(atk_cooldown).timeout
	can_attack = true

func take_damage(amount):
	health -= amount
	print("BOSS HEALTH:", health)

	if health > 0:
		is_hurt = true
		sprite.play("hurt")
		await get_tree().create_timer(0.07).timeout
		is_hurt = false
	else:
		die()

func die():
	print("BOSS DIED")
	queue_free()
