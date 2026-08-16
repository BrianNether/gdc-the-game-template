extends Resource
class_name MicroGameInfo

@export_group("Microgame Info")

@export var title: String
@export var authors: String
@export_multiline var description: String

@export var thumbnail : Texture2D

@export var game_scene : PackedScene

@export_group("Rendering")
@export var width : int = -1
@export var height : int = -1


@export_group("Advanced")
@export var custom_credit_display : PackedScene
@export var custom_credit_settings : Resource
