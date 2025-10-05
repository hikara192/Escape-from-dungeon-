extends Node2D
@onready var hp_bar = $"CanvasLayer/hp-bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hp_bar.value = GlobalVars.player_health
