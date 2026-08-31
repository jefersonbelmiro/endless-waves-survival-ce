extends Node
class_name RoomTreacherousTombsBase

signal door_entered(door_node, room)

var gateway: Node2D
var doors = []

onready var bounds: TileMap = $tile_bounds
onready var ground: TileMap = $tile_ground
onready var bg: ColorRect = $bg

