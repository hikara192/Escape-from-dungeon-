extends Area2D

enum item_type {ITEM_SOUL, ITEM_KEY, ITEM_D_JUMP, ITEM_BONUS}

@export var type : item_type

#количество очков
@export var points : int = 1
var is_picked : bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func on_pickup(body):
	if is_picked:
		return
		
	is_picked = true
	
	
	$AudioStreamPlayer.play()
	anim.play("collect")
	GlobalVars.score += points

	await $AudioStreamPlayer.finished
	if(GlobalVars.score > GlobalVars.hi_score):
		GlobalVars.hi_score = GlobalVars.score
		$Record.play()
		await $Record.finished
		
	match type:
		item_type.ITEM_SOUL:
			pass
		item_type.ITEM_KEY:
			body.has_key = true
		item_type.ITEM_BONUS:
			pass
		item_type.ITEM_D_JUMP:
			body.has_double_jump = true
			await get_tree().create_timer(10.0).timeout
			body.has_double_jump = false
	
	queue_free()
	
