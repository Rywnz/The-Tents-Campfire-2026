extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var health_bar = $CanvasLayer/HealthBar

func _ready():
	health_bar.max_value = player.health
	health_bar.value = player.health
	player.health_changed.connect(_on_player_health_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_health_changed(current_health: int) -> void:
	health_bar.value = current_health
	
