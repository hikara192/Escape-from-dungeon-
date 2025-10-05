extends Node2D


func _on_area_2d_player_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.on_death()
		
	#if body.name == 'Lich':
		#body.on_death()
