extends Node2D
@onready var hp_bar = $"CanvasLayer/hp-bar"


func _process(delta: float) -> void:
	
	hp_bar.value = GlobalVars.player_health
