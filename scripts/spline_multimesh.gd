@tool
extends Path3D

# sourced from https://github.com/CBerry22/Path-Based-Mesh-Generation-YT/blob/master/scenes/Track.gd
# then edited by me
@export var distance_between_mesh = 1.0:
	set(value):
		distance_between_mesh = value
		is_dirty = true
	
var is_dirty = false

func _ready():
	pass

func _process(_delta):
	if is_dirty:
		_update_multimesh()

		is_dirty = false

func _update_multimesh():
	var path_length: float = curve.get_baked_length()
	var count = floor(path_length / distance_between_mesh)

	var mm: MultiMesh = $MultiMeshInstance3D.multimesh
	mm.instance_count = count
	var offset = distance_between_mesh/2.0

	for i in range(0, count):
		var curve_distance = offset + distance_between_mesh * i
		var mesh_position = curve.sample_baked(curve_distance, true)

		var mesh_basis = Basis()
		
		var up = curve.sample_baked_up_vector(curve_distance, true)
		var forward = mesh_position.direction_to(curve.sample_baked(curve_distance + 0.1, true))

		mesh_basis.y = up
		mesh_basis.x = forward.cross(up).normalized()
		mesh_basis.z = -forward
		
		var mesh_transform = Transform3D(mesh_basis, mesh_position)
		mm.set_instance_transform(i, mesh_transform)


func _on_curve_changed():
	is_dirty = true
