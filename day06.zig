const std = @import("std");
const Step = struct { time: i64, distance: i64 };
const input = [_]Step{
    .{ .time = 56, .distance = 499 },
    .{ .time = 97, .distance = 2210 },
    .{ .time = 77, .distance = 1097 },
    .{ .time = 93, .distance = 1440 },
};

pub fn main() !void {
    const p1 = part1();
    const p2 = part2();

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

fn part1() i64 {
    var options: i64 = 1;
    for (input) |step| {
        const validOptions = getValidOptions(step);
        options *= validOptions;
    }
    return options;
}

fn part2() i64 {
    const t: f64 = 56977793;
    const d: f64 = 499221010971440;

    return getValidOptions(.{ .time = t, .distance = d });
}

fn getValidOptions(step: Step) i64 {
    var res: i64 = 0;
    var hold: i64 = 0;
    while (hold < step.time) : (hold += 1) {
        if (hold * (step.time - hold) > step.distance) {
            res += 1;
        }
    }
    return res;
}

// fn getValidOptionsMath(step: Step) i64 {
//     const t: f64 = @floatFromInt(step.time);
//     const d: f64 = @floatFromInt(step.distance);

//     const discr = @sqrt(t * t - 4 * d);
//     const x1 = (t - discr) / 2;
//     const x2 = (t + discr) / 2;

//     const diff = x2 - x1;

//     const res = @ceil(diff);
//     return @intFromFloat(res);
// }

test "Part 1" {
    const p1 = part1();
    try std.testing.expect(p1 == 1710720);
}

test "Part 2" {
    const p2 = part2();
    try std.testing.expect(p2 == 35349468);
}
