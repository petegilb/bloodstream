extends Node3D

var _current_room: RoomBounds = null
var _current_delivery: Delivery = null

var main_scene: Node3D = null
var gui: Gui = null

func _ready() -> void:
	main_scene = get_tree().current_scene
	gui = main_scene.find_child("Gui")

func set_current_room(new_room) -> void:
	if new_room != _current_room:
		print("Room changed to %s" % [str(new_room)])
		_current_room = new_room
		if _current_room != null:
			gui.set_current_room_label(str(_current_room.room_resource))
		else:
			gui.set_current_room_label('Unknown')

func set_current_delivery(new_delivery) -> void:
	if new_delivery != _current_delivery:
		print("Delivery changed to %s" % [str(new_delivery)])
		_current_delivery = new_delivery
