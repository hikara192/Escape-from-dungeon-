extends Node2D

@onready var hp_bar = $"CanvasLayer/hp-bar"

func _ready():
	# Запускаем музыку при загрузке уровня
	MusicManager.start_music()
	
	hp_bar.value = GlobalVars.player_health

func _process(delta: float) -> void:
	hp_bar.value = GlobalVars.player_health
