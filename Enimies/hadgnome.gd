extends Area2D

@export var bounce_force = 300.0  # Сила отскока
@export var horizontal_bounce = 250.0  # Горизонтальная сила отскока
@export var damage_to_enemy = 10  # Урон врагу

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Проверяем, что вошел игрок
	if body.is_in_group("player") and body.has_method("apply_bounce"):
		print("🎯 Игрок прыгнул на голову врага!")
		
		# Получаем родителя (врага)
		var enemy = get_parent()
		if enemy and enemy.has_method("take_damage") and not enemy.is_dead:
			# Наносим урон врагу
			print("💥 Наносим урон врагу: ", damage_to_enemy)
			enemy.take_damage(damage_to_enemy)
		
		# Вызываем отскок у игрока
		bounce_player(body)

func bounce_player(player: Node2D):
	# Определяем направление отскока (в сторону и вверх)
	var enemy = get_parent()
	
	# Определяем сторону отскока в зависимости от позиции игрока относительно врага
	var player_pos = player.global_position
	var enemy_pos = enemy.global_position
	
	# Если игрок слева от врага - отскакиваем влево, если справа - вправо
	var horizontal_direction = 1 if player_pos.x > enemy_pos.x else -1
	
	# Создаем вектор отскока (в сторону + вверх)
	var bounce_vector = Vector2(horizontal_direction * horizontal_bounce, -bounce_force)
	
	# Применяем силу отскока
	player.apply_bounce(bounce_vector)
	print("🚀 Игрок отскакивает в сторону: ", bounce_vector)
