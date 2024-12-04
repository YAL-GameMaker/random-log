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