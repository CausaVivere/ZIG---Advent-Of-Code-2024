const std = @import("std");
const print = std.debug.print;

pub fn SolutionPartOne() !void {
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

        // we start from 8 because that's where the numbers start on every line
        // you could calculate the position where they start here in code but in our case
        // it's pointless.
        var i: usize = 8;
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

    print("Day Four Part One Solution: {d}\n", .{sum});
}

pub fn SolutionPartTwo() !void {
    var file = try std.fs.cwd().openFile("src/inputs/day4_cards.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var sum: u32 = 0;
    var index: usize = 0;

    var linesRaw = try allocator.alloc([]u8, 1024);
    defer allocator.free(linesRaw);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        linesRaw[index] = try std.mem.Allocator.dupe(allocator, u8, line);

        index += 1;
    }

    var lines = try allocator.alloc([]u8, index);
    defer allocator.free(lines);

    for (0..lines.len) |i| {
        lines[i] = try std.mem.Allocator.dupe(allocator, u8, linesRaw[i]);
    }

    var indexCards: usize = 0;
    for (lines) |line| {
        var winningNums = std.ArrayList(u8).init(allocator);
        var ownNums = std.ArrayList(u8).init(allocator);

        // we start from 8 because that's where the numbers start on every line
        // you could calculate the position where they start here in code but in our case
        // it's pointless.
        var i: usize = 8;
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

        var cards: u32 = 0;
        for (ownNums.items) |num| {
            for (winningNums.items) |winNum| {
                if (winNum == num) {
                    cards += 1;
                }
            }
        }

        ownNums.clearAndFree();
        winningNums.clearAndFree();

        if (cards > 0) {
            for (indexCards + 1..indexCards + 1 + cards) |j| {
                cards = cards + AnalyzeCard(lines, j);
            }
        }

        //add the original
        cards += 1;

        sum = sum + cards;

        indexCards += 1;
    }

    print("Day Four Part Two Solution: {d}\n", .{sum});
}

fn AnalyzeCard(lines: [][]u8, index: usize) u32 {
    if (index >= lines.len) return 0;
    var winningNums = std.mem.zeroes([10]u8);
    var ownNums = std.mem.zeroes([25]u8);

    // Check if initialization succeeded
    // we start from 10 because that's where the numbers start on every line
    // you could calculate the position where they start here in code but in our case
    // it's pointless.
    const line = lines[index];
    var i: usize = 8;
    var z: usize = 0;
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

            winningNums[z] = num;
            z += 1;
        } else if (line[i] == '|') break;
    }

    z = 0;
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

            ownNums[z] = num;
            z += 1;
            if (i >= line.len - 2) break;
        }
    }

    var cards: u32 = 0;
    for (0..ownNums.len) |x| {
        if (ownNums[x] != 0) {
            for (0..winningNums.len) |y| {
                if (winningNums[y] == ownNums[x]) {
                    cards += 1;
                }
            }
        }
    }

    if (cards > 0) {
        for (index + 1..index + 1 + cards) |j| {
            cards = cards + AnalyzeCard(lines, j);
        }
        return cards;
    } else return cards;
}
