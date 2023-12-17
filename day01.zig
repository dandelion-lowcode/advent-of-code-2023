const std = @import("std");
const input = @embedFile("inputs/day01.txt");

const expect = std.testing.expect;

pub fn main() !void {
    const p1 = part1(input);
    const p2 = part2();

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

fn part1(inputStr: []const u8) i64 {
    var lines = std.mem.tokenizeScalar(u8, inputStr, '\n');

    var res: i64 = 0;
    while (lines.next()) |line| {
        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                const numericValue = c - '0';
                if (first_digit == null) {
                    first_digit = numericValue;
                }
                last_digit = numericValue;
            }
        }

        const total_number = first_digit.? * 10 + last_digit.?;
        res += total_number;
    }
    return res;
}

pub fn part2() i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const cloned_str = allocator.dupe(u8, input) catch unreachable;

    const Replacement = struct {
        needle: []const u8,
        replacement: []const u8,
    };

    const replacements = [_]Replacement{
        .{ .needle = "one", .replacement = "o1e" },
        .{ .needle = "two", .replacement = "t2o" },
        .{ .needle = "three", .replacement = "th3ee" },
        .{ .needle = "four", .replacement = "f4ur" },
        .{ .needle = "five", .replacement = "f5ve" },
        .{ .needle = "six", .replacement = "s6x" },
        .{ .needle = "seven", .replacement = "se7en" },
        .{ .needle = "eight", .replacement = "ei8ht" },
        .{ .needle = "nine", .replacement = "n9ne" },
    };

    for (replacements) |r| {
        _ = std.mem.replace(u8, cloned_str, r.needle, r.replacement, cloned_str);
    }

    return part1(cloned_str);
}

test "Part 1" {
    try expect(part1(input) == 55712);
}

test "Part 2" {
    try expect(part2() == 55413);
}
