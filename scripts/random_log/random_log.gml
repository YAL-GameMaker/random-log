// https://yal.cc/gamemaker-random-log

#macro random_log_size 8192
globalvar random_log_tag; random_log_tag = "?";
globalvar random_log_enable; random_log_enable = true;

function random_log_clear() {
	global.__random_log_lines = array_create(random_log_size, 0);
	global.__random_log_index = 0;
}
random_log_clear();

#macro random_log_mf \
	if (random_log_enable) for (var _fname; ; { \
		var _args = array_create(argument_count); \
		for (var _argi = 0; _argi < argument_count; _argi++) { \
			_args[_argi] = argument[_argi]; \
		} \
		global.__random_log_lines[global.__random_log_index] = [random_log_tag, _fname, _args, _result, debug_get_callstack()]; \
		global.__random_log_index = (global.__random_log_index + 1) % random_log_size; \
		break; \
	}) _fname = // ->

/// @param ...args
function random_log() {
	var _result = undefined;
	random_log_mf("random_log");
}

#macro random random_hook
#macro random_base random
function random_hook(_max) {
	var _result = random_base(_max);
	random_log_mf("random");
	return _result;
}

#macro random_range random_range_hook
#macro random_range_base random_range
function random_range_hook(_min, _max) {
	var _result = random_range_base(_min, _max);
	random_log_mf("random_range");
	return _result;
}

#macro irandom irandom_hook
#macro irandom_base irandom
function irandom_hook(_max_incl) {
	var _result = irandom_base(_max_incl);
	random_log_mf("irandom");
	return _result;
}

#macro irandom_range irandom_range_hook
#macro irandom_range_base irandom_range
function irandom_range_hook(_min_incl, _max_incl) {
	var _result = irandom_range_base(_min_incl, _max_incl);
	random_log_mf("irandom_range");
	return _result;
}

#macro randomize randomize_hook
#macro randomize_base randomize
function randomize_hook() {
	var _result = randomize_base();
	random_log_mf("randomize");
	return _result;
}

#macro randomise randomise_hook
#macro randomise_base randomise
function randomise_hook() {
	var _result = randomise_base();
	random_log_mf("randomise");
	return _result;
}

#macro random_set_seed random_set_seed_hook
#macro random_set_seed_base random_set_seed
function random_set_seed_hook(_seed) {
	var _result = random_set_seed_base(_seed);
	random_log_mf("random_set_seed");
	return _result;
}

#macro choose choose_hook
#macro choose_base choose
/// @param ...values
function choose_hook() {
	var _result = argument_count > 0 ? argument[irandom_base(argument_count - 1)] : 0;
	random_log_mf("choose");
	return _result;
}

#macro part_particles_create part_particles_create_hook
#macro part_particles_create_base part_particles_create
function part_particles_create_hook(_ps, _x, _y, _type, _count) {
	var _result = part_particles_create_base(_ps, _x, _y, _type, _count);
	random_log_mf("part_particles_create");
	return _result;
}

#macro part_emitter_burst part_emitter_burst_hook
#macro part_emitter_burst_base part_emitter_burst
function part_emitter_burst_hook(_ps, _ind, _pt, _number) {
	var _result = part_emitter_burst_base(_ps, _ind, _pt, _number);
	random_log_mf("part_emitter_burst");
	return _result;
}

#macro effect_create_below effect_create_below_hook
#macro effect_create_below_base effect_create_below
function effect_create_below_hook(_kind, _x, _y, _size, _color) {
	var _result = effect_create_below_base(_kind, _x, _y, _size, _color);
	random_log_mf("effect_create_below");
	return _result;
}

#macro effect_create_above effect_create_above_hook
#macro effect_create_above_base effect_create_above
function effect_create_above_hook(_kind, _x, _y, _size, _color) {
	var _result = effect_create_above_base(_kind, _x, _y, _size, _color);
	random_log_mf("effect_create_above");
	return _result;
}

#macro effect_create_layer effect_create_layer_hook
#macro effect_create_layer_base effect_create_layer
function effect_create_layer_hook(_layer, _kind, _x, _y, _size, _color) {
	var _result = effect_create_layer_base(_layer, _kind, _x, _y, _size, _color);
	random_log_mf("effect_create_layer");
	return _result;
}

#macro effect_create_depth effect_create_depth_hook
#macro effect_create_depth_base effect_create_depth
function effect_create_depth_hook(_depth, _kind, _x, _y, _size, _color) {
	var _result = effect_create_depth_base(_depth, _kind, _x, _y, _size, _color);
	random_log_mf("effect_create_depth");
	return _result;
}

global.__random_log_buffer = buffer_create(1024, buffer_grow, 1);
function random_log_print() {
	var _buf = global.__random_log_buffer;
	buffer_seek(_buf, buffer_seek_start, 0);
	random_log_print_to_buffer(_buf);
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_string);
}
function random_log_print_to_file(_path) {
	var _buf = global.__random_log_buffer;
	buffer_seek(_buf, buffer_seek_start, 0);
	random_log_print_to_buffer(_buf);
	buffer_save_ext(_buf, _path, 0, buffer_tell(_buf));
}
function random_log_print_to_buffer(_buf) {
	var _lines = global.__random_log_lines;
	var _line_ind = global.__random_log_index;
	var _max_depth = 4;
	repeat (random_log_size) {
		_line_ind = (_line_ind + 1) % random_log_size;
		var _line = _lines[_line_ind];
		if (!is_array(_line)) continue;
		buffer_write(_buf, buffer_text, _line[0]); // tag
		buffer_write(_buf, buffer_u8, ord("\t"));
		buffer_write(_buf, buffer_text, _line[1]); // function
		buffer_write(_buf, buffer_u8, ord("("));
		var _args = _line[2];
		for (var i = 0, n = array_length(_args); i < n; i++) {
			if (i > 0) buffer_write(_buf, buffer_text, ", ");
			random_log_print_rec(_buf, _args[i], _max_depth);
		}
		buffer_write(_buf, buffer_u8, ord(")"));
		//
		var _result = _line[3];
		if (_result != undefined) {
			buffer_write(_buf, buffer_text, " -> ");
			random_log_print_rec(_buf, _result, _max_depth);
		}
		//
		var _stack = _line[4];
		for (var i = 1, n = array_length(_stack); i < n; i++) {
			var _item = _stack[i];
			if (is_string(_item)) {
				buffer_write(_buf, buffer_text, "\r\n\t");
				buffer_write(_buf, buffer_text, _item);
			}
		}
		//
		buffer_write(_buf, buffer_text, "\r\n");
	}
}

function random_log_print_rec(_out, _value, _depth) {
	if (is_struct(_value)) {
		if (_depth < 0) {
			buffer_write(_out, buffer_text, "{ ... }");
			exit;
		}
		var _keys = variable_instance_get_names(_value);
		if (array_length(_keys) == 0) {
			buffer_write(_out, buffer_text, "{ }");
			exit;
		}
		buffer_write(_out, buffer_text, "{ ");
		for (var i = 0, n = array_length(_keys); i < n; i++) {
			var _key = _keys[i];
			var _sub = variable_instance_get(_value, _key);
			if (i > 0) buffer_write(_out, buffer_text, ", ");
			if (string_lettersdigits(_key) != _key) {
				buffer_write(_out, buffer_text, json_stringify(_key));
			} else buffer_write(_out, buffer_text, _key);
			buffer_write(_out, buffer_text, ": ");
			random_log_print_rec(_out, _sub, _depth - 1);
		}
		buffer_write(_out, buffer_text, " }");
		exit;
	}
	if (is_array(_value)) {
		if (_depth < 0) {
			buffer_write(_out, buffer_text, "[ ... ]");
			exit;
		}
		if (array_length(_value) == 0) {
			buffer_write(_out, buffer_text, "[ ]");
			exit;
		}
		buffer_write(_out, buffer_text, "[ ");
		for (var i = 0, n = array_length(_value); i < n; i++) {
			var _sub = _value[i];
			if (i > 0) buffer_write(_out, buffer_text, ", ");
			random_log_print_rec(_out, _sub, _depth - 1);
		}
		buffer_write(_out, buffer_text, " ]");
		exit;
	}
	if (is_real(_value)) {
		if (sign(frac(_value)) == 0) {
			buffer_write(_out, buffer_text, string(_value));
			exit;
		}
		var _str = string_format(_value, 0, 16);
		var n = string_byte_length(_str);
		var c = 0;
		var i = n;
		for ( ; i > 0; i--) {
			c = string_byte_at(_str, i);
			if (c != ord("0")) break;
		}
		if (c == ord(".")) i -= 1;
		buffer_write(_out, buffer_text, string_copy(_str, 1, i));
		exit;
	}
	/*if (is_bool(_value)) {
		buffer_write(_out, buffer_text, _value ? "true" : "false");
		exit;
	}*/
	if (is_undefined(_value)) {
		buffer_write(_out, buffer_text, "undefined");
		exit;
	}
	if (is_string(_value)) {
		buffer_write(_out, buffer_text, json_stringify(_value));
		exit;
	}
	buffer_write(_out, buffer_text, string(_value));
}