extends CharacterBody2D

@export var health: int = 100
@export var speed: int = 120
@export var damage: int = 25

const JUMP_VELOCITY = -200.0

var is_attacking = false
var is_hurt = false

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea

func _ready():
	add_to_group("player")
	attack_area.monitoring = false

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
		# Push hitbox forward so it always overlaps even if close
		var offset = max(30, 40) # minimum distance to cover close targets
		attack_area.position.x = offset if direction > 0 else -offset
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	move_and_slide()

	# Animations (skip if attacking or hurt)
	if is_attacking or is_hurt:
		return

	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func attack():
	if is_attacking:
		return  # prevent attack spamming

	is_attacking = true
	sprite.play("attack")

	# Delay before hitbox activates (mid-swing)
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = true

	# Immediately check overlapping bodies so close enemies get hit
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)

	# Wait until animation finishes
	await get_tree().create_timer(0.5).timeout
	attack_area.monitoring = false
	is_attacking = false

func _on_attack_area_body_entered(body):
	# fallback in case a body enters later
	if body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount):
	if is_hurt:
		return  # ignore new damage until hurt animation finishes

	health -= amount
	print("PLAYER HEALTH:", health)

	if health > 0:
		is_hurt = true
		sprite.play("damage_taken")
		await get_tree().create_timer(0.5).timeout
		is_hurt = false
	else:
		die()

func die():
	print("PLAYER DIED")
	queue_free()
