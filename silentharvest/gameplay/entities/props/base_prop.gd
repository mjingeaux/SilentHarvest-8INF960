class_name BaseProp extends StaticBody2D

# Can be extended to specify advanced interraction, but can be attached to a basic scene prop as 
# such to provide a basic obstacle that hinder vision

var _fading_area : Area2D

var _should_fade := false
var _alpha_from := 1.0
var _alpha_dest := 1.0
var _fading_progress := 1.0

func _ready() -> void:
	_fading_area = $FadingArea
	
	_fading_area.body_entered.connect(_on_hiding_body)
	_fading_area.body_exited.connect(_on_not_hiding_body)
	
	
func _process(delta: float) -> void:
	pass
	#if (_should_fade):
		#_fading_progress += delta * sign(_alpha_dest - _alpha_from)
		#var new_alpha = smoothstep(_alpha_from, _alpha_dest, _fading_progress)
		#modulate.a = new_alpha
		#if (new_alpha == _alpha_dest):
			#_should_fade = false
	
	
func _on_hiding_body(body : Node2D):
	if (body is Player):
		_should_fade = true
		_alpha_dest = .3
		_alpha_from = 1.

func _on_not_hiding_body(body : Node2D):
	if (body is Player):
		_should_fade = true
		_alpha_dest = 1.
		_alpha_from = .3


func _on_fading_area_body_entered(body: Node2D) -> void:
	_on_hiding_body(body)

func _on_fading_area_body_exited(body: Node2D) -> void:
	_on_not_hiding_body(body)
