const std = @import("std");
const print = std.debug.print;

pub fn Solution() !void {
    var file = try std.fs.cwd().openFile("src/inputs/day2_game.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    const redLimit: u8 = 12;
    const greenLimit: u8 = 13;
    const blueLimit: u8 = 14;

    var id: u16 = 0;
    var sum: u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        id += 1;

        var game = std.mem.split(u8, line, ":");
        _ = game.next();
        var sets = std.mem.split(u8, game.next().?, ";");

        var validGame = true;
        while (sets.next()) |set| {
            var cubes = std.mem.split(u8, set, ",");

            while (cubes.next()) |color| {
                var count: u16 = 0;
                var cube: u8 = undefined;
                for (color) |char| {
                    if (std.ascii.isDigit(char)) {
                        count = count * 10 + (char - '0');
                    } else if (std.ascii.isAlphabetic(char)) {
                        cube = char;
                        break;
                    }
                }
                if (cube == 'r') {
                    if (count > redLimit) {
                        validGame = false;
                        break;
                    }
                } else if (cube == 'g') {
                    if (count > greenLimit) {
                        validGame = false;
                        break;
                    }
                } else if (cube == 'b') {
                    if (count > blueLimit) {
                        validGame = false;
                        break;
                    }
                }
            }
        }
        if (validGame) sum += id;
    }
    print("Day Two Result: {d}\n", .{sum});
}
