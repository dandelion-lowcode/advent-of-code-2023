const std = @import("std");
const str = @embedFile("inputs/day09.txt");
const NUMBERS_PER_LINE = 21;

pub fn main() void {
    const p1, const p2 = findNextAndPrevious(str);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

const Pair = struct { i64, i64 };
pub fn findNextAndPrevious(input: []const u8) Pair {
    var p1: i64 = 0;
    var p2: i64 = 0;

    var line_iterator = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_iterator.next()) |line| {
        var space_iterator = std.mem.tokenizeScalar(u8, line, ' ');
        var numbers: [NUMBERS_PER_LINE]i64 = undefined;
        var numberIdx: usize = 0;
        while (space_iterator.next()) |numStr| : (numberIdx += 1) {
            numbers[numberIdx] = std.fmt.parseInt(i64, numStr, 10) catch unreachable;
        }
        p1 += findNext(&numbers);
        p2 += findPrevious(&numbers);
    }

    return .{ p1, p2 };
}

fn findNext(numbers: []const i64) i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const N = numbers.len;

    // Base case: if the difference between all numbers is constant,
    // return the last number + the difference

    var differences = std.ArrayList(i64).init(allocator);
    for (1..N) |i| {
        differences.append(numbers[i] - numbers[i - 1]) catch unreachable;
    }

    const allOfThemEqual = std.mem.allEqual(i64, differences.items, differences.items[0]);
    if (allOfThemEqual) {
        return numbers[N - 1] + differences.items[0];
    }

    // Otherwise, recurse on the differences
    return numbers[N - 1] + findNext(differences.items);
}

fn findPrevious(numbers: []i64) i64 {
    std.mem.reverse(i64, numbers);
    return findNext(numbers);
}

test "Parts 1 and 2" {
    const p1, const p2 = findNextAndPrevious(str);
    try std.testing.expect(p1 == 1993300041);
    try std.testing.expect(p2 == 1038);
}
