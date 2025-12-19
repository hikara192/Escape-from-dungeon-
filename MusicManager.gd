extends AudioStreamPlayer

var is_music_playing = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	stream = preload("res://res/sounds/theme.mp3")
	volume_db = -10.0

func start_music():
	if not playing:
		play()
	is_music_playing = true

func stop_music():
	stop()
	is_music_playing = false

# Публичная функция для обновления состояния
func update_music_state(is_player_alive: bool):
	if is_player_alive:
		if not is_music_playing:
			start_music()
	else:
		if is_music_playing:
			stop_music()
