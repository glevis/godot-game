extends TileMap

class_name Playable

var player = preload("res://Player/Scenes/player.tscn")

var map_w = 80
var map_h = 50
var min_room_size = 8
var min_room_factor = .4

enum Tiles { GROUND, BG, DOOR }

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []

var start_room = null
var end_room = null

func _ready():
	generate()
	player = player.instance()
	add_child(player)
	print(start_room.center.x)
	print(start_room.center.y)
	player.position.x = start_room.center.x * 30
	player.position.y = start_room.center.y * 30
	print(player.position.x)
	print(player.position.y)
func _process(_delta):
	pass


func generate():
	clear()
	fill_bg()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()
	find_start_room()
	find_end_room()


func fill_bg():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(x, y, Tiles.BG)


func start_tree():
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0
	
	tree[leaf_id] = { "x": 1, "y": 1, "w": map_w - 2, "h": map_h - 2}
	leaf_id += 1


func create_leaf(parent_id):
	var x = tree[parent_id].x
	var y = tree[parent_id].y
	var w = tree[parent_id].w
	var h = tree[parent_id].h
	
	tree[parent_id].center = { x = floor(x + w / 2), y = floor(y + h / 2) }
	
	var can_split = false
	
	var split_type = choose(["h", "v"])
	
	if min_room_factor * w < min_room_size:
		split_type = "h"
	elif min_room_factor * h < min_room_size:
		split_type = "v"
	
	var leaf1 = {}
	var leaf2 = {}
	
	if split_type == "v":
		var room_size = min_room_factor * w
		if room_size >= min_room_size:
			var w1 = randi_range(room_size, (w - room_size))
			var w2 = w - w1
			leaf1 = { x = x, y = y, w = w1, h = h, split = 'v'}
			leaf2 = { x = x + w1, y = y, w = w2, h = h, split = 'v'}
			can_split = true
	else:
		var room_size = min_room_factor * h
		if room_size >= min_room_size:
			var h1 = randi_range(room_size, (h - room_size))
			var h2 = h - h1
			leaf1 = { x = x, y = y, w = w, h = h1, split = 'h'}
			leaf2 = { x = x, y = y + h1, w = w, h = h2, split = 'h'}
			can_split = true
	
	if can_split:
		leaf1.parent_id = parent_id
		tree[leaf_id] = leaf1
		tree[parent_id].l = leaf_id
		leaf_id += 1
		
		leaf2.parent_id = parent_id
		tree[leaf_id] = leaf2
		tree[parent_id].r = leaf_id
		leaf_id += 1
		
		leaves.append([tree[parent_id].l, tree[parent_id].r])
		
		create_leaf(tree[parent_id].l)
		create_leaf(tree[parent_id].r)


func create_rooms():
	for leaf_id in tree:
		var leaf = tree[leaf_id]
		if leaf.has("l"): continue
		
		if chance(75):
			var room = {}
			room.id = leaf_id
			room.w = randi_range(min_room_size, leaf.w) - 1
			room.h = randi_range(min_room_size, leaf.h) - 1
			room.x = leaf.x + floor((leaf.w - room.w) / 2) + 1
			room.y = leaf.y + floor((leaf.h - room.h) / 2) + 1
			room.split = leaf.split
			
			room.center = Vector2()
			room.center.x = floor(room.x + room.w / 2)
			room.center.y = floor(room.y + room.h / 2)
			rooms.append(room)
	
	for i in range(rooms.size()):
		var r = rooms[i]
		for x in range(r.x, r.x + r.w):
			for y in range(r.y, r.y + r.h):
				set_cell(x, y, Tiles.GROUND)


func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])


func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var y = min(leaf1.center.y, leaf2.center.y)
	var w = 1
	var h = 1
	
	if leaf1.split == 'h':
		x -= floor(w / 2) + 1
		h = abs(leaf1.center.y - leaf2.center.y)
	else:
		y -= floor(h / 2) + 1
		w = abs(leaf1.center.x - leaf2.center.x)
		
	x = 0 if x < 0 else x
	y = 0 if y < 0 else y
	
	for i in range(x, x + w):
		for j in range(y, y + h):
			if get_cell(i, j) == Tiles.BG:
				set_cell(i, j, Tiles.GROUND)


func clear_deadends():
	var done = false
	
	while !done:
		done = true
		
		for cell in get_used_cells():
			if get_cellv(cell) != Tiles.GROUND: continue
			
			var bg_count = check_nearby(cell.x, cell.y)
			if bg_count == 3:
				set_cellv(cell, Tiles.BG)
				done = false


func find_start_room():
	var min_x = INF
	for room in rooms:
		if room.center.x < min_x:
			start_room = room
			min_x = room.center.x


func find_end_room():
	var max_x = -INF
	for room in rooms:
		if room.center.x > max_x:
			end_room = room
			max_x = room.center.x


func check_nearby(x, y):
	var count = 0
	if get_cell(x, y - 1) == Tiles.BG: count += 1
	if get_cell(x, y + 1) == Tiles.BG: count += 1
	if get_cell(x - 1, y) == Tiles.BG: count += 1
	if get_cell(x + 1, y) == Tiles.BG: count += 1
	return count


func choose(choices):
	randomize()
	
	var rand_index = randi() % choices.size()
	return choices[rand_index]


func randi_range(low, high):
	return floor(rand_range(low, high))


func chance(num):
	randomize()
	
	if randi() % 100 <= num:
		return true
	else:
		return false
