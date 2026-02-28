extends CharacterBody2D

@export var health: int = 100
@export var speed: int = 120
@export var damage: int = 25

const JUMP_VELOCITY = -300.0

var is_attacking = false

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
		attack_area.position.x = 30 if direction > 0 else -30
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	move_and_slide()

	# Animations
	if is_attacking:
		return

	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func attack():
	is_attacking = true
	sprite.play("attack")
	attack_area.monitoring = true

	await get_tree().create_timer(0.3).timeout

	attack_area.monitoring = false
	is_attacking = false

func _on_attack_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount):
	health -= amount
	print("PLAYER HEALTH:", health)

	if health <= 0:
		die()

func die():
	print("PLAYER DIED")
	queue_free()
