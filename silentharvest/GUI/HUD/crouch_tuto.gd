extends CanvasLayer

@onready var sprite: AnimatedSprite2D = $ColorRect/AnimatedSprite2D
@onready var ap: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	sprite.play("default")
	ap.play("slide")
	
func hide_and_destroy():
	ap.play_backwards("slide")
	await ap.animation_finished
	queue_free()
