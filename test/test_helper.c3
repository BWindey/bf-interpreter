module bf_test;
import std::io;
import brainfuck;

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
