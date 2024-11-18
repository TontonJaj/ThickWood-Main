extends Node3D


var increment = 0
var enabled = false
var mouse_x = 0

@onready var vehicle = get_parent()
@onready var player = $"../Player"


func _ready()-> void:
	pass


func attach_charrette_to_player(player):
	$"../Player/metarig/Skeleton3D/HeadCamera".rotation_degrees.x = 0
	$"../Player/metarig/Skeleton3D/HeadCamera".rotation_degrees.y = 0


func _process(delta: float) -> void:
	pass


func _on_area_3d_charrette_t_1_body_entered(body: CharacterBody3D):
	attach_charrette_to_player(player)
	print("sss")
