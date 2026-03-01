extends Node2D

@onready var boss_health_bar = $CanvasLayer/BossHealthBar

func _ready():
	if boss_node:
		boss_node.health_changed.connect(_on_boss_health_changed)
		boss_health_bar.max_value = boss_node.health  # set the bar’s max to boss health
		boss_health_bar.value = boss_node.health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_boss_health_changed(current_health):
	boss_health_bar.value = current_health
	if current_health <= 0:
		boss_health_bar.visible = false
		
func on_boss_fight_start():
	boss_health_bar.visible = true
	
