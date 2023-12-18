const std = @import("std");
const str = @embedFile("inputs/day18.txt");
const N = 1000;

const Matrix = [N][N]bool;

pub fn main() void {
    const p1 = part1();
    const p2 = part2();
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1() i64 {
    var matrix: Matrix = [_][N]bool{[_]bool{false} ** N} ** N;

    const startIndex = @divExact(N, 2);
    var i: usize = startIndex;
    var j: usize = startIndex;

    var line_splitter = std.mem.tokenizeScalar(u8, str, '\n');
    while (line_splitter.next()) |line| {
        var space_splitter = std.mem.tokenizeScalar(u8, line, ' ');
        const direction = space_splitter.next().?[0];
        const distance: usize = std.fmt.parseInt(usize, space_splitter.next().?, 10) catch unreachable;
        for (0..distance) |_| {
            switch (direction) {
                'U' => i -= 1,
                'D' => i += 1,
                'L' => j -= 1,
                'R' => j += 1,
                else => unreachable,
            }
            matrix[i][j] = true;
        }
    }
    fillRecursively(startIndex + 1, startIndex + 1, &matrix);
    return countActiveCells(&matrix);
}

pub fn part2() i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var i: i64 = 0;
    var j: i64 = 0;
    var trench_perimeter: i64 = 0;

    var X_positions = std.ArrayList(i64).init(allocator);
    var Y_positions = std.ArrayList(i64).init(allocator);

    X_positions.append(i) catch unreachable;
    Y_positions.append(j) catch unreachable;

    var line_splitter = std.mem.tokenizeScalar(u8, str, '\n');
    while (line_splitter.next()) |line| {
        var space_splitter = std.mem.tokenizeScalar(u8, line, ' ');
        _ = space_splitter.next();
        _ = space_splitter.next();
        const fullHexaStr = space_splitter.next().?;
        const hexaStr = fullHexaStr[2..7];
        const directionStr = fullHexaStr[7];
        const distance = std.fmt.parseInt(i64, hexaStr, 16) catch unreachable;
        // 0 means R, 1 means D, 2 means L, and 3 means U.
        switch (directionStr) {
            '0' => j += distance,
            '1' => i += distance,
            '2' => j -= distance,
            '3' => i -= distance,
            else => unreachable,
        }
        trench_perimeter += distance;
        X_positions.append(i) catch unreachable;
        Y_positions.append(j) catch unreachable;
    }

    return getPolygonArea(&X_positions, &Y_positions) + @divExact(trench_perimeter, 2) + 1;
}

fn getPolygonArea(X: *const std.ArrayList(i64), Y: *const std.ArrayList(i64)) i64 {
    const n = X.items.len;

    var area: i64 = 0.0;
    var j = @as(usize, @intCast(@as(i64, @intCast(n)) - 1));
    for (0..n) |i| {
        area += (X.items[j] + X.items[i]) * (Y.items[j] - Y.items[i]);
        j = i;
    }
    return @divExact(area, 2);
}

fn fillRecursively(i: usize, j: usize, matrix: *Matrix) void {
    if (matrix[i][j]) {
        return;
    }
    matrix[i][j] = true;
    fillRecursively(i + 1, j, matrix);
    fillRecursively(i - 1, j, matrix);
    fillRecursively(i, j + 1, matrix);
    fillRecursively(i, j - 1, matrix);
}

fn countActiveCells(matrix: *Matrix) i64 {
    var res: i64 = 0;
    for (0..N) |i| {
        for (0..N) |j| {
            if (matrix[i][j]) {
                res += 1;
            }
        }
    }
    return res;
}

const expectEqual = std.testing.expectEqual;

test "Part 1" {
    const p1 = part1();
    try expectEqual(p1, 31171);
}

test "Part 2" {
    const p2 = part2();
    try expectEqual(p2, 131431655002266);
}
