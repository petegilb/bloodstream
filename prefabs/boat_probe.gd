class_name BoatProbe

extends Node3D

@export var underneath_radius := 8

var in_water = false
var water_height = -100
var last_collision = Vector3(0, water_height, 0)
var collision_object = null

func _physics_process(_delta: float) -> void:
    # water_height = 0
    in_water = $WaterCast.is_colliding() || $UpWaterCast.is_colliding() # || check_underneath()
    if in_water:
        # last_collision = $WaterCast.get_collision_point()
        # water_height = last_collision.y
        if $UpWaterCast.is_colliding():
            last_collision = $UpWaterCast.get_collision_point()
            water_height = last_collision.y
            var possible_collision = $WaterCast.get_collider()
            if possible_collision != null:
                collision_object = possible_collision
        elif $WaterCast.is_colliding():
            last_collision = $WaterCast.get_collision_point()
            water_height = last_collision.y
            var possible_collision = $WaterCast.get_collider()
            if possible_collision != null:
                collision_object = possible_collision
    else:
        collision_object = null

func check_underneath():
    var a: Vector3 = global_position
    var b: Vector3 = last_collision

    var horizontal_distance = Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))

    var is_below = a.y < b.y
    return is_below and horizontal_distance <= underneath_radius
