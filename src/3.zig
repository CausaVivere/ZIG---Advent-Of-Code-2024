const std = @import("std");
const print = std.debug.print;

pub fn SolutionPartOne() !void {
    var file = try std.fs.cwd().openFile("src/inputs/day3_parts.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var linesRaw = try allocator.alloc([]u8, 1024);
    defer allocator.free(linesRaw);

    var iter: usize = 0;
    var sum: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        linesRaw[iter] = try std.mem.Allocator.dupe(allocator, u8, line);

        iter += 1;
    }

    var lines = try allocator.alloc([]u8, iter);
    defer allocator.free(lines);

    for (0..lines.len) |i| {
        lines[i] = try std.mem.Allocator.dupe(allocator, u8, linesRaw[i]);
    }

    for (0.., lines) |x, line| {
        var i: usize = 0;
        while (i < line.len) {
            var num: u16 = 0;
            if (std.ascii.isDigit(line[i])) {
                num = line[i] - '0';
                var offset: usize = 0;
                if (i + 1 < line.len) {
                    if (std.ascii.isDigit(line[i + 1])) {
                        for (i + 1..line.len) |j| {
                            if (std.ascii.isDigit(line[j])) {
                                num = num * 10 + (line[j] - '0');
                                continue;
                            } else {
                                offset = j - i;
                                break;
                            }
                        }
                    } else offset = 1;
                }

                var loopOffset: usize = 0;
                if (i > 0) loopOffset += 1;

                for (i - loopOffset..i + offset + 1) |y| {
                    if (x > 0) {
                        if (!std.ascii.isAlphanumeric(lines[x - 1][y]) and lines[x - 1][y] != '.') {
                            sum += num;
                            break;
                        }
                    }
                    if (!std.ascii.isAlphanumeric(lines[x][y]) and lines[x][y] != '.') {
                        sum += num;
                        break;
                    }

                    if (x + 1 < lines.len) {
                        if (!std.ascii.isAlphanumeric(lines[x + 1][y]) and lines[x + 1][y] != '.') {
                            sum += num;
                            break;
                        }
                    }
                }

                i += offset;
            }
            i += 1;
        }
    }

    print("Day Three Part One Result: {d}\n", .{sum});
}

pub fn SolutionPartTwo() !void {
    var file = try std.fs.cwd().openFile("src/inputs/day3_parts.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var iter: usize = 0;
    var linesRaw = try allocator.alloc([]u8, 1024);
    defer allocator.free(linesRaw);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        linesRaw[iter] = try std.mem.Allocator.dupe(allocator, u8, line);
        iter += 1;
    }

    var lines = try allocator.alloc([]u8, iter);
    defer allocator.free(lines);

    for (0..lines.len) |i| {
        lines[i] = try std.mem.Allocator.dupe(allocator, u8, linesRaw[i]);
    }

    var sum: u32 = 0;

    for (0.., lines) |x, line| {
        var y: usize = 0;
        while (y < line.len) {
            if (line[y] == '*') {
                var nums = std.ArrayList(u16).init(allocator);
                var gearRatio: u32 = 0;

                try partTwoCheckLeft(&x, &y, &lines, &nums);
                try partTwoCheckCenter(&x, &y, &lines, &nums);
                try partTwoCheckRight(&x, &y, &lines, &nums);

                if (nums.items.len == 2) {
                    for (nums.items) |num| {
                        if (gearRatio == 0)
                            gearRatio = num
                        else
                            gearRatio = gearRatio * num;
                    }
                }

                sum += gearRatio;
            }

            y += 1;
        }
    }
    print("Day Three Part Two Solution: {d}\n", .{sum});
}

fn partTwoCheckLeft(xPtr: *const usize, yPtr: *const usize, linesPtr: *[][]u8, numsPtr: *std.ArrayList(u16)) !void {
    const x = xPtr.*;
    const y = yPtr.*;
    const lines = linesPtr.*;
    const nums = numsPtr;

    if (x > 0) {
        if (std.ascii.isDigit(lines[x - 1][y - 1]) and !std.ascii.isDigit(lines[x - 1][y])) {
            var num: u16 = lines[x - 1][y - 1] - '0';
            var zeroStarts: u16 = 0;
            if (num == 0) zeroStarts += 1;

            const iy: isize = @intCast(y);
            var index: isize = iy - 2;
            var i: usize = y - 2;
            while (index >= 0) : (index -= 1) {
                i = @intCast(index);
                if (std.ascii.isDigit(lines[x - 1][i])) {
                    num = num * 10 + (lines[x - 1][i] - '0');
                    if (num == 0) zeroStarts += 1;
                } else break;
            }

            if (zeroStarts > 0) {
                num = reverseNumber(num);
                for (0..zeroStarts) |z| {
                    _ = z;
                    num = num * 10;
                }
                _ = try nums.append(num);
            } else _ = try nums.append(reverseNumber(num));
        }
    }

    if (std.ascii.isDigit(lines[x][y - 1])) {
        var num: u16 = lines[x][y - 1] - '0';
        var zeroStarts: u16 = 0;
        if (num == 0) zeroStarts += 1;

        const iy: isize = @intCast(y);
        var index: isize = iy - 2;
        var i: usize = y - 2;
        while (index >= 0) : (index -= 1) {
            i = @intCast(index);
            if (std.ascii.isDigit(lines[x][i])) {
                num = num * 10 + (lines[x][i] - '0');
                if (num == 0) zeroStarts += 1;
            } else break;
        }

        if (zeroStarts > 0) {
            num = reverseNumber(num);
            for (0..zeroStarts) |z| {
                _ = z;
                num = num * 10;
            }
            _ = try nums.append(num);
        } else _ = try nums.append(reverseNumber(num));
    }

    if (x + 1 < lines.len) {
        if (std.ascii.isDigit(lines[x + 1][y - 1]) and !std.ascii.isDigit(lines[x + 1][y])) {
            var num: u16 = lines[x + 1][y - 1] - '0';
            var zeroStarts: u16 = 0;
            if (num == 0) zeroStarts += 1;

            const iy: isize = @intCast(y);
            var index: isize = iy - 2;
            var i: usize = y - 2;
            while (index >= 0) : (index -= 1) {
                i = @intCast(index);
                if (std.ascii.isDigit(lines[x + 1][i])) {
                    num = num * 10 + (lines[x + 1][i] - '0');
                    if (num == 0) zeroStarts += 1;
                } else break;
            }

            if (zeroStarts > 0) {
                num = reverseNumber(num);
                for (0..zeroStarts) |z| {
                    _ = z;
                    num = num * 10;
                }
                _ = try nums.append(num);
            } else _ = try nums.append(reverseNumber(num));
        }
    }
}

fn partTwoCheckRight(xPtr: *const usize, yPtr: *const usize, linesPtr: *[][]u8, numsPtr: *std.ArrayList(u16)) !void {
    const x = xPtr.*;
    const y = yPtr.*;
    const lines = linesPtr.*;
    const nums = numsPtr;

    if (x + 1 < lines.len) {
        if (std.ascii.isDigit(lines[x - 1][y + 1]) and !std.ascii.isDigit(lines[x - 1][y])) {
            var num: u16 = lines[x - 1][y + 1] - '0';
            if (y + 2 < lines[x - 1].len) {
                var i: usize = y + 2;
                while (i != lines[x - 1].len) : (i += 1) {
                    if (std.ascii.isDigit(lines[x - 1][i])) {
                        num = num * 10 + (lines[x - 1][i] - '0');
                    } else break;
                }
            }
            _ = try nums.append(num);
        }
    }

    if (std.ascii.isDigit(lines[x][y + 1])) {
        var num: u16 = lines[x][y + 1] - '0';

        if (y + 2 < lines[x].len) {
            var i: usize = y + 2;
            while (i != lines[x].len) : (i += 1) {
                if (std.ascii.isDigit(lines[x][i])) {
                    num = num * 10 + (lines[x][i] - '0');
                } else break;
            }
        }
        _ = try nums.append(num);
    }

    if (x + 1 < lines.len) {
        if (std.ascii.isDigit(lines[x + 1][y + 1]) and !std.ascii.isDigit(lines[x + 1][y])) {
            var num: u16 = lines[x + 1][y + 1] - '0';

            if (y + 2 < lines[x].len) {
                var i: usize = y + 2;
                while (i != lines[x + 1].len) : (i += 1) {
                    if (std.ascii.isDigit(lines[x + 1][i])) {
                        num = num * 10 + (lines[x + 1][i] - '0');
                    } else break;
                }
            }
            _ = try nums.append(num);
        }
    }
}
fn partTwoCheckCenter(xPtr: *const usize, yPtr: *const usize, linesPtr: *[][]u8, numsPtr: *std.ArrayList(u16)) !void {
    const x = xPtr.*;
    const y = yPtr.*;
    const lines = linesPtr.*;
    const nums = numsPtr;

    if (std.ascii.isDigit(lines[x - 1][y])) {
        var num: u16 = lines[x - 1][y] - '0';
        var zeroStarts: u16 = 0;
        if (num == 0) zeroStarts += 1;
        if (y >= 1) {
            var i: usize = y - 1;
            while (i != 0) : (i -= 1) {
                if (std.ascii.isDigit(lines[x - 1][i])) {
                    num = num * 10 + (lines[x - 1][i] - '0');
                    if (num == 0) zeroStarts += 1;
                } else break;
            }
        }
        if (zeroStarts > 0) {
            num = reverseNumber(num);
            for (0..zeroStarts) |z| {
                _ = z;
                num = num * 10;
            }
        } else num = reverseNumber(num);

        if (y + 1 < lines[x - 1].len) {
            var i: usize = y + 1;
            while (i != lines[x - 1].len) : (i += 1) {
                if (std.ascii.isDigit(lines[x - 1][i])) {
                    num = num * 10 + (lines[x - 1][i] - '0');
                } else break;
            }
        }
        _ = try nums.append(num);
    }

    if (std.ascii.isDigit(lines[x + 1][y])) {
        var num: u16 = lines[x + 1][y] - '0';
        var zeroStarts: u16 = 0;
        if (num == 0) zeroStarts += 1;

        if (y >= 1) {
            var i: usize = y - 1;
            while (i != 0) : (i -= 1) {
                if (std.ascii.isDigit(lines[x + 1][i])) {
                    num = num * 10 + (lines[x + 1][i] - '0');
                    if (num == 0) zeroStarts += 1;
                } else break;
            }
        }
        if (zeroStarts > 0) {
            num = reverseNumber(num);
            for (0..zeroStarts) |z| {
                _ = z;
                num = num * 10;
            }
        } else num = reverseNumber(num);

        if (y + 1 < lines[x + 1].len) {
            var i: usize = y + 1;
            while (i != lines[x + 1].len) : (i += 1) {
                if (std.ascii.isDigit(lines[x + 1][i])) {
                    num = num * 10 + (lines[x + 1][i] - '0');
                } else break;
            }
        }
        _ = try nums.append(num);
    }
}

fn reverseNumber(num: u16) u16 {
    var n: u16 = num;
    var remainder: u16 = 0;
    var result: u16 = 0;

    while (n != 0) {
        remainder = n % 10;
        result = result * 10 + remainder;
        n /= 10;
    }

    return result;
}
