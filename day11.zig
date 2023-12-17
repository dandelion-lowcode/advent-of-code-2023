const std = @import("std");
const str = @embedFile("day11.txt");

const Allocator = std.mem.Allocator;
const Line = std.ArrayList(bool);
const Matrix = std.ArrayList(std.ArrayList(bool));
const Pair = struct {
    i: i64,
    j: i64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = readInput(allocator);
    const emptyRows = getEmptyRows(input);
    const emptyCols = getEmptyCols(input);

    const p1 = part1(input, emptyRows, emptyCols, allocator);
    const p2 = part2(input, emptyRows, emptyCols, allocator);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1(input: Matrix, emptyRows: std.ArrayList(i64), emptyCols: std.ArrayList(i64), allocator: Allocator) i64 {
    const increment: i64 = 1;
    const galaxies = getGalaxies(input, emptyRows, emptyCols, increment, allocator);
    return getMinDistance(galaxies);
}

pub fn part2(input: Matrix, emptyRows: std.ArrayList(i64), emptyCols: std.ArrayList(i64), allocator: Allocator) i64 {
    const increment: i64 = 1_000_000 - 1;
    const galaxies = getGalaxies(input, emptyRows, emptyCols, increment, allocator);
    return getMinDistance(galaxies);
}

pub fn getGalaxies(input: Matrix, emptyRows: std.ArrayList(i64), emptyCols: std.ArrayList(i64), increment: i64, allocator: Allocator) std.ArrayList(Pair) {
    var res = std.ArrayList(Pair).init(allocator);
    const N = input.items.len;
    const M = input.items[0].items.len;
    for (0..N) |i| {
        for (0..M) |j| {
            if (input.items[i].items[j]) {
                var I: i64 = @as(i64, @intCast(i));
                var J: i64 = @as(i64, @intCast(j));
                for (emptyRows.items) |er| {
                    if (er < i) {
                        I += increment;
                    }
                }
                for (emptyCols.items) |ec| {
                    if (ec < j) {
                        J += increment;
                    }
                }

                res.append(.{ .i = I, .j = J }) catch unreachable;
            }
        }
    }
    return res;
}

// Applies manhattan distance to compute
// the distance between coordinates
pub fn getMinDistance(galaxies: std.ArrayList(Pair)) i64 {
    const N = galaxies.items.len;
    var minDistance: i64 = 0;
    for (0..N - 1) |i| {
        const g1 = galaxies.items[i];
        for (i..N - 1) |j| {
            const g2 = galaxies.items[j + 1];
            const distance = @abs(g1.i - g2.i) + @abs(g1.j - g2.j);
            minDistance += @as(i64, @intCast(distance));
        }
    }
    return minDistance;
}

pub fn readInput(allocator: Allocator) Matrix {
    var res = Matrix.init(allocator);
    var lineIterator = std.mem.tokenizeAny(u8, str, "\n");
    while (lineIterator.next()) |lineStr| {
        var line = Line.init(allocator);
        for (lineStr) |c| {
            line.append(c == '#') catch unreachable;
        }
        res.append(line) catch unreachable;
    }
    return res;
}

pub fn getEmptyRows(input: Matrix) std.ArrayList(i64) {
    var res = std.ArrayList(i64).init(input.allocator);
    for (input.items, 0..) |line, i| {
        const allEmpty = std.mem.allEqual(bool, line.items, false);
        if (allEmpty) {
            res.append(@as(i64, @intCast(i))) catch unreachable;
        }
    }
    return res;
}

pub fn getEmptyCols(input: Matrix) std.ArrayList(i64) {
    const N = input.items.len;
    const M = input.items[0].items.len;
    var res = std.ArrayList(i64).init(input.allocator);

    for (0..M) |j| {
        var isEmpty = true;
        for (0..N) |i| {
            if (input.items[i].items[j]) {
                isEmpty = false;
                break;
            }
        }
        if (isEmpty) {
            res.append(@as(i64, @intCast(j))) catch unreachable;
        }
    }
    return res;
}

test "Part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = readInput(allocator);
    const emptyRows = getEmptyRows(input);
    const emptyCols = getEmptyCols(input);
    const p1 = part1(input, emptyRows, emptyCols, allocator);
    try std.testing.expect(p1 == 9556712);
}

test "Part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = readInput(allocator);
    const emptyRows = getEmptyRows(input);
    const emptyCols = getEmptyCols(input);
    const p2 = part2(input, emptyRows, emptyCols, allocator);
    try std.testing.expect(p2 == 678626199476);
}
