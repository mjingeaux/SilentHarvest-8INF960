class_name Level_1 extends BaseLevel

var TUTO = preload("res://GUI/HUD/crouch_tuto.tscn")

var tuto_entered := true #set to false if it's first attempt inb gamemanager
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
	if (tuto_entered && event.is_action("crouch")):
		await get_tree().create_timer(2).timeout
		tuto_node.hide_and_destroy()
