extends RigidBody3D

var mouse_movement = Vector2()
var in_water = false

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

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
    pass