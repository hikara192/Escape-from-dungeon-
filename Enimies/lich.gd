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
	if body.name == 'Player' and body.has_method("take_damage"):
		body.take_damage(20)

# Функция получения урона от игрока
func take_damage(damage: int):
	if is_dead or is_taking_damage:
		return
	
	current_health -= damage
	print("Враг получает урон: ", damage, ". Здоровье: ", current_health)
	
	# Проигрываем анимацию получения урона
	play_damage_animation()
	
	if current_health <= 0:
		die()

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
	
	if $AnimatedSprite2D.sprite_frames.has_animation("Death"):
		$AnimatedSprite2D.play("Death")
		await $AnimatedSprite2D.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	queue_free()

# АТАКА ПРИ ВХОДЕ ИГРОКА В ЗОНУ
func _on_attackarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage") and not is_attacking and not is_taking_damage:
		print("🎯 Игрок вошел в зону атаки!")
		start_attack(body)

# Начать атаку
func start_attack(player):
	is_attacking = true
	
	# Проигрываем анимацию атаки
	if $AnimatedSprite2D.sprite_frames.has_animation("Attack"):
		print("⚔️ Проигрываем анимацию атаки")
		$AnimatedSprite2D.play("Attack")
		# Ждем завершения анимации перед нанесением урона
		await $AnimatedSprite2D.animation_finished
	else:
		print("⚠️ Анимации атаки нет, используем таймер")
		await get_tree().create_timer(0.5).timeout
	
	# Наносим урон игроку
	if is_instance_valid(player) and player.has_method("take_damage"):
		print("💥 Наносим урон игроку: ", attack_damage)
		player.take_damage(attack_damage)
	
	# Завершаем атаку
	is_attacking = false
	print("✅ Атака завершена")
	
	# ВОЗВРАЩАЕМ АНИМАЦИЮ RUN ПОСЛЕ АТАКИ
	if not is_dead and not is_taking_damage:
		$AnimatedSprite2D.play("Run")

# Обработчик завершения анимации
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Attack":
		print("Анимация атаки завершена")
	elif $AnimatedSprite2D.animation == "Damage":
		print("Анимация получения урона завершена")
	elif $AnimatedSprite2D.animation == "Death":
		print("Анимация смерти завершена")
		queue_free()
