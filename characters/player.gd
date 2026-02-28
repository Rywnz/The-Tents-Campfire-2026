extends CharacterBody2D

@export var health: int = 100
@export var speed: int = 80
@export var damage: int = 50

const JUMP_VELOCITY = -250.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good gpractice, you should replace UI actions with custom gameplay actions.
	var direction: int = Input.get_axis("left", "right")
	
			
	if direction:
		velocity.x = direction * speed
		print(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
