extends CharacterBody2D

@export var health: int = 100
@export var speed: int = 80
@export var damage: int = 67

const JUMP_VELOCITY = -250.0

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement input
	var direction: int = Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * speed
		
		# Flip sprite
		if direction < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	# Animation logic
	if not is_on_floor():
		sprite.play("jump")
	elif direction:
		sprite.play("run")
	else:
		sprite.play("idle")
