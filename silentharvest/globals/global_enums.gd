class_name GlobalEnum extends Node

#name with EnameOfTheEnum

enum Edirection{
	north = 0,
	n = north,
	
	east = 1,
	e = east,
	
	south = 2,
	s = south,
	
	west = 3,
	w = west
}

enum EitemType{
	carrot = 0,
	potato = 1
}

enum Epoi_type{
	wait_short,
	wait_long,
	
	right_then_left_narrow,
	right_then_left_wide,
	left_then_right_narrow,
	left_then_right_wide,
	
	left_trick,
	right_trick,
	
	cw_full_turn,
	ccw_full_turn,
}

enum Esoil_type{
	grass = 0,
	dirt = 1
}
