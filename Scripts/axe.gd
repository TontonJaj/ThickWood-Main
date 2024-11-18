extends Node3D

@onready var animation_player = $"../../../../../AnimationPlayer"
@onready var raycasts = $Cube_001/Area3D/RayCast3D
@onready var player = $"../../../../../"

var is_swinging = false
var choppedAlready = false
var collidedTreeDictionnary = {
	"collider": null,
	"basisArray": [],
	"bottom": null,
	"depth": null,
	"top": null
}
func clearcollidedTreeDictionnary() -> void:
	collidedTreeDictionnary.collider = null
	collidedTreeDictionnary.basisArray = []
	collidedTreeDictionnary.top = null
	collidedTreeDictionnary.depth = null
	collidedTreeDictionnary.bottom = null

func _ready() -> void:
	disable_all_raycasts()

func _process(_delta: float) -> void:
	if is_swinging:
		collision_all_raycasts_on_tree()

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "metarig|Chop":
		start_swing()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "metarig|Chop":
		end_swing()

func start_swing() -> void:
	if player.playerFixed != true:
		is_swinging = true
		enable_all_raycasts()
		clearcollidedTreeDictionnary()
		choppedAlready = false

func end_swing() -> void:
	is_swinging = false
	disable_all_raycasts()

func enable_all_raycasts() -> void:
	for raycast in raycasts.get_children():
		if raycast is RayCast3D:
			raycast.enabled = true
			
func disable_all_raycasts() -> void:
	for raycast in raycasts.get_children():
		if raycast is RayCast3D:
			raycast.enabled = false

func collision_all_raycasts_on_tree() -> void:
	if !choppedAlready and collidedTreeDictionnary.top and collidedTreeDictionnary.depth and collidedTreeDictionnary.bottom and collidedTreeDictionnary.basisArray.size() == 3:
		handle_tree_collision()
		return
	for raycast in raycasts.get_children():
		if raycast is RayCast3D and raycast.is_colliding() and raycast.get_collider().name == "DeadTreeStatic": #need another condition for multiple trees
			if !collidedTreeDictionnary.collider:
				collidedTreeDictionnary.collider = raycast.get_collider()
			if raycast.name == "RayCast3DTop" and !collidedTreeDictionnary.top:
				collidedTreeDictionnary.top = raycast.get_collision_point()
				collidedTreeDictionnary.basisArray.append(raycasts.global_transform.basis)
			if raycast.name == "RayCast3DDepth" and !collidedTreeDictionnary.depth:
				collidedTreeDictionnary.depth = raycast.get_collision_point()
				collidedTreeDictionnary.basisArray.append(raycasts.global_transform.basis)
			if raycast.name == "RayCast3DBottom" and !collidedTreeDictionnary.bottom:
				collidedTreeDictionnary.bottom = raycast.get_collision_point()
				collidedTreeDictionnary.basisArray.append(raycasts.global_transform.basis)

func handle_tree_collision() -> void:
	choppedAlready = true
	$Cube_001/Area3D/CPUParticles3D.emitting = true
	$Cube_001/Area3D/Pop.playing = true
	collidedTreeDictionnary.collider.find_parent("Trees").handleChop(collidedTreeDictionnary)
	
