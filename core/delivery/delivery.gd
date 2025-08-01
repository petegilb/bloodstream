class_name Delivery
extends Resource

enum DELIVERY_STATUS {STARTED, RETRIEVED, DELIVERED, FAILED = -1}
enum DELIVERY_TYPE {OXYGEN, C02, OTHER = -1}

@export var source: Room = null
@export var destination: Room = null
@export var delivery_type: DELIVERY_TYPE = DELIVERY_TYPE.OXYGEN


var delivery_status = DELIVERY_STATUS.STARTED

func _to_string() -> String:
    return "Delivery type: %s [ %s -> %s]" % [str(delivery_type), str(source), str(destination)]
