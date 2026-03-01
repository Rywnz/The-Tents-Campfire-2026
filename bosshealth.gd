extends Node2D

@onready var boss = $"Path/To/BossNode"
@onready var boss_health_bar = $CanvasLayer/BossHealthBar

func _ready():
	if boss:
		boss.health_changed.connect(_on_boss_health_changed)
		$CanvasLayer/BossHealthBar.max_value = boss.health
		$CanvasLayer/BossHealthBar.value = boss.health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_boss_health_changed(current_health):
	boss_health_bar.value = current_health
	if current_health <= 0:
		boss_health_bar.visible = false
		
func on_boss_fight_start():
	boss_health_bar.visible = true
	
