extends CharacterBody2D

signal health_changed(current_health)

@export var health: int = 100
@export var speed: int = 120
@export var damage: int = 10
@export var heavy_damage: int = 15  # heavier damage for heavy attack

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
		attack_area.position.x = -30 if sprite.flip_h else 30  # slightly bigger range for heavy attack
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Normal attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# Heavy attack
	if Input.is_action_just_pressed("heavy_attack") and not is_attacking:
		heavy_attack()

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


# Normal Attack
func attack():
	is_attacking = true
	sprite.play("attack")

	await get_tree().create_timer(0.20).timeout
	attack_area.monitoring = true

	await get_tree().create_timer(0.25).timeout
	attack_area.monitoring = false
	is_attacking = false


# Heavy Attack
func heavy_attack():
	is_attacking = true
	sprite.play("heavy_attack")

	# Longer wind-up before hit
	await get_tree().create_timer(0.25).timeout
	attack_area.monitoring = true

	# Hit active longer
	await get_tree().create_timer(0.30).timeout
	attack_area.monitoring = false

	is_attacking = false

	# Longer cooldown after heavy attack
	await get_tree().create_timer(1.8).timeout  # longer cooldown than normal attack


# Attack Area Collision
func _on_attack_area_body_entered(body):
	if is_attacking and body != self and body.has_method("take_damage"):
		if sprite.animation == "heavy_attack":
			body.take_damage(heavy_damage)  # heavy attack does more
		else:
			body.take_damage(damage)


# Taking Damage
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
