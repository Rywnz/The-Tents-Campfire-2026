extends CharacterBody2D

@export var health: int = 300
@export var speed: int = 60
@export var damage: int = 15
@export var attack_range: float = 60.0
@export var follow_range: float = 100.0

var is_attacking = false
var can_attack = true

@onready var sprite = $AnimatedSprite2D
@onready var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	var distance = global_position.distance_to(player.global_position)

	# Face player ALWAYS
	sprite.flip_h = player.global_position.x < global_position.x

	# Follow player if within follow_range
	if distance < follow_range and distance > attack_range and not is_attacking:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		sprite.play("move")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Attack if close
	if distance <= attack_range and can_attack and not is_attacking:
		attack()

	move_and_slide()

	if velocity.x == 0 and not is_attacking:
		sprite.play("idle")

func attack():
	is_attacking = true
	can_attack = false

	sprite.play("attack")

	# Wait a little so animation plays
	await get_tree().create_timer(0.4).timeout

	# DIRECT DAMAGE: ignore collisions, just check distance
	if player and global_position.distance_to(player.global_position) <= attack_range:
		player.take_damage(damage)
		print("Boss hit player! Player HP:", player.health)

	is_attacking = false

	# Cooldown
	await get_tree().create_timer(1.2).timeout
	can_attack = true

func take_damage(amount):
	health -= amount
	print("BOSS HEALTH:", health)
	sprite.play("hurt")
	

	if health <= 0:
		die()

func die():
	print("BOSS DIED")
	queue_free()
