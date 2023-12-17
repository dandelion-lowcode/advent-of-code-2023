const std = @import("std");
const str = @embedFile("day02.txt");

pub fn main() !void {
    std.debug.print("Part 1: {d}\n", .{part1()});
    std.debug.print("Part 2: {d}\n", .{part2()});
}

pub fn part1() u32 {
    var lines = std.mem.tokenizeSequence(u8, str, "\r\n");
    var lineIdx: u32 = 0;
    var sumIds: u32 = 0;
    while (lines.next()) |line| {
        lineIdx += 1;
        if (isValid1(line)) {
            sumIds += lineIdx;
        }
    }
    return sumIds;
}

fn isValid1(line: []const u8) bool {
    var semicolonParts = std.mem.tokenizeSequence(u8, line, ": ");
    _ = semicolonParts.next();
    const afterSemicolon = semicolonParts.next() orelse return false;
    return parseParts1(afterSemicolon);
}

fn parseParts1(blocks: []const u8) bool {
    var parts = std.mem.split(u8, blocks, "; ");
    while (parts.next()) |part| {
        var colors = std.mem.tokenizeSequence(u8, part, ", ");

        var red: u8 = 0;
        var green: u8 = 0;
        var blue: u8 = 0;

        while (colors.next()) |color| {
            var colorParts = std.mem.tokenizeSequence(u8, color, " ");
            const number = colorParts.next() orelse return undefined;
            const integer = std.fmt.parseInt(u8, number, 10) catch return undefined;
            const colorName = colorParts.next() orelse return undefined;

            if (std.mem.eql(u8, colorName, "red")) {
                red += integer;
            } else if (std.mem.eql(u8, colorName, "green")) {
                green += integer;
            } else if (std.mem.eql(u8, colorName, "blue")) {
                blue += integer;
            } else {
                std.log.info("unknown color '{s}'\n", .{colorName});
                return undefined;
            }
        }

        if (red > 12) return false;
        if (green > 13) return false;
        if (blue > 14) return false;
    }

    return true;
}

pub fn part2() u32 {
    var lines = std.mem.tokenizeSequence(u8, str, "\r\n");
    var res: u32 = 0;
    while (lines.next()) |line| {
        res += potence(line);
    }
    return res;
}

pub fn potence(line: []const u8) u32 {
    var semicolonParts = std.mem.tokenizeSequence(u8, line, ": ");
    _ = semicolonParts.next();
    const afterSemicolon = semicolonParts.next() orelse return 0;
    return parseParts2(afterSemicolon);
}

fn parseParts2(blocks: []const u8) u32 {
    var parts = std.mem.split(u8, blocks, "; ");

    var maxRed: u32 = 0;
    var maxGreen: u32 = 0;
    var maxBlue: u32 = 0;
    while (parts.next()) |part| {
        var colors = std.mem.tokenizeSequence(u8, part, ", ");

        while (colors.next()) |color| {
            var colorParts = std.mem.tokenizeSequence(u8, color, " ");
            const number = colorParts.next() orelse return 0;
            const integer = std.fmt.parseInt(u8, number, 10) catch return 0;
            const colorName = colorParts.next() orelse return 0;

            if (std.mem.eql(u8, colorName, "red")) {
                maxRed = @max(maxRed, integer);
            } else if (std.mem.eql(u8, colorName, "green")) {
                maxGreen = @max(maxGreen, integer);
            } else if (std.mem.eql(u8, colorName, "blue")) {
                maxBlue = @max(maxBlue, integer);
            } else {
                std.log.info("unknown color '{s}'\n", .{colorName});
                return 0;
            }
        }
    }

    const res = maxRed * maxGreen * maxBlue;
    return res;
}
