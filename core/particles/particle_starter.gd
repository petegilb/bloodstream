class_name ParticleStarter
extends Node3D

@export var time_before_death = 2.0

func _ready() -> void:
    for child in find_children("*"):
        if child is GPUParticles3D:
            child.emitting = true
    
    await get_tree().create_timer(time_before_death).timeout
    queue_free()
