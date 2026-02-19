extends CanvasLayer

@onready var text_label = $TextLabel
@onready var type_sound = $TypeSound



var screens = [
	"В центре леса сиял КАМЕНЬ МУДРОСТИ.\n\nОн давал жизнь всему живому...",
	"Но КОРОЛЬ возненавидел МОНСТРОВ,\nчто жили в гармонии с лесом.",
	"Из жадности и злобы он ВЫРВАЛ камень,\nспрятав его в темных ПОДЗЕМЕЛЬЯХ.",
	"Без света камня лес стал ЗАСЫХАТЬ,\nи тишина накрыла землю...",
	"Но одна девочка по имени ВИ\nне могла смотреть на гибель леса.",
	"Она бросила вызов КОРОЛЮ,\nчтобы вернуть КАМЕНЬ и спасти МОНСТРОВ.",
	"Ви отправилась в опасный путь,\nведомая надеждой и любовью к жизни.",
	"Ей предстоит спуститься в ПОДЗЕМЕЛЬЯ\nи восстановить ГАРМОНИЮ...\n\n[Нажмите ПРОБЕЛ]"
]

var current_screen = 0
var is_typing = false
var text_to_type = ""

func _ready():
	show_screen(0)

func _process(_delta):

	if Input.is_action_just_pressed("ui_accept"):
		if is_typing:
			text_label.text = text_to_type
			is_typing = false
		else:
			# Следующий экран
			next_screen()

func show_screen(screen_index):
	if screen_index >= screens.size():
		epic_fade_transition()
		return
	
	current_screen = screen_index
	text_to_type = screens[screen_index]
	start_typing(text_to_type)

func start_typing(text):
	is_typing = true
	text_label.text = ""
	
	var shake_words = ["КАМЕНЬ", "КОРОЛЬ", " МОНСТРОВ", "ВЫРВАЛ", "ПОДЗЕМЕЛЬЯХ", "ЗАСЫХАТЬ", "ВИ", "ПОДЗЕМЕЛЬЯ", "ГАРМОНИЮ"]
	
	for i in range(text.length()):
		if not is_typing:
			break
		
		var char = text[i]
		text_label.text += char
		
		for word in shake_words:
			if i + word.length() <= text.length():
				if text.substr(i, word.length()) == word:
					await shake_effect()
		
		if type_sound and char != " " and char != "\n":
			type_sound.pitch_scale = randf_range(0.8, 1.2)
			type_sound.play()
		
		await get_tree().create_timer(get_char_delay(char)).timeout
	
	is_typing = false

func get_char_delay(char):
	if char == ",":
		return 0.2
	elif char == "." or char == "!" or char == "?":
		return 0.35
	else:
		return 0.05

func shake_effect():
	var original_pos = text_label.position
	var strength = 5
	
	for _j in range(6):
		text_label.position.x = original_pos.x + randf_range(-strength, strength)
		text_label.position.y = original_pos.y + randf_range(-strength, strength)
		await get_tree().create_timer(0.01).timeout
	
	text_label.position = original_pos

func next_screen():
	current_screen += 1
	show_screen(current_screen)

func epic_fade_transition():
	# Блокируем ввод во время перехода
	set_process(false)

	# Этап 1: Медленное исчезновение текста (7 секунд)
	var stage1 = create_tween()
	stage1.tween_property(text_label, "modulate:a", 0.0, 6.0)
	stage1.set_ease(Tween.EASE_IN_OUT)
	
	# Этап 2: Появление черного оверлея (начинается позже, длится дольше)
	if has_node("BlackOverlay"):
		var overlay = $BlackOverlay
		overlay.visible = true
		overlay.modulate.a = 0
		
		# Ждем немного перед началом затемнения
		await get_tree().create_timer(2.0).timeout
		
		var stage2 = create_tween()
		stage2.tween_property(overlay, "modulate:a", 1.0, 5.0)
		stage2.set_ease(Tween.EASE_IN)
		await stage2.finished
	
	await stage1.finished
	
	# Этап 3: Долгая пауза на черном экране (5 секунд)
	await get_tree().create_timer(3.0).timeout
	
	# Финальный переход
	get_tree().change_scene_to_file("C:/Users/HIKARA/Documents/GitHub/Escape-from-dungeon-/Menus/main_menu.tscn")

# ИЛИ просто замените функцию end_intro() на эту:

func end_intro():
	# Увеличил время затухания до 5 секунд
	var tween = create_tween()
	
	# Медленное затухание текста (5 секунд)
	tween.tween_property(text_label, "modulate:a", 0.0, 3.0)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Ждем полного завершения анимации
	await tween.finished
	
	# Дополнительная пауза после исчезновения текста (3 секунды)
	await get_tree().create_timer(1.5).timeout
	
	# Переход к игре
	get_tree().change_scene_to_file("C:/Users/HIKARA/Documents/GitHub/Escape-from-dungeon-/Menus/main_menu.tscn")
