const std = @import("std");
const str = @embedFile("inputs/day15.txt");
const ArrayList = std.ArrayList;

const Instruction = struct { tag: []const u8, command: Command };
const Command = union(enum) { focalLength: u8, decrease: void };

const Boxes = [256]Box;
const Box = std.ArrayList(Slot);
const Slot = struct {
    tag: []const u8,
    value: u64,
};

pub fn main() !void {
    const p1 = part1(str);
    const p2 = part2(str);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1(input: []const u8) u64 {
    var comma_iterator = std.mem.tokenizeScalar(u8, input, ',');
    var res: u64 = 0;
    while (comma_iterator.next()) |line| {
        res += getHash(line);
    }
    return res;
}

pub fn part2(input: []const u8) u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Initialize boxes
    var boxes: Boxes = undefined;
    for (&boxes) |*box| {
        box.* = Box.init(allocator);
        defer box.deinit();
    }

    var comma_iterator = std.mem.tokenizeScalar(u8, input, ',');
    while (comma_iterator.next()) |instructionStr| {
        const instruction = getInstruction(instructionStr);
        const tag = instruction.tag;

        const hash = getHash(tag);
        const box = &boxes[hash];
        const matching_slot = slotWithMatchingKeyIndex(box, tag);

        switch (instruction.command) {
            Command.decrease => {
                if (matching_slot) |idx| {
                    _ = box.orderedRemove(idx);
                }
            },
            Command.focalLength => |focalLength| {
                if (matching_slot) |idx| {
                    box.items[idx].value = focalLength;
                } else {
                    const new_slot: Slot = .{ .tag = tag, .value = focalLength };
                    boxes[hash].append(new_slot) catch unreachable;
                }
            },
        }
    }
    return getScore(&boxes);
}

pub fn slotWithMatchingKeyIndex(box: *Box, tag: []const u8) ?usize {
    for (box.items, 0..) |item, idx| {
        const other_tag = item.tag;
        if (std.mem.eql(u8, tag, other_tag)) {
            return idx;
        }
    }
    return null;
}

pub fn getScore(boxes: *Boxes) u64 {
    var res: u64 = 0;
    for (boxes, 0..) |box, boxIdx| {
        for (box.items, 0..) |slot, slotIdx| {
            res += (boxIdx + 1) * (slotIdx + 1) * slot.value;
        }
    }
    return res;
}

pub fn getInstruction(line: []const u8) Instruction {
    const contains_equal_sign = std.mem.indexOfPosLinear(u8, line, 0, "=");
    if (contains_equal_sign) |_| {
        return getFocalLengthInstruction(line);
    }
    return getDecreaseInstruction(line);
}

pub fn getFocalLengthInstruction(line: []const u8) Instruction {
    var equal_iterator = std.mem.split(u8, line, "=");
    const key = equal_iterator.next() orelse unreachable;
    const valueString = equal_iterator.next() orelse unreachable;
    const value = std.fmt.parseInt(u8, valueString, 10) catch unreachable;

    return Instruction{ .tag = key, .command = .{ .focalLength = value } };
}

pub fn getDecreaseInstruction(line: []const u8) Instruction {
    const key = line[0 .. line.len - 1];
    return Instruction{ .tag = key, .command = Command.decrease };
}

pub fn getHash(s: []const u8) u8 {
    var res: u64 = 0;
    for (s) |c| {
        res += c;
        res *= 17;
        res %= 256;
    }
    return @as(u8, @intCast(res));
}

test {
    const testing_input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
    try std.testing.expect(part1(testing_input) == 1320);
    try std.testing.expect(part2(testing_input) == 145);
}

test {
    try std.testing.expect(part1(str) == 511498);
    try std.testing.expect(part2(str) == 284674);
}

test {
    try std.testing.expect(getHash("rn") == 0);
    try std.testing.expect(getHash("qp") == 1);
    try std.testing.expect(getHash("pc") == 3);
    try std.testing.expect(getHash("ot") == 3);
    try std.testing.expect(getHash("ab") == 3);
}
