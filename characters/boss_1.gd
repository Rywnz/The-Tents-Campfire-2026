extends CharacterBody2D

@export var health: int = 300
@export var speed: int = 60
@export var attack_range: float = 50.0
@export var follow_range: float = 200.0

var is_attacking = false
var can_attack = true
var attack_counter = 0  # counts attacks to decide heavy attack

@onready var sprite = $AnimatedSprite2D
@onready var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Face player horizontally
	sprite.flip_h = player.global_position.x < global_position.x

	# Horizontal distance only
	var horizontal_distance = abs(player.global_position.x - global_position.x)

	# Follow player if within follow_range and not attacking
	if horizontal_distance < follow_range and horizontal_distance > attack_range and not is_attacking:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		sprite.play("move")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Attack if close horizontally (no strict vertical check)
	if horizontal_distance <= attack_range and can_attack and not is_attacking:
		attack_async()  # async attack so physics still runs

	move_and_slide()

	if velocity.x == 0 and not is_attacking:
		sprite.play("idle")

func attack_async() -> void:
	if is_attacking or not can_attack:
		return

	is_attacking = true
	can_attack = false
	attack_counter += 1

	var atk_anim = "attack"
	var atk_damage = 10       # normal attack damage
	var atk_range = attack_range
	var atk_delay = 0.6       # normal attack delay
	var atk_cooldown = 1.2    # normal attack cooldown

	# Every 5th attack is heavy
	if attack_counter % 5 == 0:
		atk_anim = "attack_heavy"
		atk_damage = 15
		atk_range = attack_range + 20
		atk_delay = 1.0          # heavy attack delay (animation fully plays)
		atk_cooldown = 1.8       # heavy attack cooldown

	sprite.play(atk_anim)

	# Delay before applying damage
	await get_tree().create_timer(atk_delay).timeout

	# Apply damage if player still in horizontal range
	var dx = abs(player.global_position.x - global_position.x)
	if dx <= atk_range:
		player.take_damage(atk_damage)
		print("Boss hit player! Player HP:", player.health)

	is_attacking = false

	# Cooldown before next attack
	await get_tree().create_timer(atk_cooldown).timeout
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
