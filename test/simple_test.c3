import brainfuck;
import std::io;

macro test_helper(char[] instructions, String expected, bool binary = false) => @pool() {
	ByteWriter buffer;
	buffer.tinit();

	brainfuck::interpret(instructions, stdout: &buffer)!!;

	if (binary) {
		assert(
			buffer.str_view() == expected,
			"\n Expected '%s'\n"
			" Received '%s'\n", (char[]) expected, (char[]) buffer.str_view()
		);
	} else {
		assert(
			buffer.str_view() == expected,
			"\n Expected '%s'\n"
			" Received '%s'\n", expected, buffer.str_view()
		);
	}
}

fn void test_hello_world() @test {
	char[] instructions = "++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------.";
	test_helper(instructions, "Hello World");
}

fn void test_printing() @test {
	char[] instructions = "+++++.>+++.";
	test_helper(instructions, (String) (char[]) { 5, 3 }, binary: true);
}

fn void test_sum() @test {
	char[] instructions = "+++++>+++<[>>+<<-]>[>+<-]>.";
	test_helper(instructions, (String) (char[]) { 8 }, binary: true);
}
