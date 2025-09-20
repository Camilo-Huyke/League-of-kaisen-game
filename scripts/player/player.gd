extends CharacterBody3D
class_name Player

var speed: int = 20
var JUMP_VELOCITY: int = 10
var health: int

var direction: Vector3 = Vector3()
@export var pos_server: Vector3
@export var dir_server: Vector3
@export var navigation_fini_server:bool
@export var curr_state_server: state
@export var targ_pos_server: Vector3

@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $AuxScene/AnimationPlayer
@onready var health_bar: Sprite2D = $SubViewport/Health_bar

enum state {IDLE, WALK, CTRL_ANIMATION}
enum ctrl_animations {CTRL_1}
var current_ctrl_animation: ctrl_animations
var current_state: state
var prev_state: state

var idle_animation: String = "mixamo_com"
var walking_animation: String = "Walking"
var ctrl_1_animation:String = "Flair"

func _init() -> void:
	health = 1040
	
func _ready() -> void:
	change_state(state.IDLE)
	if not str(multiplayer.get_unique_id()) == self.name:
		if camera:
			if not multiplayer.is_server():
				camera.queue_free()
	else:
		if camera:
			camera.make_current()
			
	health_bar.init_health(health)

func _input(event: InputEvent) -> void:
	if not str(multiplayer.get_unique_id()) == self.name:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			get_world_pos()
			change_state(state.WALK)
			
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 and event.ctrl_pressed:
			#rpc_id(1, "input_request_ctrl_animation")
			input_request_ctrl_animation.rpc_id(1)
			
func _physics_process(delta: float) -> void:
	#if not multiplayer.is_server():
		#return
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		
	update_state(delta)
	
func _process(delta: float) -> void:
	if multiplayer.is_server():
		pos_server = position
		#dir_server = direction
		#navigation_fini_server = navigation_agent.is_navigation_finished()
		curr_state_server = current_state
		#targ_pos_server = navigation_agent.target_position
		
		
func get_world_pos():
	var mouse_pos = get_viewport().get_mouse_position();
	var ray_length = 180
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from;
	ray_query.to = to;
	var result = space.intersect_ray(ray_query)
	if result:
		navigation_agent.target_position = result.position
		input_request_move.rpc_id(1, result.position)
		#print(result)
		#print(navigation_agent.is_target_reachable())
		#print(navigation_agent.distance_to_target())
		#print('Intercepted')
	#else:
		#print('No intercepted')

#State machine
func change_state(new_state: state):
	exit_state(current_state)
	
	prev_state = current_state
	current_state = new_state
	
	enter_state(new_state)
	
func exit_state(_state: state):
	match _state:
		state.IDLE:
			pass
		state.CTRL_ANIMATION:
			animation_player.stop()
	
func enter_state(_state: state):
	match _state:
		state.IDLE:
			animation_player.play(idle_animation)
		state.WALK:
			animation_player.play(walking_animation)
			
func update_state(delta):
	match current_state:
		state.IDLE:
			idle_state(delta)
		state.WALK:
			walk_state(delta)
		state.CTRL_ANIMATION:
			ctrl_animation()
# estados
func walk_state(delta):
	if multiplayer.is_server() or (int(self.name) == multiplayer.get_unique_id()):
		direction = (navigation_agent.get_next_path_position() - global_position).normalized()
		#print(navigation_agent.distance_to_target())
		
		if navigation_agent.distance_to_target() < 0.1 or navigation_agent.is_navigation_finished() or position == navigation_agent.target_position:
			velocity.x = 0
			velocity.z = 0
			animation_player.stop()
			change_state(state.IDLE)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			#velocity = direction * speed
			if multiplayer.is_server():
				$AuxScene.look_at(position + Vector3(-direction.x, 0, -direction.z), Vector3.UP)
			animation_player.play(walking_animation)
		
		move_and_slide()
	else:
		direction = (pos_server - position).normalized()
		#print(multiplayer.get_unique_id(), " ", self.name, " ", direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		move_and_slide()

func idle_state(delta):
	# Add the gravity.
	if not multiplayer.is_server():
		return
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	move_and_slide()
	
func ctrl_animation():
	match current_ctrl_animation:
		ctrl_animations.CTRL_1:
			animation_player.play(ctrl_1_animation)

#inputs request
@rpc("any_peer", "call_local", "unreliable")
func input_request_move(_target_position):
	#get_world_pos(mouse_pos)
	navigation_agent.target_position = _target_position
	change_state(state.WALK)
	
@rpc("any_peer", "call_local", "unreliable")
func input_request_ctrl_animation():
	current_ctrl_animation = ctrl_animations.CTRL_1
	change_state(state.CTRL_ANIMATION)
	
func _on_multiplayer_synchronizer_synchronized() -> void:
	if self.position.distance_to(pos_server) > 4:
		self.position = lerp(self.position, pos_server, 0.5)
		
	if not multiplayer.is_server():
		if current_state != curr_state_server:
			change_state(curr_state_server)
