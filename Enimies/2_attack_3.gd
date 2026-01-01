extends Node2D

var player = null
var is_chasing = false
@export var move_speed = 250.0
var animated_sprite: AnimatedSprite2D
var initial_direction: Vector2 = Vector2.ZERO
var original_local_position: Vector2
var wall_parent: Node2D
var state_machine_timer: float = 0
var current_state: String = "initial_waiting"  # Новое начальное состояние
var attack_started: bool = false  # Флаг начала атак

# Обновленные параметры состояний
var state_durations = {
	"initial_waiting": 60.0,  
	"waiting": 6.0,          
	"attacking": 10.0,        
	"returning": 5.0         
}

func _ready() -> void:
	
	original_local_position = position
	
	
	wall_parent = get_parent()
	
	# Ищем AnimatedSprite2D
	animated_sprite = find_child("AnimatedSprite2D")
	if not animated_sprite:
		animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
	
	print("Вторая атака: Ждем 63 секунды перед началом (60 + 3)")

func _process(delta: float) -> void:
	
	_update_state(delta)
	
	
	if is_chasing:
		global_position += initial_direction * move_speed * delta

func _update_state(delta: float) -> void:
	state_machine_timer += delta
	
	match current_state:
		"initial_waiting":
			if state_machine_timer >= state_durations.initial_waiting:
				_enter_wait_state()  
				print("Вторая атака: Начинаем цикл атак")
		
		"waiting":
			if state_machine_timer >= state_durations.waiting:
				_enter_attack_state()
		
		"attacking":
			if state_machine_timer >= state_durations.attacking:
				_enter_return_state()
		
		"returning":
			if state_machine_timer >= state_durations.returning:
				_enter_wait_state()

func _enter_wait_state():
	print("Вторая атака: Ожидание (6 сек)")
	current_state = "waiting"
	state_machine_timer = 0
	is_chasing = false
	
	if animated_sprite:
		animated_sprite.stop()

func _enter_attack_state():
	print("Вторая атака: Начало атаки")
	current_state = "attacking"
	state_machine_timer = 0
	is_chasing = true
	
	
	original_local_position = position
	
	# Находим игрока
	_find_player()
	
	if player:
		
		initial_direction = (player.global_position - global_position).normalized()
		rotation = initial_direction.angle()
		
		
		if animated_sprite and "attack" in animated_sprite.sprite_frames.get_animation_names():
			animated_sprite.play("attack")

func _enter_return_state():
	print("Вторая атака: Возвращение")
	current_state = "returning"
	state_machine_timer = 0
	is_chasing = false
	
	
	position = original_local_position
	rotation = 0
	
	if animated_sprite:
		animated_sprite.stop()

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = null

func _on_scullarea_2_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.on_death()
