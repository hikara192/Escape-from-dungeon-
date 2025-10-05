extends CanvasLayer

func _ready() -> void:
	if GlobalVars.last_level == "":
		$return.visible = false
		
func _on_play_pressed() -> void:
	GlobalVars.score = 0 
	if not GlobalVars.hi_score:
		GlobalVars.hi_score = 0
	GlobalVars.last_level = ""
	GlobalVars.save_game()
	get_tree().change_scene_to_file("res://Levels/Level1.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
func _on_return_pressed() -> void:
	GlobalVars.score = 0 
	if not GlobalVars.hi_score:
		GlobalVars.hi_score = 0
	get_tree().change_scene_to_file(GlobalVars.last_level)

func _on_records_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/hall_of_fame.tscn")
