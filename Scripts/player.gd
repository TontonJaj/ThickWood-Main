#I need to fix that shit, make the rigman simpler
#also the head is choppy when animation finishes

extends CharacterBody3D

var speed : float = WALK_SPEED #what 
const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
var camera_pitch = 0.0  # Variable to track the camera's pitch (vertical rotation tracker)

var statspoints : int = 10

#LEVELING SYSTEM
var level : int = 1

var experience = 0
var experience_total = 0
var experience_required = get_required_experience(level +1)

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

#PlAYER STAT
var strength : int = 10
var stamina : int = 10
var charisma : int = 10
var agility : int = 10

#var speed : int = 10 for animation speed ? faster cut cut and also better penetration if we create a damage dealt per hit variable or something
var staminaRegenStat = 0.3
var staminaDegenStat = 0
var staminaFull : bool = true
var sprintDegenValue = 0.2
var holdDegenValue = 0.2
var staminaValue : float = 100

var playerFixed = false
var picked : bool = false
var is_chopping = false
var is_sprinting = false
var locked = false  #prevent player looking around while using the rotation motion on a log
var is_jumping = false

var XP = 0

#CHARACTER onreadys
@onready var head = $metarig/Skeleton3D/HeadCamera/Head
@onready var body = $metarig
@onready var camera = $metarig/Skeleton3D/HeadCamera/Head/Camera3D
@onready var interaction = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/Interaction
@onready var hand = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/Hand
@onready var animation_player = $AnimationPlayer
@onready var joint = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/Generic6DOFJoint3D
@onready var staticbody = $metarig/Skeleton3D/HeadCamera/Head/Camera3D/StaticBody3D
@onready var wallet = $"../GUI/PlayerInfo/Wallet"
#GUI onreadys
@onready var staminaBar = $"../GUI/PlayerInfo/StaminaBar"

func get_required_experience(levelIn):
	return round(pow(levelIn, 2) + levelIn * 4)  #https://www.desmos.com/calculator/0r0mrngda2?lang=fr     

func gain_experience(amount):
	experience_total += amount
	experience+= amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
	
func level_up(): 
	level += 1
	experience_required = get_required_experience(level + 1)
	statspoints += 3
	print("you have now : ", statspoints," stats points")



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func pickTreeIfTree():
	var collider = interaction.get_collider()
	if collider is RigidBody3D and collider.is_in_group("trees"):
		picked_object = collider
		print("eee")
		if picked_object.mass / strength < staminaValue: #condition to pick something, u need to have strength left
			print("222")
			print ("object mass is :" , picked_object.mass , "stam used: " , picked_object.mass / strength )
			staminaValue -= picked_object.mass / strength
			joint.set_node_b(picked_object.get_path()) #glue the object to generic6DOjoint3D, acting like an anchor that is attached to the player hand
			picked = true
			staminaDegenStat += holdDegenValue
			staminaBar.update_stamina_bar()
			staminaBar.timer_control()
			
		
func drop_object():
	if picked == true:
		picked = false
		joint.set_node_b(joint.get_path())
		staminaDegenStat -= holdDegenValue
		staminaBar.timer_control()

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			staticbody.rotate_y(deg_to_rad(event.relative.x * rotation_power))


func _unhandled_input(event):
	if event is InputEventMouseMotion and !locked:
		body.rotate_y(-event.relative.x * SENSITIVITY)
		#head.rotate_y(-event.relative.x * SENSITIVITY)
		
		# Update the camera pitch based on mouse movement (up/down)
		camera_pitch -= event.relative.y * SENSITIVITY
		camera_pitch = clamp(camera_pitch, deg_to_rad(-40), deg_to_rad(60))

		# Instead of directly modifying camera.rotation.x, we first update camera_pitch based on mouse movement and then clamp it.
		camera.rotation.x = camera_pitch

func _input(event):
	if Input.is_action_just_pressed("pick_up"):
		if picked == false:
			pickTreeIfTree()
		elif picked == true:
			drop_object()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and staminaValue>=5:#stamina>10 for the moment but will need to be > than required stamina, determined by axe_stamina_requirement
			if is_chopping == false and playerFixed != true:
				start_chop_animation() 
				staminaValue -= 5#lose_stamina()#depend on the axe used in this case
				staminaBar.update_stamina_bar()
				
	if Input.is_action_pressed("rotate"):
		locked = true
		rotate_object(event)
	if Input.is_action_just_released("rotate"):
		locked = false

	

func _physics_process(delta):
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and playerFixed != true and staminaValue >= 15:
		velocity.y = JUMP_VELOCITY
		$Jump.playing = true
		is_jumping = true
		staminaValue -= 15
		staminaBar.update_stamina_bar()
		staminaBar.timer_control()
		is_jumping = false
		staminaBar.timer_control()


	#Handle sprint.
	if Input.is_action_just_pressed("sprint"):
		speed = SPRINT_SPEED
		is_sprinting = true
		staminaDegenStat += sprintDegenValue
		staminaBar.timer_control()
		
	
	if Input.is_action_just_released("sprint"):
		speed = WALK_SPEED
		print("whattheheck2")
		is_sprinting = false
		staminaDegenStat -= sprintDegenValue
		staminaBar.timer_control()


	var input_dir = Input.get_vector("left", "right", "up", "down")
	#var direction = -(body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = Vector3(-input_dir.x, 0, -input_dir.y)
	direction = direction.rotated(Vector3.UP, body.rotation.y)
	
	if playerFixed != true: #cant move if for exemple is in caracteristic menu
		if is_on_floor() and direction:
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if not animation_player.is_playing():
				animation_player.play("metarig|walking")
				animation_player.set_speed_scale(1.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
			
	else: #gradually reduce velocity when player is fixed
		velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 10.0)
		
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
	

	
			

			 

			
			#$GUI/PlayerInfo/CaracteristicPanel.visible = false
	
			
	move_and_slide()

	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func start_chop_animation():
	is_chopping = true
	staminaBar.timer_control()

	animation_player.play("metarig|Chop")
	# Wait for the animation to finish
	await animation_player.animation_finished
	is_chopping = false
	staminaBar.timer_control()
