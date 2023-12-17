const std = @import("std");
const str = @embedFile("inputs/day16.txt");
const Allocator = std.mem.Allocator;
const Queue = @import("queue.zig").Queue;

const N = 110;

const Matrix = [N][N]Cell;
const Cell = enum(u8) {
    EMPTY = '.',
    RIGHT_MIRROR = '/',
    LEFT_MIRROR = '\\',
    VERTICAL_SPLITTER = '|',
    HORIZONTAL_SPLITTER = '-',
};

const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

const MatrixVisited = [N][N]bool;

const Beam = struct { i: usize, j: usize, dir: Direction };
const Bounces = struct { b1: ?Direction, b2: ?Direction };

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const m = readMap();

    const p1 = part1(allocator, &m);
    const p2 = part2(allocator, &m);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1(allocator: Allocator, m: *const Matrix) i64 {
    return get_energy(allocator, .{ .i = 0, .j = 0, .dir = .RIGHT }, m);
}

pub fn part2(allocator: Allocator, m: *const Matrix) i64 {
    var res: i64 = 0;
    for (0..N) |d| {
        res = @max(res, get_energy(allocator, .{ .i = 0, .j = d, .dir = .DOWN }, m));
        res = @max(res, get_energy(allocator, .{ .i = N - 1, .j = d, .dir = .UP }, m));
        res = @max(res, get_energy(allocator, .{ .i = d, .j = 0, .dir = .RIGHT }, m));
        res = @max(res, get_energy(allocator, .{ .i = d, .j = N - 1, .dir = .LEFT }, m));
    }
    return res;
}

pub fn get_energy(allocator: Allocator, initial_beam: Beam, m: *const Matrix) i64 {
    var matrix_visited_up: MatrixVisited = [_][N]bool{[_]bool{false} ** N} ** N;
    var matrix_visited_down: MatrixVisited = [_][N]bool{[_]bool{false} ** N} ** N;
    var matrix_visited_left: MatrixVisited = [_][N]bool{[_]bool{false} ** N} ** N;
    var matrix_visited_right: MatrixVisited = [_][N]bool{[_]bool{false} ** N} ** N;

    var queue = Queue(Beam).init(allocator);
    queue.enqueue(initial_beam) catch unreachable;

    while (!queue.isEmpty()) {
        const beam = queue.dequeue() orelse unreachable;
        const i = beam.i;
        const j = beam.j;
        const c = m[i][j];

        switch (beam.dir) {
            .UP => {
                if (matrix_visited_up[i][j]) continue;
                matrix_visited_up[i][j] = true;
            },
            .DOWN => {
                if (matrix_visited_down[i][j]) continue;
                matrix_visited_down[i][j] = true;
            },
            .LEFT => {
                if (matrix_visited_left[i][j]) continue;
                matrix_visited_left[i][j] = true;
            },
            .RIGHT => {
                if (matrix_visited_right[i][j]) continue;
                matrix_visited_right[i][j] = true;
            },
        }

        const bounces = getBounces(beam.dir, c);
        const bounce_list: [2]?Direction = .{ bounces.b1, bounces.b2 };
        inline for (bounce_list) |maybe_bounce| {
            if (maybe_bounce) |bounce| {
                const maybe_new_beam = advanceBeam(bounce, i, j);
                if (maybe_new_beam) |new_beam| {
                    queue.enqueue(new_beam) catch unreachable;
                }
            }
        }
    }

    return countLit(&matrix_visited_right, &matrix_visited_left, &matrix_visited_up, &matrix_visited_down);
}

fn advanceBeam(direction: Direction, i: usize, j: usize) ?Beam {
    const newI = @as(i64, @intCast(i)) + getDi(direction);
    const newJ = @as(i64, @intCast(j)) + getDj(direction);
    if (0 <= newI and newI < N and 0 <= newJ and newJ < N) {
        const i_1 = @as(usize, @intCast(newI));
        const j_1 = @as(usize, @intCast(newJ));
        return .{ .i = i_1, .j = j_1, .dir = direction };
    }
    return null;
}

inline fn getDi(d: Direction) i64 {
    return switch (d) {
        .UP => -1,
        .DOWN => 1,
        .LEFT, .RIGHT => 0,
    };
}

inline fn getDj(d: Direction) i64 {
    return switch (d) {
        .UP, .DOWN => 0,
        .LEFT => -1,
        .RIGHT => 1,
    };
}

fn getBounces(d: Direction, c: Cell) Bounces {
    return switch (c) {
        .EMPTY => .{ .b1 = d, .b2 = null },
        .RIGHT_MIRROR => switch (d) {
            .UP => .{ .b1 = .RIGHT, .b2 = null },
            .DOWN => .{ .b1 = .LEFT, .b2 = null },
            .LEFT => .{ .b1 = .DOWN, .b2 = null },
            .RIGHT => .{ .b1 = .UP, .b2 = null },
        },
        .LEFT_MIRROR => switch (d) {
            .UP => .{ .b1 = .LEFT, .b2 = null },
            .DOWN => .{ .b1 = .RIGHT, .b2 = null },
            .LEFT => .{ .b1 = .UP, .b2 = null },
            .RIGHT => .{ .b1 = .DOWN, .b2 = null },
        },
        .VERTICAL_SPLITTER => switch (d) {
            .LEFT, .RIGHT => .{
                .b1 = .UP,
                .b2 = .DOWN,
            },
            else => .{ .b1 = d, .b2 = null },
        },
        .HORIZONTAL_SPLITTER => switch (d) {
            .UP, .DOWN => .{
                .b1 = .LEFT,
                .b2 = .RIGHT,
            },
            else => .{ .b1 = d, .b2 = null },
        },
    };
}

fn readMap() Matrix {
    var res: Matrix = undefined;
    var line_iterator = std.mem.tokenizeScalar(u8, str, '\n');
    var lineIdx: usize = 0;
    while (line_iterator.next()) |line| : (lineIdx += 1) {
        for (line, 0..) |c, cIdx| {
            res[lineIdx][cIdx] = @enumFromInt(c);
        }
    }
    return res;
}

pub fn countLit(m1: *const MatrixVisited, m2: *const MatrixVisited, m3: *const MatrixVisited, m4: *const MatrixVisited) i64 {
    var count: i64 = 0;
    for (0..N) |i| {
        for (0..N) |j| {
            if (m1[i][j] or m2[i][j] or m3[i][j] or m4[i][j]) count += 1;
        }
    }
    return count;
}

test "Part 1" {
    const m = readMap();
    const p1 = part1(std.testing.allocator, &m);
    try std.testing.expect(p1 == 7236);
}

test "Part 2" {
    const m = readMap();
    const p2 = part2(std.testing.allocator, &m);
    try std.testing.expect(p2 == 7521);
}
