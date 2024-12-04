# random_log

**Quick links:**
[blog post](https://yal.cc/gamemaker-random-log)
· [itch](https://yellowafterlife.itch.io/gamemaker-random-log)  
**Versions:** GameMaker LTS / GM2022+

This is a script that tracks uses of random number generator functions in GameMaker!

So if you do something like this:
```gml
function scr_test() {
	random_log_tag = "T1";
	random_log("hey");
	var a = random(10);
	//
	random_log_tag = "T2";
	var b = choose("A", "B", "C");
	//
	show_debug_message(random_log_print());
}
```
The output would be:
```js
T1	random_log("hey")
	gml_Script_scr_test:3
	gml_Object_obj_test_Create_0:1
T1	random(10) -> 8.0878257285803556
	gml_Script_scr_test:4
	gml_Object_obj_test_Create_0:1
T2	choose("A", "B", "C") -> "B"
	gml_Script_scr_test:7
	gml_Object_obj_test_Create_0:1
```
Check out the blog post for an explanation of how this works!

## API

### random_log_size: int
You can edit this macro to control the maximum number of RNG log entries that can be kept at once.

This only affects memory use.

### random_log_enable: bool
This global variable controls whether logging should be enabled or not.

With logging disabled, RNG functions have minimal overhead.

### random_log_tag: string
This string is attached to each log entry and shows up in front of them when printing.

Typically this is either a frame number or the state that the game's in.

### random_log(...values)
Adds an entry without modifying RNG state.

Good for attaching additional debug information!

### random_log_print()➜string
Pretty-prints the log entries and returns them as a string.

### random_log_print_to_buffer(buffer)
Appends pretty-printed log entries to the given buffer as text.

### random_log_print_to_file(path)
Pretty-prints the log entries to a file.

### random_log_clear()
Clears the log entries!

If you made `random_log_size` a variable, you'll want to call this after changing the log size.

## Limitations
Since we're storing arguments instead of printing them on spot (that'd cost!),
if you are doing a choose() or random_log() on structs/arrays,
upon printing you'll see the current value of struct/array rather than the one
as of the function being called. 