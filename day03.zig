const std = @import("std");
const str = @embedFile("inputs/day03.txt");
const N = std.math.sqrt(str.len);
const Input = [N][N]u8;

pub fn main() !void {
    const input = getInput(str);
    const p1, const p2 = findRatiosSums(&input);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn findRatiosSums(m: *const Input) struct { i64, i64 } {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var part1: i64 = 0;
    var part2: i64 = 0;

    for (m, 0..) |row, i| {
        for (row, 0..) |c, j| {
            if (isAllowedChar(c)) continue;

            var numbers = std.ArrayList(i64).init(allocator);

            for ([3]i64{ -1, 0, 1 }) |di| {
                const I: i64 = @as(i64, @intCast(i)) + di;
                const J: i64 = @as(i64, @intCast(j));

                const isPreLeft = isNumber(getPos(m, I, J - 2));
                const isLeft = isNumber(getPos(m, I, J - 1));
                const isCenter = isNumber(getPos(m, I, J));
                const isRight = isNumber(getPos(m, I, J + 1));
                const isPostRight = isNumber(getPos(m, I, J + 2));

                const ii = @as(usize, @intCast(I));
                const jj = @as(usize, @intCast(J));

                const segment = allocator.dupe(u8, m[ii][jj - 3 .. jj + 4]) catch unreachable;

                std.mem.replaceScalar(u8, segment, '.', ' ');

                if (!isPreLeft) {
                    segment[0] = ' ';
                    segment[1] = ' ';
                }

                if (!isLeft) {
                    segment[0] = ' ';
                    segment[1] = ' ';
                    segment[2] = ' ';
                }

                if (!isCenter) {
                    segment[3] = ' ';
                }

                if (!isRight) {
                    segment[4] = ' ';
                    segment[5] = ' ';
                    segment[6] = ' ';
                }

                if (!isPostRight) {
                    segment[5] = ' ';
                    segment[6] = ' ';
                }

                var space_iterator = std.mem.tokenizeScalar(u8, segment, ' ');
                while (space_iterator.next()) |nn| {
                    const parsedNumber = std.fmt.parseInt(i64, nn, 10) catch unreachable;
                    part1 += parsedNumber;
                    numbers.append(parsedNumber) catch unreachable;
                }
            }

            if (numbers.items.len == 2) {
                const num1 = numbers.items[0];
                const num2 = numbers.items[1];
                part2 += num1 * num2;
            }
        }
    }
    return .{ part1, part2 };
}

pub fn getPos(m: *const Input, i: i64, j: i64) u8 {
    const I: usize = @as(usize, @intCast(i));
    const J: usize = @as(usize, @intCast(j));

    return m[I][J];
}

pub fn getInput(s: []const u8) Input {
    var m: [N][N]u8 = undefined;
    var line_iterator = std.mem.tokenizeScalar(u8, s, '\n');
    var i: usize = 0;
    while (line_iterator.next()) |line| : (i += 1) {
        for (line, 0..) |c, j| {
            m[i][j] = c;
        }
    }
    return m;
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

const expect = std.testing.expect;

test "Parts 1 and 2" {
    const input = getInput(str);
    const p1, const p2 = findRatiosSums(&input);
    try expect(p1 == 507214);
    try expect(p2 == 72553319);
}
