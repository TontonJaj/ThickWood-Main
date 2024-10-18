#I need to fix that shit, make the rigman simpler
#also the head is choppy when animation finishes

extends CharacterBody3D

var speed #what 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

#BOB Variables
const  BOB_FREQ = 2.0
const BOB_AMP = 0.04
var t_bob = 0.0 # var name not relatable

const BASE_FOV = 75.0
const FOV_CHANGE = 0.1

const gravity = 9.8

var picked_object = null
var rotation_power = 0.05
#not sure if we're handling these switches correctly

#MOST DEFINITIVIELY SOMETHING TO CARE FOR !!!! WHEN THE FUCKING OBJECT GETS OUT OF CONTROL OF PICKING
#OR IS SOLD WITHOUT PRESSING 'E' OR CALLING DROP_OBJECT THERE IS NO REINITIALISATION OF STATES!

const pull_power = 8

#CHARACTER onreadys
@onready var head = $metarig/Skeleton3D/HeadCamera/Head
@onready var body = $metarig
@onready var camera = $metarig/Skeleton3D/HeadCamera/Head/Camera3D
@onready var interaction = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/Interaction
@onready var hand = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/Hand
@onready var animation_player = $AnimationPlayer
@onready var joint = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/Generic6DOFJoint3D
@onready var staticbody = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/StaticBody3D

#GUI onreadys
@onready var staminaBar = $"../GUI/PlayerInfo/StaminaBar"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func pickTreeIfTree():
	var collider = interaction.get_collider()
	if collider is RigidBody3D and collider.is_in_group("trees"):
		picked_object = collider
		if picked_object.mass / Global.strength < Global.staminaValue: #condition to pick something, u need to have strength left
			print ("object mass is :" , picked_object.mass , "stam used: " , picked_object.mass / Global.strength )
			Global.staminaValue -= picked_object.mass / Global.strength
			joint.set_node_b(picked_object.get_path()) #glue the object to generic6DOjoint3D, acting like an anchor that is attached to the player hand
			Global.picked = true
			staminaBar.update_stamina_bar()
			staminaBar.timer_control()
			
		
func drop_object():
	if Global.picked == true:
		Global.picked = false
		joint.set_node_b(joint.get_path())
		staminaBar.timer_control()
		print("picked is now ",Global.picked)

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			staticbody.rotate_y(deg_to_rad(event.relative.x * rotation_power))


func _unhandled_input(event):
	if event is InputEventMouseMotion and !Global.locked:
		body.rotate_y(-event.relative.x * SENSITIVITY)
		#head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _input(event):
	if Input.is_action_just_pressed("pick_up"):
		if Global.picked == false:
			pickTreeIfTree()
		elif Global.picked == true:
			drop_object()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.staminaValue>=5:#stamina>10 for the moment but will need to be > than required stamina, determined by axe_stamina_requirement
			if Global.is_chopping == false:
				start_chop_animation() 
				Global.staminaValue -= 5#lose_stamina()#depend on the axe used in this case
				staminaBar.update_stamina_bar()
				
	if Input.is_action_pressed("rotate"):
		Global.locked = true
		rotate_object(event)
	if Input.is_action_just_released("rotate"):
		Global.locked = false

	

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$Jump.playing = true

	#Handle sprint.
	if Input.is_action_just_pressed("sprint"):
		speed = SPRINT_SPEED
		Global.is_sprinting = true
		Global.staminaDegenStat += Global.sprintDegenValue
		staminaBar.timer_control()
	
	if Input.is_action_just_released("sprint"):
		speed = WALK_SPEED
		Global.is_sprinting = false
		Global.staminaDegenStat -= Global.sprintDegenValue
		staminaBar.timer_control()
	else:
		speed = WALK_SPEED

	var input_dir = Input.get_vector("left", "right", "up", "down")
	#var direction = -(body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = Vector3(-input_dir.x, 0, -input_dir.y)
	direction = direction.rotated(Vector3.UP, body.rotation.y)
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if not animation_player.is_playing():
				animation_player.play("metarig|walking")
				animation_player.set_speed_scale(1.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	#Head BOB
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)	

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	#movement of the log
	if Global.picked == true and picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin 
		picked_object.set_linear_velocity((b-a) * pull_power)
	
	#Opening Gui
	
	
			

			 

			
			#$GUI/PlayerInfo/CaracteristicPanel.visible = false
	
			
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func start_chop_animation():
	Global.is_chopping = true
	animation_player.play("metarig|Chop")
	# Wait for the animation to finish
	await animation_player.animation_finished
	Global.is_chopping = false
	staminaBar.timer_control()
