const std = @import("std");
const str = @embedFile("inputs/day01.txt");

pub fn main() !void {
    std.debug.print("Part 1: {d}\n", .{part1(str)});
    std.debug.print("Part 2: {d}\n", .{part2()});
}

fn part1(input: []const u8) i32 {
    var lines = std.mem.tokenize(u8, input, "\n");

    var sum: i32 = 0;
    while (lines.next()) |line| {
        var firstNumber: i32 = -1;
        var lastNumber: i32 = -1;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                if (firstNumber == -1) {
                    firstNumber = c - '0';
                }
                lastNumber = c - '0';
            }
        }

        const totalNumber = firstNumber * 10 + lastNumber;
        sum += totalNumber;
    }
    return sum;
}

const Replacement = struct {
    old: []const u8,
    new: []const u8,
};

pub fn part2() i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const str2 = allocator.dupe(u8, str) catch unreachable;

    const replacements = [_]Replacement{
        .{ .old = "one", .new = "o1e" },
        .{ .old = "two", .new = "t2o" },
        .{ .old = "three", .new = "th3ee" },
        .{ .old = "four", .new = "f4ur" },
        .{ .old = "five", .new = "f5ve" },
        .{ .old = "six", .new = "s6x" },
        .{ .old = "seven", .new = "se7en" },
        .{ .old = "eight", .new = "ei8ht" },
        .{ .old = "nine", .new = "n9ne" },
    };

    for (replacements) |r| {
        _ = std.mem.replace(u8, str2, r.old, r.new, str2);
    }

    return part1(str2);
}
