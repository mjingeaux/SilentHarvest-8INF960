class_name HumanEnemy extends Enemy


func _on_poi_timer_temp_timeout() -> void:
	poi_finished.emit()
