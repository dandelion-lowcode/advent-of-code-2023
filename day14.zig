const std = @import("std");
const str = @embedFile("inputs/day14.txt");
const N = 100;
const ITERATIONS = 1_000_000_000;

const Line = [N]u8;
const Matrix = [N]Line;

pub fn main() !void {
    const p1 = part1();
    const p2 = part2();

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1() i64 {
    var input = readInput();
    tilt_north(&input);
    return get_score(input);
}

pub fn part2() i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var input = readInput();

    var precise_score_to_iteration = std.AutoHashMap(i64, usize).init(allocator);
    var iteration_to_score = std.AutoHashMap(usize, i64).init(allocator);
    var precise_score_to_score = std.AutoHashMap(i64, i64).init(allocator);

    var i: usize = 0;
    while (true) : (i += 1) {
        cycle(&input);

        const precise_score = get_precise_score(input);

        if (precise_score_to_iteration.get(precise_score)) |prevIteration| {
            const period = i - prevIteration;

            const idx = (ITERATIONS - prevIteration - 1) % period;
            const goodIdx = idx + prevIteration;
            std.debug.print("Index {d}\n", .{goodIdx});
            const goodScore = iteration_to_score.get(goodIdx) orelse unreachable;
            return goodScore;
        }

        const score = get_score(input);
        iteration_to_score.put(i, score) catch unreachable;

        precise_score_to_iteration.put(precise_score, i) catch unreachable;
        precise_score_to_score.put(precise_score, score) catch unreachable;
    }

    unreachable;
}

pub fn readInput() Matrix {
    var res: Matrix = undefined;
    var lineIterator = std.mem.tokenizeScalar(u8, str, '\n');
    var i: usize = 0;
    while (lineIterator.next()) |line| {
        res[i] = line[0..N].*;
        i += 1;
    }
    return res;
}

pub fn cycle(input: *Matrix) void {
    tilt_north(input);
    tilt_west(input);
    tilt_south(input);
    tilt_east(input);
}

pub fn tilt_west(input: *Matrix) void {
    for (input) |*line| {
        line.* = collapse(line);
    }
}

pub fn tilt_east(input: *Matrix) void {
    for (input) |*line| {
        std.mem.reverse(u8, line);
        line.* = collapse(line);
        std.mem.reverse(u8, line);
    }
}

pub fn tilt_north(input: *Matrix) void {
    transpose(input);
    tilt_west(input);
    transpose(input);
}

pub fn tilt_south(input: *Matrix) void {
    transpose(input);
    tilt_east(input);
    transpose(input);
}

pub fn get_score(input: Matrix) i64 {
    var res: i64 = 0;
    for (input, 0..) |line, i| {
        for (line) |c| {
            if (c == 'O') {
                res += N - @as(i64, @intCast(i));
            }
        }
    }
    return res;
}

pub fn get_precise_score(input: Matrix) i64 {
    var res: i64 = 0;
    for (input, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == 'O') {
                const idx = @as(i64, @intCast(i)) * N + @as(i64, @intCast(j));
                res += idx;
            }
        }
    }
    return res;
}

pub fn transpose(input: *Matrix) void {
    var res: Matrix = undefined;
    for (0..N) |i| {
        for (0..N) |j| {
            res[i][j] = input[j][i];
        }
    }
    input.* = res;
}

// Moves as many Os as possible to the left
// Leaving all #s where they are.
pub fn collapse(line: *const Line) Line {
    var res: Line = undefined;
    var numEmpties: usize = 0;
    var numRocks: usize = 0;
    var i: usize = 0;

    for (line) |c| {
        if (c == '#') {
            // Place all the Os and dots
            for (0..numRocks) |_| {
                res[i] = 'O';
                i += 1;
            }
            for (0..numEmpties) |_| {
                res[i] = '.';
                i += 1;
            }

            numEmpties = 0;
            numRocks = 0;

            res[i] = c;
            i += 1;
        } else {
            if (c == '.') {
                numEmpties += 1;
            } else {
                numRocks += 1;
            }
        }
    }

    // Place all the Os and dots
    for (0..numRocks) |_| {
        res[i] = 'O';
        i += 1;
    }
    for (0..numEmpties) |_| {
        res[i] = '.';
        i += 1;
    }

    return res;
}

test {
    const p1 = part1();
    try std.testing.expectEqual(p1, 112046);
}

test {
    const p2 = part2();
    try std.testing.expectEqual(p2, 104619);
}
