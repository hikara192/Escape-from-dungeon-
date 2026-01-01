extends Node2D

var move_direction: int = 1  
var move_distance: int = 580 #скок пикселей пройдет
var move_speed: float = 1.0 #время пути 


func _ready() -> void:
	$body2/AnimatedSprite2D.play("idle")
	_start_movement_cycle()


func _process(delta: float) -> void:
	pass


func _move_in_direction() -> Tween:
	var target_x = position.x + (move_distance * move_direction)
	var tween = create_tween()
	tween.tween_property(self, "position:x", target_x, move_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	
	move_direction *= -1
	
	return tween

func _start_movement_cycle() -> void:
	while true:
		
		await get_tree().create_timer(35.0).timeout
		
		
		var tween = _move_in_direction()
		await tween.finished


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.on_death()
