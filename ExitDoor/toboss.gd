extends Node2D

@export var needs_key : bool = false
@export var next_scene : String

func _on_door_open_animate_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	$OpenDoor.hide()

func _on_door_open_animate_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return
	$OpenDoor.hide()

func _on_go_to_next_scene_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	# Проверяем ключ если нужно
	if needs_key and not body.has_key:
		return
	
	# Запускаем переход и ждем его завершения
	Tooboss.transition()
	await Tooboss.on_transition_finished
	
	# Сохраняем и меняем сцену
	GlobalVars.last_level = next_scene
	GlobalVars.save_game()
	get_tree().change_scene_to_file(next_scene)
