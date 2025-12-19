extends Area2D

enum item_type {ITEM_SOUL, ITEM_KEY, ITEM_D_JUMP, ITEM_BONUS}

@export var type : item_type

#количество очков
@export var points : int = 1
var is_picked : bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Уникальный идентификатор для этой души
@export var soul_id : String = ""

func _ready() -> void:
	# Генерируем уникальный ID если он не задан
	if soul_id == "":
		soul_id = str(get_tree().current_scene.name) + "_" + str(global_position.x) + "_" + str(global_position.y)
	
	# Проверяем, не была ли уже собрана эта душа
	if type == item_type.ITEM_SOUL and GlobalVars.is_soul_collected(soul_id):
		queue_free()
		return
	
	# Подключаем сигнал
	body_entered.connect(on_pickup)

func _process(delta: float) -> void:
	pass

func on_pickup(body):
	if is_picked:
		return
	
	# Проверяем, что это игрок
	if not body.is_in_group("player"):
		return
		
	is_picked = true
	
	$AudioStreamPlayer.play()
	anim.play("collect")
	GlobalVars.score += points

	# Если это душа - сохраняем её ID
	if type == item_type.ITEM_SOUL:
		GlobalVars.add_collected_soul(soul_id)  # Изменено здесь!

	await $AudioStreamPlayer.finished
	if GlobalVars.score > GlobalVars.hi_score:
		GlobalVars.hi_score = GlobalVars.score
		GlobalVars.update_hi_score(GlobalVars.score)
		if has_node("Record"):
			$Record.play()
			await $Record.finished
		
	match type:
		item_type.ITEM_SOUL:
			pass
		item_type.ITEM_KEY:
			if body.has_method("set_has_key"):
				body.set_has_key(true)
		item_type.ITEM_BONUS:
			pass
		item_type.ITEM_D_JUMP:
			if body.has_method("set_has_double_jump"):
				body.set_has_double_jump(true)
				await get_tree().create_timer(10.0).timeout
				if body.has_method("set_has_double_jump"):
					body.set_has_double_jump(false)
	
	queue_free()
