module bf_test @test;

fn void test_hello_world() {
	char[] instructions = "++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------.";
	test_helper(instructions, "Hello World");
}

fn void test_printing() {
	char[] instructions = "+++++.>+++.";
	test_helper(instructions, (String) (char[]) { 5, 3 }, binary: true);
}

fn void test_sum() {
	char[] instructions = "+++++>+++<[>>+<<-]>[>+<-]>.";
	test_helper(instructions, (String) (char[]) { 8 }, binary: true);
}
