extends CanvasLayer

func _ready() -> void:
	$BestScore/Label.text =  "" + str(GlobalVars.hi_score)
	$Label.text = "" + str(GlobalVars.collected_souls_count)



func _on_go_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
