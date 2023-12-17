const std = @import("std");
const str = @embedFile("inputs/day03.txt");
const N = 140;
const Matrix = [N][N]u8;

pub fn main() !void {
    std.debug.print("Part 1: {d}\n", .{part1()});
}

pub fn part1() i32 {
    var m: Matrix = buildMatrix();
    const totalSum = getSum(m);
    cleanNeighbours(&m);
    const cleanSum = getSum(m);
    const res = totalSum - cleanSum;
    return res;
}

pub fn getSum(m: Matrix) i32 {
    var sum: i32 = 0;
    var number: i32 = 0;
    for (m) |row| {
        for (row) |c| {
            if (isNumber(c)) {
                number = number * 10 + getNumber(c);
            } else {
                sum += number;
                number = 0;
            }
        }
        sum += number;
        number = 0;
    }
    return sum;
}

pub fn buildMatrix() Matrix {
    var m: [N][N]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;
    for (str) |c| {
        if (c == '\n') {
            i += 1;
            j = 0;
        } else if (c != '\r') {
            m[i][j] = c;
            j += 1;
        }
    }
    return m;
}

pub fn printMatrix(m: Matrix) void {
    for (m) |row| {
        for (row) |c| {
            std.debug.print("{c}", .{c});
        }
        std.debug.print("\n", .{});
    }
}

const differences = [_][2]i32{
    [2]i32{ 0, 1 },
    [2]i32{ 0, -1 },
    [2]i32{ 1, 0 },
    [2]i32{ -1, 0 },
    [2]i32{ 1, 1 },
    [2]i32{ 1, -1 },
    [2]i32{ -1, 1 },
    [2]i32{ -1, -1 },
};

pub fn cleanNeighbours(m: *Matrix) void {
    for (m, 0..) |row, i| {
        for (row, 0..) |c, j| {
            if (!isAllowedChar(c)) {
                for (differences) |diff| {
                    const I: i32 = @as(i32, @intCast(i)) + diff[0];
                    const J: i32 = @as(i32, @intCast(j)) + diff[1];
                    killCell(m, I, J);
                }
            }
        }
    }
}

pub fn killCell(m: *Matrix, I: i32, J: i32) void {
    if (J >= 0 and I >= 0 and I < N and J < N) {
        const safeI: usize = @as(usize, @intCast(I));
        const safeJ: usize = @as(usize, @intCast(J));

        const c = m[safeI][safeJ];

        if (c == '.') {
            return;
        }

        killCell(m, I, J + 1);
        m[safeI][safeJ] = '.';
        killCell(m, I, J - 1);
    }
}

pub fn isAllowedChar(c: u8) bool {
    const allowedChars = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' };
    for (allowedChars) |ac| {
        if (c == ac) {
            return true;
        }
    }
    return false;
}

pub fn isNumber(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn getNumber(c: u8) i32 {
    return @as(i32, @intCast(c - '0'));
}
