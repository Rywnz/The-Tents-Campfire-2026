extends CharacterBody2D

@export var health: int = 100
@export var speed: int = 80
@export var damage: int = 68

const JUMP_VELOCITY = -250.0

@onready var sprite = $AnimatedSprite2D

func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction: int = Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	# Animations
	if not is_on_floor():
		sprite.play("jump")
	elif direction:
		sprite.play("run")
	else:
		sprite.play("idle")


func take_damage(amount):
	health -= amount
	print("Player Health:", health)

	if health <= 0:
		die()

func die():
	print("Player Died")
	queue_free()
