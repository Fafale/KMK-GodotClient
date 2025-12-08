extends Node

@onready var main_preload = preload("res://main_scene.tscn")

@onready var main = $Main

func reset_main():
	main.queue_free()
	
	main = main_preload.instantiate()
	add_child(main)
	
	
