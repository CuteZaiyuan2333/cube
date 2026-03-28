extends Node3D
var surface         = preload("res://models/surface.tscn")

var positionVectors = [
						[Vector3(0,  -0.5 , 0), Vector3(0, 0, 0), Vector3(0,  0.5 , 0)],
						[Vector3(-0.5,  0,  0  ), Vector3(0, 0, 0), Vector3(0.5  , 0, 0)],
						[Vector3(0,  0  ,  -0.5), Vector3(0, 0, 0), Vector3( 0,  0  , 0.5)], 
						
					]
var rotationVectors = [
						[
						Vector3(deg_to_rad(0  ), deg_to_rad(0  ), deg_to_rad(180  )),
						Vector3(deg_to_rad(0  ), deg_to_rad(0  ), deg_to_rad(0  )),
						Vector3(deg_to_rad(0), deg_to_rad(0  ), deg_to_rad(0  ))
						],
						
						[
						Vector3(deg_to_rad(0 ), deg_to_rad(0  ), deg_to_rad(90  )),
						Vector3(deg_to_rad(0  ), deg_to_rad(0  ), deg_to_rad(0  )),
						Vector3(deg_to_rad(0  ), deg_to_rad(0  ), deg_to_rad(270))
						],
						
						[
						Vector3(deg_to_rad(270), deg_to_rad(0  ), deg_to_rad(0  )),
						Vector3(deg_to_rad(0  ), deg_to_rad(0  ), deg_to_rad(0  )),
						Vector3(deg_to_rad(90  ), deg_to_rad(0  ), deg_to_rad(0 ))
						]
					]

var colorTable = [
	[Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 0.0, 1.0)],
	[Color(0.0, 0.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), Color(0.0, 1.0, 0.0, 1.0)],
	[Color(1.0, 0.304, 0.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 0.0, 0.0, 1.0)]
]

func start_up(index) -> void:
	for i in range(0, 3):
		var instance = surface.instantiate()
		add_child(instance)
		instance.position = positionVectors[i][index[i]]
		instance.rotation = rotationVectors[i][index[i]]
		instance.color    = colorTable     [i][index[i]]
		instance.set_color()
	#if index[0] == 1:
		#for i in range(0, 3):
			#var instance = surface.instantiate()
			#add_child(instance)
			#instance.position = positionVectors[i][index[i]]
			#instance.rotation = rotationVectors[i][index[i]]
			#instance.color    = colorTable     [i][index[i]]
			#instance.set_color()
