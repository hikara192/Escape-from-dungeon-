extends Button



func _on_you_died_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
	
	

func _on_timer_timeout() -> void:
	_on_you_died_pressed()
