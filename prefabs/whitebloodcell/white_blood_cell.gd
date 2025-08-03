class_name WhiteBloodCell
extends RigidBody3D

var before_destroy := 1.2
var alive_timer := 0.0

func _process(delta: float) -> void:
    alive_timer += delta
    if alive_timer >= before_destroy:
        queue_free()

func _on_body_entered(body:Node) -> void:
    print("body entered white blood cell %s" % str(body))
    if body is Virus:
        body.kill()
