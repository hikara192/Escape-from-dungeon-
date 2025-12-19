extends Node2D

@export var amplitude: float = 25.0
@export var frequency: float = 2.0
@export var move_speed: float = 200.0

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
var start_position: Vector2
var time: float = 0.0

func _ready():
	

	
	start_position = position
	
	
	if camera:
		camera.make_current()

		
	_play_animation()

func _process(delta):
	time += delta
	var new_x = position.x + move_speed * delta
	var new_y = start_position.y + amplitude * cos(frequency * time)
	position = Vector2(new_x, new_y)

func _play_animation():
	
	
	if animation_player:
		print("AnimationPlayer найден")
		print("Доступные анимации: ", animation_player.get_animation_list())
		if animation_player.has_animation("move"):
			animation_player.play("move")
			print("Анимация 'move' запущена")
		else:
			print("Анимация 'move' не найдена!")
	elif animated_sprite:
		print("AnimatedSprite2D найден")
		print("Доступные спрайты: ", animated_sprite.sprite_frames.get_animation_names() if animated_sprite.sprite_frames else "Нет спрайт-фреймов")
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("move"):
			animated_sprite.play("move")
			print("Анимация 'move' запущена")
		else:
			print("Анимация 'move' не найдена!")
	else:
		print("Ни AnimationPlayer, ни AnimatedSprite2D не найдены!")
		
		
func _attack():
	print("1")
	


#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.name == 'Player':
		#body.on_death()
