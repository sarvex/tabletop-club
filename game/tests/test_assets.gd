# tabletop-club
# Copyright (c) 2020-2023 Benjamin 'drwhut' Beddows.
# Copyright (c) 2021-2023 Tabletop Club contributors (see game/CREDITS.tres).
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends GutTest

## Test scripts related to custom assets.


func test_asset_entries() -> void:
	var entry := AssetEntry.new()
	
	# id
	assert_eq(entry.id, "_")
	entry.id = "Test"
	assert_eq(entry.id, "Test")
	entry.id = "   Test   "
	assert_eq(entry.id, "Test")
	entry.id = "Test\n    "
	assert_eq(entry.id, "Test")
	entry.id = "" # Cannot be empty.
	assert_eq(entry.id, "Test")
	entry.id = "    \n\n  " # Cannot be empty.
	assert_eq(entry.id, "Test")
	entry.id = "Test/Subtest" # Must be a valid file name.
	assert_eq(entry.id, "Test")
	entry.id = "Test?" # Must be a valid file name.
	assert_eq(entry.id, "Test")
	entry.id = "Test*" # Must be a valid file name.
	assert_eq(entry.id, "Test")
	
	# name
	assert_eq(entry.name, "Test")
	entry.name = "Test2"
	assert_eq(entry.name, "Test2")
	entry.name = ""
	assert_eq(entry.name, "Test")
	entry.name = "    \n\t  "
	assert_eq(entry.name, "Test")
	entry.name = "/Test/" # Must be a valid file name.
	assert_eq(entry.name, "Test")
	
	# pack, type, get_path
	assert_eq(entry.pack, "TabletopClub")
	assert_eq(entry.type, "")
	assert_eq(entry.get_path(), "")
	
	entry.pack = "PackA"
	assert_eq(entry.pack, "PackA")
	entry.pack = "PackA/SubPack" # No '/' allowed in pack.
	assert_eq(entry.pack, "PackA")
	assert_eq(entry.get_path(), "")
	
	entry.type = "cards"
	assert_eq(entry.get_path(), "PackA/cards/Test")
	entry.type = "dice"
	assert_eq(entry.get_path(), "PackA/dice/Test")
	entry.pack = "PackB"
	assert_eq(entry.get_path(), "PackB/dice/Test")


func test_asset_packs() -> void:
	var pack = AssetPack.new()
	assert_eq(pack.id, "_")
	assert_eq(pack.name, "_")
	
	for property in ["id", "name"]:
		# Similar checks to AssetEntry.
		pack.set(property, "MyPack")
		assert_eq(pack.get(property), "MyPack")
		pack.set(property, "   MyPack   \n   ")
		assert_eq(pack.get(property), "MyPack")
		pack.set(property, "   ")
		assert_eq(pack.get(property), "MyPack")
		pack.set(property, "My/Pack")
		assert_eq(pack.get(property), "MyPack")
	
	assert_eq(pack.origin, "")
	assert_true(pack.is_bundled())
	pack.origin = "res://assets"
	assert_eq(pack.origin, "res://assets")
	assert_false(pack.is_bundled())
	pack.origin = "res://dhhwby" # origin must be an existing directory.
	assert_eq(pack.origin, "res://assets")
	
	var a = AssetEntry.new()
	a.id = "A"
	var b = AssetEntry.new()
	b.id = "B"
	
	assert_true(pack.is_empty())
	pack.add_entry("pieces", a)
	assert_false(pack.is_empty())
	assert_true(pack.has_entry("pieces", "A"))
	assert_eq(pack.get_entry_count(), 1)
	assert_eq(pack.get_entry("pieces", "A"), a)
	
	assert_eq(a.pack, "MyPack")
	assert_eq(a.type, "pieces")
	assert_eq(a.get_path(), "MyPack/pieces/A")
	
	pack.remove_entry("pieces", 0)
	assert_true(pack.is_empty())
	assert_eq(pack.get_entry_count(), 0)
	assert_false(pack.has_entry("pieces", "A"))
	
	pack.add_entry("cards", b)
	assert_eq(pack.get_entry_count(), 1)
	assert_true(pack.has_entry("cards", "B"))
	assert_false(pack.has_entry("pieces", "B"))
	
	assert_eq(b.pack, "MyPack")
	assert_eq(b.type, "cards")
	assert_eq(b.get_path(), "MyPack/cards/B")
	
	assert_eq_deep(pack.get_type("cards"), [b])
	pack.add_entry("cards", a)
	assert_eq_deep(pack.get_type("cards"), [a, b])
	assert_eq_deep(pack.get_all(), {
		"boards": [],
		"cards": [a, b],
		"containers": [],
		"dice": [],
		"games": [],
		"music": [],
		"pieces": [],
		"skyboxes": [],
		"sounds": [],
		"speakers": [],
		"stacks": [],
		"tables": [],
		"templates": [],
		"timers": [],
		"tokens": [],
	})
	
	pack.erase_entry("cards", "A")
	pack.erase_entry("cards", "B")
	assert_true(pack.is_empty())
	assert_false(pack.has_entry("cards", "B"))
	
	var b_temp = AssetEntry.new()
	b_temp.id = "B"
	b_temp.temp = true
	
	var c_temp = AssetEntry.new()
	c_temp.id = "C"
	c_temp.temp = true
	
	pack.add_entry("tables", c_temp)
	pack.add_entry("tables", a)
	pack.add_entry("tables", b)
	assert_eq(pack.get_entry_count(), 3)
	assert_eq_deep(pack.get_type("tables"), [a, b, c_temp])
	assert_eq_deep(pack.get_replaced_entries(), [])
	
	pack.clear_temp_entries()
	assert_eq(pack.get_entry_count(), 2)
	assert_eq_deep(pack.get_type("tables"), [a, b])
	
	pack.add_entry("tables", b_temp)
	assert_eq(pack.get_entry_count(), 2)
	assert_eq_deep(pack.get_type("tables"), [a, b_temp])
	assert_eq_deep(pack.get_replaced_entries(), [b])
	
	pack.clear_temp_entries()
	assert_eq(pack.get_entry_count(), 2)
	assert_eq_deep(pack.get_type("tables"), [a, b])
	assert_eq_deep(pack.get_replaced_entries(), [])
	
	pack.clear_all_entries()
	assert_true(pack.is_empty())
	
	pack.add_entry("?????", a)
	assert_true(pack.is_empty())
	assert_true(pack.get_type("?????").empty())
