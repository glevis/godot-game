extends Panel;

const ItemClass = preload("res://GUI/Inventory/New Inv/Item.gd");
const ItemSlotClass = preload("res://GUI/Inventory/New Inv/ItemSlot.gd");
const TooltipClass = preload("res://GUI/Inventory/New Inv/Tooltip.gd");
const weaponScene = preload("res://Items/Weapons/BasicSword.tscn"); 
#>>>>>>> combat
const MAX_SLOTS = 45;

const itemImages = [
	preload("res://GUI/Inventory/New Inv/images/Ac_Ring05.png"),
	preload("res://GUI/Inventory/New Inv/images/A_Armor05.png"),
	preload("res://GUI/Inventory/New Inv/images/A_Armour02.png"),
	preload("res://GUI/Inventory/New Inv/images/A_Shoes03.png"),
	preload("res://GUI/Inventory/New Inv/images/C_Elm03.png"),
	preload("res://GUI/Inventory/New Inv/images/E_Wood02.png"),
	preload("res://GUI/Inventory/New Inv/images/P_Red02.png"),
	preload("res://GUI/Inventory/New Inv/images/W_Sword001.png"),
	preload("res://GUI/Inventory/New Inv/images/Ac_Necklace03.png"),
];

#<<<<<<< HEAD
#const itemDictionary = {
#=======
var weapon = weaponScene.instance()

var itemDictionary = {
#>>>>>>> combat
	0: {
		"itemName": "Ring",
		"itemValue": 456,
		"itemIcon": itemImages[0],
		"slotType": Global.SlotType.SLOT_RING
	},
	1: {
		"itemName": "Sword",
		"itemValue": 832,
		"itemIcon": itemImages[7],
		"slotType": Global.SlotType.SLOT_LHAND
	},
	2: {
		"itemName": "Armor",
		"itemValue": 623,
		"itemIcon": itemImages[2],
		"slotType": Global.SlotType.SLOT_ARMOR
	},
	3: {
		"itemName": "Helmet",
		"itemValue": 12,
		"itemIcon": itemImages[4],
		"slotType": Global.SlotType.SLOT_HELMET
	},
	4: {
		"itemName": "Boots",
		"itemValue": 654,
		"itemIcon": itemImages[3],
		"slotType": Global.SlotType.SLOT_FEET
	},
	5: {
		"itemName": "Shield",
		"itemValue": 23,
		"itemIcon": itemImages[5],
		"slotType": Global.SlotType.SLOT_RHAND
	},
	6: {
		"itemName": "Necklace",
		"itemValue": 756,
		"itemIcon": itemImages[8],
		"slotType": Global.SlotType.SLOT_NECK
#<<<<<<< HEAD
	}
#=======
	}#,
#	7: {
#		"itemName": weapon.stats.item_name,
#		"itemValue": weapon.stats.price,
#		"itemIcon": itemImages[7],
#		"slotType": Global.SlotType.SLOT_RHAND
#	}
#>>>>>>> combat
#};

var slotList = Array();

var holdingItem = null;
var itemOffset = Vector2(0, 0);

onready var tooltip = get_node("../Tooltip");
onready var characterPanel = get_node("../CharacterPanel");

func _ready():
	var slots = get_node("SlotsContainer/Slots");
	for _i in range(MAX_SLOTS):
		var slot = ItemSlotClass.new();
		slot.connect("mouse_entered", self, "mouse_enter_slot", [slot]);
		slot.connect("mouse_exited", self, "mouse_exit_slot", [slot]);
		slot.connect("gui_input", self, "slot_gui_input", [slot]);
		slotList.append(slot);
		slots.add_child(slot);
#<<<<<<< HEAD
#=======
	weapon._init("weaponName", 6, 9, 4, 2, 0, null, 6, 8, 69420)
	itemDictionary[7] = {
		"itemName": weapon.stats.item_name,
		"itemValue": weapon.stats.price,
		"itemIcon": itemImages[7],
		"slotType": Global.SlotType.SLOT_RHAND
	}
#>>>>>>> combat

	for i in range(10):
		if i == 0:
			continue;
		var panelSlot = characterPanel.slots[i];
		if panelSlot:
			panelSlot.connect("mouse_entered", self, "mouse_enter_slot", [panelSlot]);
			panelSlot.connect("mouse_exited", self, "mouse_exit_slot", [panelSlot]);
			panelSlot.connect("gui_input", self, "slot_gui_input", [panelSlot]);

func mouse_enter_slot(_slot : ItemSlotClass):
	if _slot.item:
		tooltip.display(_slot.item, get_global_mouse_position());

func mouse_exit_slot(_slot : ItemSlotClass):
	if tooltip.visible:
		tooltip.hide();

func slot_gui_input(event : InputEvent, slot : ItemSlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if holdingItem:
				if slot.slotType != Global.SlotType.SLOT_DEFAULT:
					if canEquip(holdingItem, slot):
						if !slot.item:
							slot.equipItem(holdingItem, false);
							slot.item.isEquipped = true
							holdingItem = null;
						else:
							var tempItem = slot.item;
							slot.pickItem();
							tempItem.rect_global_position = event.global_position - itemOffset;
							slot.equipItem(holdingItem, false);
							holdingItem = tempItem;
							holdingItem.item.isEquipped = false
				elif slot.item:
					
					var tempItem = slot.item;
					slot.pickItem();
					tempItem.rect_global_position = event.global_position - itemOffset;
					slot.putItem(holdingItem);
					slot.item.isEquipped = true
					holdingItem = tempItem;
				else:		
					slot.equipItem(holdingItem, false);
					slot.item.isEquipped = false
					holdingItem = null;
			elif slot.item:
				holdingItem = slot.item;
				itemOffset = event.global_position - holdingItem.rect_global_position;
				slot.pickItem();
				holdingItem.rect_global_position = event.global_position - itemOffset;		
		elif event.button_index == BUTTON_RIGHT && !event.pressed:
			if slot.slotType != Global.SlotType.SLOT_DEFAULT:
				if slot.item:
					var freeSlot = getFreeSlot();
					if freeSlot:
						var item = slot.item;
						slot.removeItem();
						freeSlot.setItem(item);
			else:
				if slot.item:
					var itemSlotType = slot.item.slotType;
					var panelSlot = characterPanel.getSlotByType(slot.item.slotType);
					
					if slot.item.isEquipped == false:
						if itemSlotType == Global.SlotType.SLOT_RING:
							if panelSlot[0].item && panelSlot[1].item:
								var panelItem = panelSlot[0].item;
								panelSlot[0].removeItem();
								var slotItem = slot.item;
								slot.removeItem();
								slot.setItem(panelItem);
								panelSlot[0].setItem(slotItem);
								slot.item.isEquipped = false
								panelSlot[0].item.isEquipped = true
								pass
							elif !panelSlot[0].item && panelSlot[1].item || !panelSlot[0].item && !panelSlot[1].item:
								var tempItem = slot.item;
								slot.removeItem();
								panelSlot[0].equipItem(tempItem);
								panelSlot[0].item.isEquipped = true
							elif panelSlot[0].item && !panelSlot[1].item:
								var tempItem = slot.item;
								slot.removeItem();
								panelSlot[1].equipItem(tempItem);
								panelSlot[1].item.isEquipped = true
								pass
						else:
							if panelSlot.item:
								var panelItem = panelSlot.item;
								panelSlot.removeItem();
								var slotItem = slot.item;
								slot.removeItem();
								slot.setItem(panelItem);
								panelSlot.setItem(slotItem);
								slot.item.isEquipped = false
								panelSlot.item.isEquipped = true
							else:
								var tempItem = slot.item;
								slot.removeItem();
								panelSlot.equipItem(tempItem);
								panelSlot.item.isEquipped = true
					else:
						var freeSlot = getFreeSlot()
						var tempItem = slot.item
						if freeSlot:
							slot.removeItem()
							freeSlot.equipItem(tempItem)
							freeSlot.item.isEquipped = false

func _input(event : InputEvent):
	if holdingItem && holdingItem.picked:
		holdingItem.rect_global_position = get_viewport().get_mouse_position();

func getFreeSlot():
	for slot in slotList:
		if !slot.item:
			return slot;

func canEquip(item, slot):
	var ring = Global.SlotType.SLOT_RING;
	var ring2 = Global.SlotType.SLOT_RING2;
	return item.slotType == slot.slotType || item.slotType == ring && (slot.slotType == ring || slot.slotType == ring2);

func _on_SortRarityButton_pressed():
	var items = Array();
	for slot in slotList:
		if slot.item:
			items.append(slot.item);
			slot.removeItem();
	items.sort_custom(self, "sortItemsByRarity");
	for i in range(items.size()):
		var item = items[i];
		var slot = slotList[i];
		slot.setItem(item);

func sortItemsByRarity(itemA : ItemClass, itemB : ItemClass):
	return itemA.rarity > itemB.rarity;

func _on_AddItemButton_pressed():
	var slot = getFreeSlot();
	if slot:
		var item = itemDictionary[randi() % itemDictionary.size()];
		var itemName = item.itemName;
		var itemIcon = item.itemIcon;
		var itemValue = item.itemValue;
		var slotType = item.slotType;
		slot.setItem(ItemClass.new(itemName, itemIcon, null, itemValue, slotType));

