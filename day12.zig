const std = @import("std");
const expect = std.testing.expect;
const str = @embedFile("inputs/day12.txt");

pub fn main() !void {
    const p1 = part1();
    std.debug.print("Part 1 = {d}\n", .{p1});
}

fn part1() i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var total: i64 = 0;
    total += 0;
    var lineSplitter = std.mem.tokenizeScalar(u8, str, '\n');
    while (lineSplitter.next()) |line| {
        var spaceSplitter = std.mem.tokenizeScalar(u8, line, ' ');
        const springs = spaceSplitter.next() orelse "";
        const groupString = spaceSplitter.next() orelse "";

        var groupsNumeric = std.mem.tokenizeScalar(u8, groupString, ',');
        var groups = [_]usize{0} ** 10;
        var i: usize = 0;
        while (groupsNumeric.next()) |group| {
            groups[i] = std.fmt.parseInt(usize, group, 10) catch 0;
            i += 1;
        }

        const variableSprings = allocator.dupe(u8, springs) catch unreachable;
        const variableGroups = allocator.dupe(usize, groups[0..i]) catch unreachable;

        total += countValids(variableSprings, variableGroups);
    }
    return total;
}

fn countValids(springs: []u8, groups: []const usize) i64 {
    return expand(springs, groups, 0);
}

fn expand(springs: []u8, groups: []const usize, i: usize) i64 {
    // Base case
    if (i == springs.len) {
        if (!satisfiesGroups(springs, groups)) return 0;
        //std.debug.print("springs = ", .{});
        //for (springs) |spring| {
        //    std.debug.print("{c}", .{spring});
        //}
        //std.debug.print("\n", .{});
        return 1;
    }

    var validGroups: i64 = 0;

    // Recursive case
    if (springs[i] == '?') {
        // Expand to a '#'
        springs[i] = '#';
        validGroups += expand(springs, groups, i + 1);

        // Expand to a '.'
        springs[i] = '.';
        validGroups += expand(springs, groups, i + 1);

        // Reset the spring
        springs[i] = '?';
    } else {
        // Nothing to expand, move on to the next iteration
        validGroups += expand(springs, groups, i + 1);
    }

    return validGroups;
}

// Checks that groups are correct
// For example: "###..#..#.#" corresponds to 3, 1, 1, 1
// Another example: "####..#..#.#" corresponds to 4, 1, 1, 1
fn satisfiesGroups(s: []const u8, groups: []const usize) bool {
    var groupIdx: usize = 0;
    var hashtagsSeen: usize = 0;
    for (s) |c| {
        if (c == '#') {
            hashtagsSeen += 1;
        } else {
            if (hashtagsSeen != 0) {
                if (groupIdx >= groups.len) {
                    return false;
                }
                if (hashtagsSeen != groups[groupIdx]) {
                    return false;
                }
                groupIdx += 1;
                hashtagsSeen = 0;
            }
        }
    }
    // Check that the last group is correct
    if (hashtagsSeen != 0) {
        if (groupIdx >= groups.len) {
            return false;
        }
        if (hashtagsSeen != groups[groupIdx]) {
            return false;
        }
        groupIdx += 1;
        hashtagsSeen = 0;
    }
    // Check that we've seen all the groups
    if (groupIdx != groups.len) {
        return false;
    }
    return true;
}

test {
    const springs = [_]u8{ '#', '.', '#', '.', '#', '#', '#', '.', '.', '.', '.', '#' };
    const groups = [_]usize{ 1, 1, 3, 1 };
    try expect(satisfiesGroups(&springs, &groups));
}

test {
    const springs = [_]u8{ '#', '.', '#', '.', '.', '#', '.', '.', '.', '#', '#', '#', '.' };
    const groups = [_]usize{ 1, 1, 1, 3 };
    try expect(satisfiesGroups(&springs, &groups));
}

test {
    const springs = [_]u8{ '#', '.', '#', '#', '#', '.', '#', '.', '#', '#', '#', '#', '#', '#' };
    const groups = [_]usize{ 1, 3, 1, 6 };
    try expect(satisfiesGroups(&springs, &groups));
}
