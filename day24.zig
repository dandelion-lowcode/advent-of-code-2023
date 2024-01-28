const std = @import("std");
const str = @embedFile("inputs/day24.txt");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const MIN = 200000000000000;
const MAX = 400000000000000;

// px py pz @ vx vy vz
const Hailstone = struct {
    px: f64,
    py: f64,
    pz: f64,
    vx: f64,
    vy: f64,
    vz: f64,
};

const Input = ArrayList(Hailstone);

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = getInput(allocator);
    const p1 = part1(&input);
    std.debug.print("Part 1: {d}\n", .{p1});
}

fn part1(input: *const Input) i64 {
    var res: i64 = 0;
    for (input.items, 0..) |h1, i| {
        for (i + 1..input.items.len) |j| {
            const h2 = input.items[j];
            const mayCross = find_intersection(h1, h2);
            if (mayCross) |crossing| {
                if (crossing.tA >= 0 and crossing.tB >= 0 and crossing.x >= MIN and crossing.x <= MAX and crossing.y >= MIN and crossing.y <= MAX) {
                    res += 1;
                }
            }
        }
    }
    return res;
}

const Crossing = struct {
    tA: f64,
    tB: f64,
    x: f64,
    y: f64,
};

fn find_intersection(A: Hailstone, B: Hailstone) ?Crossing {
    const det = A.vx * B.vy - A.vy * B.vx;
    if (det == 0) {
        return null;
    }

    const tA = (B.vy * (B.px - A.px) - B.vx * (B.py - A.py)) / det;
    const tB = (A.vy * (B.px - A.px) - A.vx * (B.py - A.py)) / det;

    const x = A.px + A.vx * tA;
    const y = A.py + A.vy * tA;

    return Crossing{
        .tA = tA,
        .tB = tB,
        .x = x,
        .y = y,
    };
}

fn printHail(hs: Hailstone) void {
    std.debug.print("{d} {d} {d} @ {d} {d} {d}\n", .{
        hs.px,
        hs.py,
        hs.pz,
        hs.vx,
        hs.vy,
        hs.vz,
    });
}

fn getInput(allocator: Allocator) Input {
    var res = Input.init(allocator);

    var line_splitter = std.mem.tokenizeScalar(u8, str, '\n');
    while (line_splitter.next()) |line| {
        var at_splitter = std.mem.tokenizeSequence(u8, line, " @ ");
        const left = at_splitter.next() orelse "";
        const right = at_splitter.next() orelse "";

        var ps_splitter = std.mem.tokenizeSequence(u8, left, ", ");
        const px = std.fmt.parseFloat(f64, ps_splitter.next() orelse "0");
        const py = std.fmt.parseFloat(f64, ps_splitter.next() orelse "0");
        const pz = std.fmt.parseFloat(f64, ps_splitter.next() orelse "0");

        var vs_splitter = std.mem.tokenizeSequence(u8, right, ", ");
        const vx = std.fmt.parseFloat(f64, vs_splitter.next() orelse "0");
        const vy = std.fmt.parseFloat(f64, vs_splitter.next() orelse "0");
        const vz = std.fmt.parseFloat(f64, vs_splitter.next() orelse "0");

        const hs = Hailstone{
            .px = px catch unreachable,
            .py = py catch unreachable,
            .pz = pz catch unreachable,
            .vx = vx catch unreachable,
            .vy = vy catch unreachable,
            .vz = vz catch unreachable,
        };

        res.append(hs) catch unreachable;
    }

    return res;
}
