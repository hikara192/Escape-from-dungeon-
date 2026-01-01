extends Node2D

@onready var hp_bar = $"CanvasLayer/hp-bar"
@onready var bloodwall = $Bloodwall
@onready var bloodwall_camera = $Camera2D  # Отдельная камера на сцене

func _ready():
	GlobalVars.player_health = 100
	MusicManager.stop_music()
	hp_bar.value = GlobalVars.player_health
	
	# Отключаем камеру игрока
	var player_camera = $Player.get_node("Camera2D")
	if player_camera:
		player_camera.enabled = false
		print("Камера игрока отключена")
	
	# Настраиваем камеру bloodwall
	if bloodwall_camera:
		bloodwall_camera.enabled = true
		bloodwall_camera.make_current()
		print("Камера bloodwall активирована")
	
	await get_tree().create_timer(2.1).timeout
	$AudioStreamPlayer.stream = load("res://res/sounds/bossmusic.wav")
	$AudioStreamPlayer.play()

func _process(delta: float) -> void:
	hp_bar.value = GlobalVars.player_health
	
	# Двигаем камеру вместе с bloodwall
	if bloodwall and bloodwall_camera:
		bloodwall_camera.global_position = bloodwall.global_position
	
	# Проверяем жив ли игрок и управляем музыкой
	var player_alive = GlobalVars.player_health > 0
