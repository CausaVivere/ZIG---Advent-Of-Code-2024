const std = @import("std");
const print = std.debug.print;

pub fn Solution() anyerror!void {
    // Read File
    var file = try std.fs.cwd().openFile("src/inputs/day1_calibration.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var sum: u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var firstNumber: u8 = 0;
        var secondNumber: u8 = 0;

        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                if (firstNumber == 0) {
                    firstNumber = char;
                    if (secondNumber == 0) secondNumber = char;
                } else {
                    secondNumber = char;
                }
            }
        }

        const combinedNumber: u16 = (firstNumber - '0') * 10 + (secondNumber - '0');

        sum += combinedNumber;
    }
    print("Day One Result: {d}", .{sum});
    print("\n", .{});
}
