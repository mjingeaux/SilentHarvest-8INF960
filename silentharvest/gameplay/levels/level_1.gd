class_name Level_1 extends BaseLevel

var TUTO = preload("res://GUI/HUD/crouch_tuto.tscn")

var tuto_entered := true #set to false in gamemanager if it's first attempt 
var call_destroy := false
var tuto_node : CanvasLayer

func _ready() -> void:
	super()
	PlayerManager.clear_inventory()
	Inventory_Hud.show()


func _on_tuto_zone_body_entered(body: Node2D) -> void:
	if (!tuto_entered && body is Player):
		tuto_entered = true
		tuto_node = TUTO.instantiate()
		add_child(tuto_node)
		
func _input(event: InputEvent) -> void:
	if (tuto_entered && !call_destroy && event.is_action("crouch")):
		call_destroy = true
		await get_tree().create_timer(1.2).timeout
		if (is_instance_valid(tuto_node)):
			tuto_node.hide_and_destroy()


func _on_end_zone_body_entered(body: Node2D) -> void:
	if (body is Player):
		get_node("/root/GameManager").load_level(6)
