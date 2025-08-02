class_name Virus
extends CharacterBody3D

@export var movement_speed: float = 5.0
@export var rotation_speed: float = 4.0
@export var fast_rotation_speed: float = 20.0

@onready var navigation_agent = $NavigationAgent3D

var has_target := false

# func _unhandled_input(event: InputEvent) -> void:
#     #navigation_agent.target_position = 
#     pass

func set_target(new_target: Vector3):
    navigation_agent.target_position = new_target
    has_target = true

func _physics_process(delta: float) -> void:
    if has_target:
        var destination = navigation_agent.get_next_path_position()
        var local_destination = global_position.direction_to(destination)

        var direction = local_destination.normalized()

        velocity = direction * movement_speed

        if navigation_agent.is_navigation_finished():
            has_target = false
            velocity = Vector3.ZERO

        var target_rotation := direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
        if abs(target_rotation - rotation.y) > deg_to_rad(60):
            rotation.y = move_toward(rotation.y, target_rotation, delta * fast_rotation_speed)
        else:
            rotation.y = move_toward(rotation.y, target_rotation, delta * rotation_speed)

    move_and_slide()
