extends CharacterBody2D

@export var tilemap : TileMap

const SPEED = 200.0
const JUMP_VELOCITY = -320.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_area: Area2D = $PickupArea

var has_key : bool = false
var has_double_jump : bool = false
var can_double_jump : bool = false
var is_attacking = false
var attack_cooldown = 0.0
var attack_cooldown_time = 0.5

# Переменные здоровья
var max_health = 100
var current_health = 100
var is_invulnerable = false
var invulnerability_time = 0.5
var attack_damage = 25
var attack_key = KEY_E
var is_dead = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	
	add_to_group("player")
	anim.animation_finished.connect(_on_animation_finished)
	
	# Загружаем здоровье из GlobalVars (без автоматического восстановления)
	load_health_from_global()
	
	# Настраиваем Area2D для раздельной обработки
	setup_pickup_area()
	
	print("Здоровье игрока: ", current_health, "/", max_health)
	print("Используйте клавишу X для атаки")

# Загрузка здоровья из GlobalVars (без восстановления)
func load_health_from_global():
	if GlobalVars.has_method("get_player_health"):
		current_health = GlobalVars.get_player_health()
	if GlobalVars.has_method("get_player_max_health"):
		max_health = GlobalVars.get_player_max_health()
	
	print("Здоровье загружено из GlobalVars: ", current_health, "/", max_health)

# Сохранение здоровья в GlobalVars
func save_health_to_global():
	if GlobalVars.has_method("set_player_health"):
		GlobalVars.set_player_health(current_health)
	if GlobalVars.has_method("set_player_max_health"):
		GlobalVars.set_player_max_health(max_health)

# Восстановление здоровья только после смерти
func restore_health_after_death():
	# Восстанавливаем здоровье до максимума
	current_health = max_health
	
	# Сохраняем восстановленное здоровье в GlobalVars
	save_health_to_global()
	
	print("Здоровье восстановлено после смерти: ", current_health, "/", max_health)

func setup_pickup_area():
	if pickup_area:
		pickup_area.body_entered.connect(_on_pickup_area_body_entered)
		pickup_area.area_entered.connect(_on_pickup_area_area_entered)
		pickup_area.collision_mask = 2 | 3
		print("PickupArea настроен. Маска: ", pickup_area.collision_mask)
	else:
		print("Ошибка: PickupArea не найден!")

func _physics_process(delta: float) -> void:

	
	if is_dead:
		return
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	if is_invulnerable:
		invulnerability_time -= delta
		if invulnerability_time <= 0:
			is_invulnerable = false
			invulnerability_time = 0.5
	
	if Input.is_key_pressed(attack_key) and not is_attacking and attack_cooldown <= 0 and not is_dead:
		attack()
	

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and not is_attacking and not is_dead:
		if is_on_floor():
			can_double_jump = true
			velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_accept") and not is_attacking and not is_dead:
		if not is_on_floor() and has_double_jump and can_double_jump:
			can_double_jump = false 
			velocity.y = JUMP_VELOCITY * 0.85

	if not is_attacking and not is_dead:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
			#ФОНАРИК !!!!!!!!!!!! ( ХЗ ДОБАВИТЬ ИЛИ НЕТ ) ( СКРИЛ В ПЛЕЕРЕ)
		#if Input.is_action_just_pressed("light"):
			#$PointLight2D.enabled = !$PointLight2D.enabled
	
	update_animation()
	move_and_slide()
	
	if position.y > 1125 and not is_dead:
		take_damage(100)

func update_animation():
	if is_dead:
		return
	
	if is_attacking:
		return
		
	if velocity.x > 0:
		anim.flip_h = true 
	elif velocity.x < 0:
		anim.flip_h = false
	
	if velocity.x != 0:
		anim.play("Run")
	else:
		anim.play("Idle")
	
	if velocity.y < 0:
		anim.play("Jump")
	elif velocity.y > 0:
		anim.play("Fall")

func attack():
	if is_dead:
		return
	
	is_attacking = true
	attack_cooldown = attack_cooldown_time
	velocity.x = 0
	anim.play("Attack")
	print("⚔️ Атака начата!")
	
	var hit_enemies = []
	if pickup_area:
		var bodies = pickup_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("enemies") and body.has_method("take_damage"):
				print("💥 Попадание по врагу: ", body.name)
				body.take_damage(attack_damage)
				hit_enemies.append(body)
				body.modulate = Color.RED
				await get_tree().create_timer(0.1).timeout
				if is_instance_valid(body):
					body.modulate = Color.WHITE
	
	if hit_enemies.size() > 0:
		print("Поражено врагов: ", hit_enemies.size())
	else:
		print("Атака прошла мимо")

func _on_animation_finished():
	if anim.animation == "Attack":
		is_attacking = false
		print("Атака завершена")
	elif anim.animation == "Death":
		print("Анимация смерти завершена")
		# ВОССТАНАВЛИВАЕМ ЗДОРОВЬЕ ПЕРЕД ПЕРЕХОДОМ НА ЭКРАН СМЕРТИ
		restore_health_after_death()
		get_tree().change_scene_to_file("res://Menus/game_over.tscn")

func _on_pickup_area_body_entered(body: Node2D):
	if is_dead:
		return
	
	if is_attacking and body.is_in_group("enemies") and body.has_method("take_damage"):
		print("💥 НЕМЕДЛЕННАЯ АТАКА!")
		body.take_damage(attack_damage)
		body.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(body):
			body.modulate = Color.WHITE

func _on_pickup_area_area_entered(area: Area2D):
	if is_dead:
		return
	
	print("Обнаружен предмет: ", area.name)
	if area.has_method("on_pickup"):
		area.on_pickup(self)
		print("🎁 Предмет собран!")

func take_damage(damage: int):
	if is_invulnerable or is_dead:
		return
	
	current_health -= damage
	is_invulnerable = true
	
	# Сохраняем текущее здоровье (без восстановления)
	save_health_to_global()
	
	print("Получено урона: ", damage, ". Здоровье: ", current_health, "/", max_health)
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func heal(amount: int):
	if is_dead:
		return
	
	current_health = min(current_health + amount, max_health)
	
	# Сохраняем текущее здоровье
	save_health_to_global()
	
	print("Восстановлено здоровья: ", amount, ". Здоровье: ", current_health, "/", max_health)

func die():
	if is_dead:
		return
	
	is_dead = true
	print("💀 Игрок умер!")
	
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	
	anim.play("Death")
	print("⚰️ Проигрываем анимацию смерти")

func on_death():
	take_damage(100)
	
func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func set_max_health(value: int):
	max_health = value
	current_health = min(current_health, max_health)
	save_health_to_global()

func _input(event):
	if is_dead:
		return
	
	if Input.is_key_pressed(KEY_T):
		print("=== ТЕСТОВАЯ ПРОВЕРКА ЗОНЫ ===")
		if pickup_area:
			var bodies = pickup_area.get_overlapping_bodies()
			print("Тела в зоне: ", bodies.size())
			for body in bodies:
				print(" - ", body.name, " (enemies: ", body.is_in_group("enemies"), ")")
