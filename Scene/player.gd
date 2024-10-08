extends CharacterBody3D

var speed #what 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

#BOB Variables
const  BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0 # var name not relatable

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

const gravity = 9.8

var picked_object #zefuck
var picked = Global.picked #zefuck
#zefuck I understand the idea but notice that this will not work with multiple picked objects neither with multiple users

const pull_power = 4

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interaction = $Head/Camera3D/Interaction
@onready var hand = $Head/Camera3D/Hand


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func pickTreeIfTree():
	var collider = interaction.get_collider()
	if collider is RigidBody3D and collider.is_in_group("trees"):
		picked_object = collider
		picked = true
		
func drop_object():
	if picked == true:
		print("picked is ",picked)
		picked = false
		print("picked is now ",picked)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _input(event):
	if Input.is_action_just_pressed("pick_up"):
		if picked == false:
			pickTreeIfTree()
			print("picked_func")
		elif picked == true:
			drop_object()
			print("droped func")
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#Handle sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.x * speed, delta * 2.0)
		
	#Head BOB
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)	

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	#movement of the log
	if picked == true and picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a) * pull_power)
		
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
