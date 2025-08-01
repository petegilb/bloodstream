@tool
class_name BloodRiver
extends Path3D

# sourced from https://github.com/CBerry22/Path-Based-Mesh-Generation-YT/blob/master/scenes/Track.gd
# then edited by me
@export var distance_between_mesh = 1.0:
	set(value):
		distance_between_mesh = value
		is_dirty = true

@export var source_room: Room = null
@export var destination_room: Room = null
	
var is_dirty = false
var multimesh_objects: Array[MultiMesh] = []

func _ready():
	if source_room == null:
		printerr("spline is missing its source room!! %s" % [self])
	if destination_room == null:
		printerr("spline is missing its destination room!! %s" % [self])
	for child in get_children():
		if is_instance_of(child, MultiMesh):
			multimesh_objects.append(child)

func _process(_delta):
	if is_dirty:
		_update_multimesh()

		is_dirty = false

func _update_multimesh():
	var path_length: float = curve.get_baked_length()
	var count = floor(path_length / distance_between_mesh)

	# var mm: MultiMesh = $MultiMeshInstance3D.multimesh
	for mm in multimesh_objects:
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
