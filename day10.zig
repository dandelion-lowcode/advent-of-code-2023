const std = @import("std");
const str = @embedFile("inputs/day10.txt");
const N = 11; //140

const Matrix = [N][N]u8;
const DistanceMatrix = [N][N]i32;
const D = struct {
    di: i32,
    dj: i32,
};

pub fn main() void {
    const matrix = readMatrix();

    // Perform a BFS from the starting point (which has distance 0)
    // ignoring all '.' cells
    //const iStart = 19;
    //const jStart = 88;

    const iStart = 1;
    const jStart = 1;

    const line: [N]i32 = [_]i32{-1} ** N;
    var distanceMatrix: [N][N]i32 = [_][N]i32{line} ** N;

    // Set the starting point to 0
    distanceMatrix[iStart][jStart] = 0;

    var queue = Queue(struct { i: i32, j: i32 }).init(std.heap.page_allocator);
    queue.enqueue(.{ .i = iStart, .j = jStart }) catch unreachable;

    while (queue.count > 0) {
        const ij = queue.dequeue() orelse unreachable;
        const i = ij.i;
        const j = ij.j;

        const i_usize = @as(usize, @intCast(i));
        const j_usize = @as(usize, @intCast(j));

        const distance = distanceMatrix[i_usize][j_usize];

        const dd = getDs(matrix[i_usize][j_usize]);

        if (dd) |ds| {
            for (ds) |d| {
                const iNext = i + d.di;
                const jNext = j + d.dj;

                if (iNext < 0 or jNext < 0 or iNext >= N or jNext >= N) {
                    continue;
                }

                const iNext_usize = @as(usize, @intCast(iNext));
                const jNext_usize = @as(usize, @intCast(jNext));

                if (matrix[iNext_usize][jNext_usize] == '.') {
                    continue;
                }

                if (distanceMatrix[iNext_usize][jNext_usize] == -1) {
                    distanceMatrix[iNext_usize][jNext_usize] = distance + 1;

                    queue.enqueue(.{ .i = iNext, .j = jNext }) catch unreachable;
                }
            }
        }
    }

    // Find the maximum distance
    var maxDistance: i32 = 0;
    for (distanceMatrix) |row| {
        for (row) |d| {
            if (d > maxDistance) {
                maxDistance = d;
            }
        }
    }

    std.debug.print("Max distance: {d}\n", .{maxDistance});
}

pub fn getDs(c: u8) ?[2]D {
    const NORTH = .{ .di = -1, .dj = 0 };
    const SOUTH = .{ .di = 1, .dj = 0 };
    const EAST = .{ .di = 0, .dj = 1 };
    const WEST = .{ .di = 0, .dj = -1 };

    return switch (c) {
        '|' => .{ NORTH, SOUTH },
        '-' => .{ EAST, WEST },
        'L' => .{ NORTH, EAST },
        'J' => .{ NORTH, WEST },
        '7' => .{ SOUTH, WEST },
        'F' => .{ SOUTH, EAST },
        else => null,
    };
}

pub fn readMatrix() Matrix {
    var m: Matrix = undefined;
    var i: usize = 0;
    var j: usize = 0;
    for (str) |c| {
        if (c == '\n') {
            i += 1;
            j = 0;
        } else {
            m[i][j] = c;
            j += 1;
        }
    }
    return m;
}

pub fn Queue(comptime Child: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: Child,
            next: ?*Node,
        };
        gpa: std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,
        count: usize, // Added count field

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .start = null,
                .end = null,
                .count = 0, // Initialize count to 0
            };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.gpa.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
            this.count += 1; // Increment count
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.gpa.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            this.count -= 1; // Decrement count
            return start.data;
        }
    };
}
