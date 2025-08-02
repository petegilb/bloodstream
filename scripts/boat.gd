class_name BoatCharacter
extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05
@export var river_passive_force := 5

@export var forward_row_force := 20
@export var backward_row_force := 10
@export var turn_force := 2
@export var depth_bias := .5
@export var non_submerged_movement_modifer := .4
@export var arrow_lerp_speed := 5.0

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes: Array[Node] = $ProbeContainer.get_children()
@onready var arrow := $Arrow
@onready var accelerate_sound: AudioStreamPlayer3D = $Accelerate
@onready var fadeout_sound: AudioStreamPlayer3D = $FadeOut

var submerged = false

# References: https://www.youtube.com/watch?v=_R2KDcAp1YQ, https://www.youtube.com/watch?v=UaOQdMKQrjA

var mouse_movement = Vector2()

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    pass

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    if event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if event is InputEventMouseMotion:
        mouse_movement = event.relative

func _physics_process(delta: float) -> void:
    if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and mouse_movement != Vector2():
        $CameraPivot.rotation_degrees.y += -mouse_movement.x
        $CameraPivot/CameraTilt.rotation_degrees.x += mouse_movement.y
        $CameraPivot/CameraTilt.rotation_degrees.x = clamp($CameraPivot/CameraTilt.rotation_degrees.x, 0, 90)

        mouse_movement = Vector2()

    var collision_object: Path3D = null
    submerged = false
    for p in probes:
        var depth = p.water_height - p.global_position.y + depth_bias
        # if p.in_water and depth > 0:
        # what happens if we're not in water lol
        if p.in_water and depth > 0:
            submerged = true
            if p.collision_object and p.collision_object.get_parent() is Path3D:
                collision_object = p.collision_object.get_parent()
            var force = Vector3.UP * float_force * gravity * depth
            apply_force(force, p.global_position - global_position)
    
    if submerged:
        # river flow
        if collision_object != null:
            var curve = collision_object.curve
            var closest_offset = curve.get_closest_offset(global_position)
            var river_forward_direction = curve.sample_baked(closest_offset, true).direction_to(curve.sample_baked(closest_offset + .1, true)).normalized()
            apply_central_force(river_forward_direction*river_passive_force)

        if Input.is_action_pressed("move_forward"):
            apply_central_force(global_transform.basis.z*forward_row_force)
            if not accelerate_sound.playing:
                accelerate_sound.play()
        if Input.is_action_pressed("move_backward"):
            apply_central_force(-global_transform.basis.z*forward_row_force)
            if not accelerate_sound.playing:
                accelerate_sound.play()
            if Input.is_action_pressed("move_left"):
                apply_torque(Vector3(0, -1, 0)*turn_force)
            if Input.is_action_pressed("move_right"):
                apply_torque(Vector3(0, 1, 0)*turn_force)
        else:
            if Input.is_action_pressed("move_left"):
                apply_torque(Vector3(0, 1, 0)*turn_force)
            if Input.is_action_pressed("move_right"):
                apply_torque(Vector3(0, -1, 0)*turn_force)
    else:
        # allow moving outside of water just in case (it's weaker than normal)
        if Input.is_action_pressed("move_forward"):
            apply_central_force(global_transform.basis.z*forward_row_force * non_submerged_movement_modifer)
        if Input.is_action_pressed("move_backward"):
            apply_central_force(-global_transform.basis.z*forward_row_force * non_submerged_movement_modifer)
            if Input.is_action_pressed("move_left"):
                apply_torque(Vector3(0, -1, 0)*turn_force)
            if Input.is_action_pressed("move_right"):
                apply_torque(Vector3(0, 1, 0)*turn_force)
        else:
            if Input.is_action_pressed("move_left"):
                apply_torque(Vector3(0, 1, 0)*turn_force)
            if Input.is_action_pressed("move_right"):
                apply_torque(Vector3(0, -1, 0)*turn_force)

    if not (Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backward")):
        if accelerate_sound.playing:
            fadeout_sound.play(1.0)
            accelerate_sound.stop()

    if GameManager._current_delivery != null and GameManager._current_delivery.delivery_status != GameManager.DELIVERY_STATUS.DELIVERED:
        # update arrow position
        if len(GameManager.shortest_path_arr) > 1:
            arrow.visible = true
            var target_node = GameManager.room_to_bounds.get(GameManager.room_name_to_resource.get(GameManager.shortest_path_arr[1]))
            # print(target_node, target_node.global_position)
            if target_node != null:
                var direction = (target_node.global_position - arrow.global_position).normalized()
                var target_basis = Basis.looking_at(direction, Vector3.UP)
                arrow.global_transform.basis = arrow.global_transform.basis.slerp(target_basis, delta * arrow_lerp_speed)
        else:
            arrow.visible = false
    else:
        arrow.visible = false
        
        

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    if submerged:
        state.linear_velocity *= 1 - water_drag
        state.angular_velocity *= 1 - water_angular_drag 
