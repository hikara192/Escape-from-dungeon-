extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var timeline_name := "timeline1"

var spawn_position: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	spawn_position = position

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and (body.is_in_group("player") or body.name == "Player"):
		# Поворачиваем NPC к игроку
		turn_towards_player(body)
		# Запускаем диалог
		Dialogic.start(timeline_name)
		# Отключаем коллизию чтобы диалог не повторялся
		$CollisionShape2D.disabled = true

func turn_towards_player(player: CharacterBody2D):
	var player_position = player.global_position
	var npc_position = global_position
	
	# Поворачиваем спрайт к игроку
	if player_position.x > npc_position.x:
		anim.flip_h = false
	else:
		anim.flip_h = true

func on_death():
	position = spawn_position
