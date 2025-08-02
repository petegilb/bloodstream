class_name BoatProbe

extends Node3D

@export var underneath_radius := 8

var in_water = false
var water_height = -100
var last_collision = Vector3(0, water_height, 0)
var collision_object = null

@onready var up_water_cast = $UpWaterCast
@onready var water_cast = $WaterCast

func _physics_process(_delta: float) -> void:
    # force up water cast to point up:
    var up = Vector3.UP
    var forward = -up_water_cast.global_transform.basis.z.normalized() # Keep the same forward direction
    var new_basis = Basis.looking_at(forward, up)
    up_water_cast.global_transform.basis = new_basis

    # water_height = 0
    in_water = water_cast.is_colliding() || up_water_cast.is_colliding() # || check_underneath()
    if in_water:
        # last_collision = $WaterCast.get_collision_point()
        # water_height = last_collision.y
        if up_water_cast.is_colliding():
            # print('upward collision %s' % [self])
            last_collision = up_water_cast.get_collision_point()
            water_height = last_collision.y
            var possible_collision = water_cast.get_collider()
            if possible_collision != null:
                collision_object = possible_collision
        elif water_cast.is_colliding():
            # print('downward collision %s' % [self])
            last_collision = water_cast.get_collision_point()
            water_height = last_collision.y
            var possible_collision = water_cast.get_collider()
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
