class_name BaseProp extends StaticBody2D

# Can be extended to specify advanced interraction, but can be attached to a basic scene prop as 
# such to provide a basic obstacle that hinder vision



func _ready() -> void:
	collision_layer = collision_layer | 256
	
	
func _process(_delta: float) -> void:
	pass
