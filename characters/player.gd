extends CharacterBody2D

signal health_changed(current_health)

@export var health: int = 100
@export var speed: int = 120
@export var damage: int = 10

const JUMP_VELOCITY = -250.0

var is_attacking = false
var is_hurt = false

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea


func _ready():
	add_to_group("player")
	attack_area.monitoring = false


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
		attack_area.position.x = -25 if sprite.flip_h else 25
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	move_and_slide()

	if is_attacking or is_hurt:
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

	await get_tree().create_timer(0.15).timeout
	attack_area.monitoring = true

	await get_tree().create_timer(0.25).timeout
	attack_area.monitoring = false
	is_attacking = false


func _on_attack_area_body_entered(body):
	if is_attacking and body.has_method("take_damage"):
		body.take_damage(damage)


func take_damage(amount):
	if is_hurt:
		return

	health -= amount
	health_changed.emit(health)

	if health > 0:
		is_hurt = true
		sprite.play("damage_taken")
		await get_tree().create_timer(0.4).timeout
		is_hurt = false
	else:
		queue_free()
