class_name RoomBounds
extends Node3D

@export var room_resource: Room = null
@onready var area3d: Area3D = $Area3D

func _ready() -> void:
    if room_resource == null:
        printerr("no room resource assigned in %s" % [self])
        return

# func _physics_process(_delta: float) -> void:

func _on_area_3d_body_entered(_body:Node3D) -> void:
    GameManager.set_current_room(self)

func _on_area_3d_body_exited(_body:Node3D) -> void:
    GameManager.set_current_room(null)

func _to_string() -> String:
    return room_resource._to_string()
