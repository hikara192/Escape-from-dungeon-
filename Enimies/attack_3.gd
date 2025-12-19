extends Node2D


var move_direction: int = 1  
var move_distance: int = 515 # сколько пикселей пройдет
var move_speed: float = 1.0   # время пути


func _ready() -> void:
	$body1/AnimatedSprite2D.play("idle")
	_start_movement_cycle()


func _process(delta: float) -> void:
	pass


func _move_in_direction() -> Tween:
	# Меняем координату Y вместо X для движения вверх/вниз
	var target_y = position.y + (move_distance * move_direction)
	var tween = create_tween()
	tween.tween_property(self, "position:y", target_y, move_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	
	move_direction *= -1  
	
	return tween


func _start_movement_cycle() -> void:
	while true:
		# Ждем 5 секунд перед началом движения
		await get_tree().create_timer(40.0).timeout
		
		# Выполняем движение
		var tween = _move_in_direction()
		await tween.finished


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.on_death()
