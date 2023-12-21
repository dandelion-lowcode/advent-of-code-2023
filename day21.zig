const std = @import("std");
const str = @embedFile("inputs/day21.txt");
const N = std.math.sqrt(str.len);

const Input = struct {
    matrix: Matrix,
    initial: struct { usize, usize },
};

const Matrix = [N][N]bool;

pub fn main() void {
    const p1 = part1();
    std.debug.print("Part 1: {d}\n", .{p1});
}

pub fn part1() i64 {
    const input = readInput();
    var actives: Matrix = undefined;

    const i_initial, const j_initial = input.initial;
    actives[i_initial][j_initial] = true;

    const num_iterations = 64;
    for (0..num_iterations) |_| {
        actives = evolve(&input.matrix, &actives);
    }

    const numActives = count_actives(&actives);
    return numActives;
}

fn evolve(matrix: *const Matrix, markeds: *const Matrix) Matrix {
    var res: Matrix = undefined;
    for (markeds, 0..) |row, i| {
        for (row, 0..) |c, j| {
            if (!c) continue;

            const I: i64 = @as(i64, @intCast(i));
            const J: i64 = @as(i64, @intCast(j));

            validate_and_mark(matrix, &res, I - 1, J);
            validate_and_mark(matrix, &res, I + 1, J);
            validate_and_mark(matrix, &res, I, J - 1);
            validate_and_mark(matrix, &res, I, J + 1);
        }
    }
    return res;
}

pub fn validate_and_mark(matrix: *const Matrix, dest: *Matrix, I: i64, J: i64) void {
    if (I < 0 or J < 0 or I >= N or J >= N) {
        return;
    }

    const i = @as(usize, @intCast(I));
    const j = @as(usize, @intCast(J));
    if (!matrix[i][j]) {
        dest[i][j] = true;
    }
}

pub fn count_actives(matrix: *const Matrix) i64 {
    var res: i64 = 0;
    for (matrix) |row| {
        for (row) |c| {
            if (c) res += 1;
        }
    }
    return res;
}

fn readInput() Input {
    var i_initial: ?usize = null;
    var j_initial: ?usize = null;

    var matrix: Matrix = undefined;
    var i: usize = 0;
    var line_splitter = std.mem.tokenizeScalar(u8, str, '\n');
    while (line_splitter.next()) |line| : (i += 1) {
        for (line, 0..) |c, j| {
            if (c == 'S') {
                i_initial = i;
                j_initial = j;
            }
            matrix[i][j] = c == '#';
        }
    }
    return .{
        .matrix = matrix,
        .initial = .{
            i_initial.?,
            j_initial.?,
        },
    };
}
