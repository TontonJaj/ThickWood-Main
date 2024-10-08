extends CharacterBody3D

@export var MOVE_SPEED = 5
@export var FALL_ACCELERATION = 9
@export var JUMP_VELOCITY = 4.5
@export var mouse_sensitivity: float = 0.1

@onready var camera_mount = $CameraMount
@onready var camera = $CameraMount/Camera3D
@onready var animation_player = $AnimationPlayer

var input_dir = Vector2.ZERO
var snap_vector = Vector3.DOWN
var is_chopping = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_chop_animation()

func start_chop_animation():
	is_chopping = true
	animation_player.play("metarig|Chop")
	# Wait for the animation to finish
	await animation_player.animation_finished
	is_chopping = false

func _physics_process(delta):
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		snap_vector = -get_floor_normal()
		if Input.is_action_just_pressed("jump"):
			snap_vector = Vector3.ZERO
			velocity.y = JUMP_VELOCITY
	else:
		snap_vector = Vector3.DOWN
		velocity.y -= FALL_ACCELERATION * delta
	
	if direction and not is_chopping:
		velocity.x = direction.x * MOVE_SPEED
		velocity.z = direction.z * MOVE_SPEED
		if not animation_player.is_playing() or animation_player.current_animation != "metarig|walking":
			animation_player.play("metarig|walking")
			animation_player.set_speed_scale(1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED)
		if animation_player.is_playing() and animation_player.current_animation == "metarig|walking":
			animation_player.stop()
	
	move_and_slide()

func _process(_delta):
	camera.global_transform = camera_mount.global_transform
