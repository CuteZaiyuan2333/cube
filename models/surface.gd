extends MeshInstance3D

var color = Color(0.735, 0.0, 0.735, 1.0)
var mat: StandardMaterial3D

func set_color() -> void:
	# 1. 从 Mesh 资源中获取原始材质
	var original_mat = mesh.surface_get_material(0)
	
	if original_mat:
		# 2. 创建唯一副本，防止修改这个材质影响到其他使用同个 Mesh 的物体
		mat = original_mat.duplicate()
		# 3. 注意：这里直接调用，不要写 mesh.set_...
		set_surface_override_material(0, mat)
		mat.albedo_color = color
	else:
		printerr("错误：Mesh 资源表面 0 上没有材质！")

#func _process(delta: float) -> void:
	#if mat:
		## 4. 每一帧只需修改已经引用好的材质属性即可
		#mat.albedo_color = color
