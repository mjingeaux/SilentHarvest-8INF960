class_name FootStepSound extends Node2D

var _sound_list: Array[AudioStreamPlayer2D]
var _init_volume_list: Array[float]

var terrain_type := GlobalE.Esoil_type.grass
var is_slow := false
@export var is_muted := false : set = _set_mute
@export var overall_volume := 1.  : set = _set_overall_volume

var _current_sound_id := -1
	
func play():
	if (is_muted):
		return
	var new_sound_id = _get_sound_id()
	if (new_sound_id == _current_sound_id):
		return
	
	_sound_list[_current_sound_id].stop()
	_sound_list[new_sound_id].play()
	_current_sound_id = new_sound_id
	
func stop():
	if (_current_sound_id != -1):
		_sound_list[_current_sound_id].stop()
	_current_sound_id = -1
	
func set_current_volume(delta_vol : float):
	if (_current_sound_id == -1):
		return
	_sound_list[_current_sound_id].volume_db = _init_volume_list[_current_sound_id] + delta_vol
	

func _ready() -> void:
	for sound in get_children():
		_sound_list.append(sound)
		_init_volume_list.append(sound.volume_db)
		if (sound.stream is AudioStreamRandomizer):
			sound.finished.connect(_on_randomised_sound_finished)
	
	_set_overall_volume(overall_volume)
		
func _on_randomised_sound_finished():
	_sound_list[_current_sound_id].play()
		
func _get_sound_id():
	match terrain_type:
		GlobalE.Esoil_type.grass:
			return 1 if is_slow else 0
		GlobalE.Esoil_type.dirt:
			return 3 if is_slow else 2
		_:
			return 0
		
func _set_mute(val : bool):
	is_muted = val
	stop()

func _set_overall_volume(val : float):
	if (val != 1):
		pass
	var vol = -30. * (1-val) if val < 1. else 24. * (val-1)
	for i in range(_init_volume_list.size()):
		_init_volume_list[i] = vol
		_sound_list[i].volume_db = vol
