const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

const str = @embedFile("inputs/day08.txt");

const Targets = struct {
    left: [3]u8,
    right: [3]u8,
};

const Input = struct { allKeys: std.ArrayList([]const u8), directions: std.ArrayList(bool), nodes: std.StringHashMap(Targets) };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try parseInput(allocator);

    const p1 = part1(input);
    const p2 = part2(allocator, input);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

fn part1(input: Input) usize {
    var idx: usize = 0;
    var count: usize = 0;
    var current: [3]u8 = "AAA".*;

    while (!std.mem.eql(u8, &current, "ZZZ")) {
        const direction = input.directions.items[idx];
        const targets = input.nodes.get(&current) orelse unreachable;
        current = if (direction) targets.left else targets.right;
        idx = (idx + 1) % input.directions.items.len;
        count += 1;
    }

    return count;
}

fn part2(allocator: Allocator, input: Input) usize {
    var current = std.ArrayList([]const u8).init(allocator);
    var periods = std.ArrayList(usize).init(allocator);

    for (input.allKeys.items) |key| {
        if (key[2] == 'A') {
            current.append(key) catch unreachable;
            periods.append(0) catch unreachable;
        }
    }

    var idx: usize = 0;
    var steps: usize = 0;
    while (true) {
        const direction = input.directions.items[idx];
        // Advance all the current keys according to the direction
        for (current.items) |*key| {
            const targets = input.nodes.get(key.*) orelse unreachable;
            const next = if (direction) targets.left else targets.right;
            key.* = allocator.dupe(u8, &next) catch unreachable;
        }
        // Advance the index
        idx = (idx + 1) % input.directions.items.len;
        steps += 1;

        // Update periods if a Z is found
        for (current.items, 0..) |key, keyIdx| {
            if (key[2] == 'Z') {
                periods.items[keyIdx] = steps;
            }
        }

        var done = true;
        for (periods.items) |period| {
            if (period == 0) {
                done = false;
                break;
            }
        }

        if (done) {
            break;
        }
    }

    return lcm(periods);
}

fn parseInput(allocator: Allocator) !Input {
    var lineIterator = std.mem.tokenizeSequence(u8, str, "\n");

    // Directions
    const firstLine = lineIterator.next() orelse unreachable;
    var directions = std.ArrayList(bool).init(allocator);
    for (firstLine) |letter| {
        try directions.append(letter == 'L');
    }

    // Nodes
    var allKeys = std.ArrayList([]const u8).init(allocator);
    var nodes = std.StringHashMap(Targets).init(allocator);
    while (lineIterator.next()) |line| {
        // Example: "LHL = (LJF, BDX)"
        const from = line[0..3];
        const left = .{ line[7], line[8], line[9] };
        const right = .{ line[12], line[13], line[14] };
        const targets = Targets{ .left = left, .right = right };

        try nodes.put(from, targets);
        try allKeys.append(from);
    }

    return Input{ .allKeys = allKeys, .directions = directions, .nodes = nodes };
}

fn lcm(periods: std.ArrayList(usize)) usize {
    var result = periods.items[0];
    for (periods.items[1..]) |period| {
        result = lcm_one(result, period);
    }
    return result;
}

fn lcm_one(a: usize, b: usize) usize {
    return (a * b) / gcd(a, b);
}

fn gcd(a: usize, b: usize) usize {
    if (b == 0) {
        return a;
    }
    return gcd(b, a % b);
}

test "Correct result Part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try parseInput(allocator);
    const p1 = part1(input);
    try expect(p1 == 17263);
}

test "Correct result Part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try parseInput(allocator);
    const p2 = part2(allocator, input);
    try expect(p2 == 14631604759649);
}
