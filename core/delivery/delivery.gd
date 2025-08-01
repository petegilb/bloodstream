class_name Delivery
extends Resource

@export var source: Room = null
@export var destination: Room = null
@export var delivery_type: GameManager.DELIVERY_TYPE = GameManager.DELIVERY_TYPE.OXYGEN


var delivery_status = GameManager.DELIVERY_STATUS.STARTED

func _to_string() -> String:
    return "Deliver %s from %s to %s!" % [str(delivery_type), str(source), str(destination)]
