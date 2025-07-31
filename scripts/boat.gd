extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@export var forward_row_force := 20
@export var backward_row_force := 10
@export var turn_force := 2
@export var depth_bias := .5

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes: Array[Node] = $ProbeContainer.get_children()

var submerged = false

# References: https://www.youtube.com/watch?v=_R2KDcAp1YQ, https://www.youtube.com/watch?v=UaOQdMKQrjA

var mouse_movement = Vector2()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _physics_process(_delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and mouse_movement != Vector2():
		$CameraPivot.rotation_degrees.y += -mouse_movement.x
		$CameraPivot/CameraTilt.rotation_degrees.x += mouse_movement.y
		$CameraPivot/CameraTilt.rotation_degrees.x = clamp($CameraPivot/CameraTilt.rotation_degrees.x, 0, 90)

		mouse_movement = Vector2()
	
	submerged = false
	for p in probes:
		var depth = p.water_height - p.global_position.y + depth_bias
		# if p.in_water and depth > 0:
		# what happens if we're not in water lol
		if p.in_water and depth > 0:
			submerged = true
			var force = Vector3.UP * float_force * gravity * depth
			apply_force(force, p.global_position - global_position)
	
	if submerged:
		if Input.is_action_pressed("move_forward"):
			apply_central_force(global_transform.basis.z*forward_row_force)
		if Input.is_action_pressed("move_backward"):
			apply_central_force(-global_transform.basis.z*forward_row_force)
		if Input.is_action_pressed("move_left"):
			apply_torque(Vector3(0, 1, 0)*turn_force)
		if Input.is_action_pressed("move_right"):
			apply_torque(Vector3(0, -1, 0)*turn_force)
		

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
