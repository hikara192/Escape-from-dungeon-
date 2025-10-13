extends CanvasLayer

func _ready() -> void:
	if GlobalVars.last_level == "":
		$return.visible = false

func hide_all_content():
	# Получаем все дочерние ноды и скрываем только те, у которых есть свойство visible
	for child in get_children():
		if child != $TransitionScreen:  # Не скрываем сам TransitionScreen
			# Проверяем, есть ли у ноды метод set_visible (что означает свойство visible)
			if child.has_method("set_visible"):
				child.visible = false

func _on_play_pressed() -> void:
	# Останавливаем AudioStreamPlayer1, если он играет
	if has_node("AudioStreamPlayer1") and $AudioStreamPlayer1.playing:
		$AudioStreamPlayer1.stop()
	
	# Проигрываем мелодию при нажатии на кнопку старт
	$AudioStreamPlayer.play()
	
	hide_all_content()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	GlobalVars.score = 0 
	if not GlobalVars.hi_score:
		GlobalVars.hi_score = 0
	GlobalVars.last_level = ""
	GlobalVars.save_game()
	get_tree().change_scene_to_file("res://Levels/Level1.tscn")

func _on_exit_pressed() -> void:
	hide_all_content()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().quit()

func _on_return_pressed() -> void:
	hide_all_content()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	GlobalVars.score = 0 
	if not GlobalVars.hi_score:
		GlobalVars.hi_score = 0
	get_tree().change_scene_to_file(GlobalVars.last_level)

func _on_records_pressed() -> void:
	hide_all_content()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Menus/hall_of_fame.tscn")
