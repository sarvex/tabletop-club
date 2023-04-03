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

class_name CustomValue
extends Resource

## A generic custom value defined by the user.


## Defines the data type of the value.
enum ValueType {
	TYPE_NULL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_MAX,
}


## The data type of the value. Note that setting one of the values will
## automatically change the type depending on which value was set.
export(ValueType) var value_type := ValueType.TYPE_INT setget set_value_type

## The current integer value.
export(int) var value_int := 0 setget set_value_int

## The current float value. Note that you may need to sanitize this value.
export(float) var value_float := 0.0 setget set_value_float

## The current string value. Note that you may need to sanitize this value.
export(String) var value_string := "" setget set_value_string


func set_value_float(value: float) -> void:
	value_type = ValueType.TYPE_FLOAT
	value_float = value


func set_value_int(value: int) -> void:
	value_type = ValueType.TYPE_INT
	value_int = value


func set_value_string(value: String) -> void:
	value_type = ValueType.TYPE_STRING
	value_string = value


func set_value_type(type: int) -> void:
	if type < 0 or type >= ValueType.TYPE_MAX:
		push_error("Invalid value for ValueType")
		return
	
	value_type = type