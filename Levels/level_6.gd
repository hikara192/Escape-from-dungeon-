extends Node2D

@onready var hp_bar = $"CanvasLayer/hp-bar"

func _ready():
	# Запускаем музыку при старте уровня
	MusicManager.start_music()
	hp_bar.value = GlobalVars.player_health

func _process(delta: float) -> void:
	hp_bar.value = GlobalVars.player_health
	
	# Проверяем жив ли игрок и управляем музыкой
	var player_alive = GlobalVars.player_health > 0
	MusicManager.update_music_state(player_alive)
	
	
