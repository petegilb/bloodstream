class_name Room
extends Resource

@export var room_name: String = "Unknown Room"

func _to_string() -> String:
    return room_name
