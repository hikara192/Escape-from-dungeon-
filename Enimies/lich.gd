extends CharacterBody2D

var speed = 60.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right = true

# Добавляем переменные здоровья
var max_health = 50
var current_health = 50
var is_dead = false

# Переменные для атаки
var is_attacking = false
var attack_damage = 20
var is_taking_damage = false  # Флаг получения урона
var player_in_attack_zone: Node2D = null  # Храним игрока в зоне атаки
var current_attack_player: Node2D = null  # Текущий игрок, по которому идет атака

func _ready():
	$AnimatedSprite2D.play("Run")
	add_to_group("enemies")
	
	current_health = max_health
	print("Враг создан. Здоровье: ", current_health)

func _physics_process(delta: float) -> void:
	if is_dead or is_taking_damage:  # Не двигаемся во время получения урона
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if !$RayCast2D.is_colliding() and is_on_floor():
		flip()
	
	# Не двигаемся во время атаки
	if not is_attacking:
		velocity.x = speed
	else:
		velocity.x = 0
	
	move_and_slide()

func flip():
	if is_dead or is_attacking or is_taking_damage:
		return
		
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Проверяем, что враг не мертв
	if is_dead:
		return
		
	if body.name == 'Player' and body.has_method("take_damage"):
		body.take_damage(20)

# Функция получения урона от игрока
func take_damage(damage: int):
	if is_dead or is_taking_damage:
		return
	
	# ЕСЛИ ВРАГ АТАКУЕТ - ПРЕРЫВАЕМ АТАКУ
	if is_attacking:
		print("🛑 Атака прервана получением урона!")
		interrupt_attack()
	
	current_health -= damage
	print("Враг получает урон: ", damage, ". Здоровье: ", current_health)
	
	# Проигрываем анимацию получения урона
	play_damage_animation()
	
	if current_health <= 0:
		die()

# ПРЕРЫВАНИЕ АТАКИ ПРИ ПОЛУЧЕНИИ УРОНА
func interrupt_attack():
	is_attacking = false
	current_attack_player = null
	print("⚡ Атака прервана - игрок не получит урон")

# Проигрываем анимацию получения урона
func play_damage_animation():
	is_taking_damage = true
	velocity.x = 0  # Останавливаемся при получении урона
	
	if $AnimatedSprite2D.sprite_frames.has_animation("Damage"):
		print("💢 Проигрываем анимацию получения урона")
		$AnimatedSprite2D.play("Damage")
		# Ждем завершения анимации урона
		await $AnimatedSprite2D.animation_finished
	else:
		# Если анимации Damage нет, используем короткую паузу
		print("⚠️ Анимации Damage нет, используем короткую паузу")
		await get_tree().create_timer(0.3).timeout
	
	# Возвращаемся к обычному состоянию
	is_taking_damage = false
	
	# Возвращаем анимацию бега, если не умерли и не атакуем
	if not is_dead and not is_attacking:
		$AnimatedSprite2D.play("Run")

func die():
	is_dead = true
	speed = 0
	collision_layer = 0
	collision_mask = 0
	
	print("💀 Враг умирает!")
	
	# ПРЕРЫВАЕМ АТАКУ ПРИ СМЕРТИ
	if is_attacking:
		interrupt_attack()
	
	# УДАЛЯЕМ ВСЕ AREA2D СРАЗУ ПРИ СМЕРТИ
	remove_all_area2d()
	
	if $AnimatedSprite2D.sprite_frames.has_animation("Death"):
		$AnimatedSprite2D.play("Death")
		await $AnimatedSprite2D.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	queue_free()

# Функция для удаления всех Area2D
func remove_all_area2d():
	print("🗑️ Удаляем все Area2D...")
	
	# Ищем все дочерние Area2D узлы
	for child in get_children():
		if child is Area2D:
			print("✅ Удален Area2D: ", child.name)
			child.queue_free()
	
	# Также отключаем все коллизии
	$CollisionShape2D.set_deferred("disabled", true)

# АТАКА ПРИ ВХОДЕ ИГРОКА В ЗОНУ
func _on_attackarea_body_entered(body: Node2D) -> void:
	# Проверяем, что враг не мертв
	if is_dead:
		return
		
	if body.is_in_group("player") and body.has_method("take_damage") and not is_attacking and not is_taking_damage:
		print("🎯 Игрок вошел в зону атаки!")
		player_in_attack_zone = body  # Сохраняем ссылку на игрока
		start_attack()

# Игрок вышел из зоны атаки
func _on_attackarea_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("🎯 Игрок вышел из зоны атаки!")
		player_in_attack_zone = null  # Очищаем ссылку на игрока

# Начать атаку
func start_attack():
	# Проверяем, что враг не мертв
	if is_dead:
		return
		
	is_attacking = true
	current_attack_player = player_in_attack_zone
	
	print("⚔️ Начинаем атаку на игрока")
	
	# Проигрываем анимацию атаки
	if $AnimatedSprite2D.sprite_frames.has_animation("Attack"):
		print("⚔️ Проигрываем анимацию атаки")
		$AnimatedSprite2D.play("Attack")
		# Ждем завершения анимации перед нанесением урона
		await $AnimatedSprite2D.animation_finished
	else:
		print("⚠️ Анимации атаки нет, используем таймер")
		await get_tree().create_timer(0.5).timeout
	
	# НАНОСИМ УРОН ТОЛЬКО ПРИ ЗАВЕРШЕНИИ АНИМАЦИИ, ЕСЛИ ИГРОК ВСЕ ЕЩЕ В ЗОНЕ И АТАКА НЕ ПРЕРВАНА
	if not is_dead and is_attacking and player_in_attack_zone and is_instance_valid(player_in_attack_zone) and player_in_attack_zone.has_method("take_damage"):
		print("💥 Наносим урон игроку при завершении анимации: ", attack_damage)
		player_in_attack_zone.take_damage(attack_damage)
	else:
		if not is_attacking:
			print("⏹️ Урон не нанесен: атака была прервана")
		else:
			print("⏹️ Урон не нанесен: игрок вышел из зоны атаки")
	
	# Завершаем атаку
	is_attacking = false
	current_attack_player = null
	print("✅ Атака завершена")
	
	# ВОЗВРАЩАЕМ АНИМАЦИЮ RUN ПОСЛЕ АТАКИ
	if not is_dead and not is_taking_damage:
		$AnimatedSprite2D.play("Run")

# Обработчик завершения анимации
func _on_animated_sprite_2d_animation_finished():
	if is_dead:
		return
		
	if $AnimatedSprite2D.animation == "Attack":
		print("Анимация атаки завершена")
	elif $AnimatedSprite2D.animation == "Damage":
		print("Анимация получения урона завершена")
	elif $AnimatedSprite2D.animation == "Death":
		print("Анимация смерти завершена")
		queue_free()
