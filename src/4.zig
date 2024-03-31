const std = @import("std");
const print = std.debug.print;

pub fn Solution() !void {
    var file = try std.fs.cwd().openFile("src/inputs/day4_cards.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var sum: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var winningNums = std.ArrayList(u8).init(allocator);
        var ownNums = std.ArrayList(u8).init(allocator);

        // we start from 10 because that's where the numbers start on everyline
        // you could calculate the position where they start here in code but in our case
        // it's pointless.
        var i: usize = 10;
        while (i < line.len) : (i += 1) {
            if (std.ascii.isDigit(line[i])) {
                var num: u8 = line[i] - '0';

                for (i + 1..line.len) |j| {
                    if (std.ascii.isDigit(line[j])) {
                        num = num * 10 + (line[j] - '0');
                    } else {
                        i += j - i;
                        break;
                    }
                }

                _ = try winningNums.append(num);
            } else if (line[i] == '|') break;
        }

        while (i < line.len) : (i += 1) {
            if (std.ascii.isDigit(line[i])) {
                var num: u8 = line[i] - '0';

                for (i + 1..line.len) |j| {
                    if (std.ascii.isDigit(line[j])) {
                        num = num * 10 + (line[j] - '0');
                    } else {
                        i += j - i;
                        break;
                    }
                }

                _ = try ownNums.append(num);
                if (i >= line.len - 2) break;
            }
        }

        var points: u32 = 0;
        for (ownNums.items) |num| {
            for (winningNums.items) |winNum| {
                if (winNum == num) {
                    if (points == 0) points = 1 else points *= 2;
                }
            }
        }

        sum += points;

        ownNums.clearAndFree();
        winningNums.clearAndFree();
    }

    print("Day Four Solution: {d}\n", .{sum});
}
