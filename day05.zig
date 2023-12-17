const std = @import("std");
const str = @embedFile("inputs/day05.txt");
const Allocator = std.mem.Allocator;
const String = []const u8;

const Range = struct { destinationStart: i64, sourceStart: i64, range: i64 };

const Input = struct {
    seeds: std.ArrayList(i64),
    seed_soil: std.ArrayList(Range),
    soil_fertilizer: std.ArrayList(Range),
    fertilizer_water: std.ArrayList(Range),
    water_light: std.ArrayList(Range),
    light_temperature: std.ArrayList(Range),
    temperature_humidity: std.ArrayList(Range),
    humidity_location: std.ArrayList(Range),
};

pub fn main() !void {
    const input = try parseInput();

    const p1 = try part1(input);
    const p2 = try part2();
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {?d}\n", .{p2});
}

pub fn part1(input: Input) !i64 {
    // Find the minimum seed
    var min: i64 = @as(i64, @bitCast(std.math.inf(f64)));
    for (input.seeds.items[1..]) |seed| {
        const location = getFullTranslation(seed, input);
        if (location < min) {
            min = location;
        }
    }
    return min;
}

pub fn part2() !?i64 {
    // var i: usize = 0;
    // while (i < input.seeds.items.len - 1) : (i += 2) {
    //     const start = input.seeds.items[i];
    //     const howMany = input.seeds.items[i + 1];
    // }
    return null;
}

pub fn parseInput() !Input {
    var blocksIterator = std.mem.tokenizeSequence(u8, str, "\n\n");

    const seeds = try readListOfNumbers(discardHeader(blocksIterator.next() orelse unreachable));

    const seed_soil = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));
    const soil_fertilizer = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));
    const fertilizer_water = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));
    const water_light = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));
    const light_temperature = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));
    const temperature_humidity = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));
    const humidity_location = try readRanges(discardHeader(blocksIterator.next() orelse unreachable));

    const input = Input{
        .seeds = seeds,
        .seed_soil = seed_soil,
        .soil_fertilizer = soil_fertilizer,
        .fertilizer_water = fertilizer_water,
        .water_light = water_light,
        .light_temperature = light_temperature,
        .temperature_humidity = temperature_humidity,
        .humidity_location = humidity_location,
    };
    return input;
}

pub fn getTranslation(input: i64, ranges: std.ArrayList(Range)) i64 {
    for (ranges.items) |range| {
        const result = applyRange(input, range);
        if (result != -1) {
            return result;
        }
    }
    return input;
}

pub fn getFullTranslation(seed: i64, input: Input) i64 {
    const soil = getTranslation(seed, input.seed_soil);
    const fertilizer = getTranslation(soil, input.soil_fertilizer);
    const water = getTranslation(fertilizer, input.fertilizer_water);
    const light = getTranslation(water, input.water_light);
    const temperature = getTranslation(light, input.light_temperature);
    const humidity = getTranslation(temperature, input.temperature_humidity);
    const location = getTranslation(humidity, input.humidity_location);
    return location;
}

pub fn discardHeader(input: String) String {
    var i: usize = 0;
    while (input[i] != ':') : (i += 1) {}
    return input[i + 2 ..];
}

pub fn readListOfNumbers(input: String) !std.ArrayList(i64) {
    var spaceIterator = std.mem.tokenizeSequence(u8, input, " ");
    //  try std.fmt.parseInt(i64, number, 10);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var result = std.ArrayList(i64).init(allocator);
    while (spaceIterator.next()) |number| {
        try result.append(try std.fmt.parseInt(i64, number, 10));
    }

    return result;
}

pub fn readRange(input: String) !Range {
    const listOfNumbers = try readListOfNumbers(input);
    const destinationStart = listOfNumbers.items[0];
    const sourceStart = listOfNumbers.items[1];
    const range = listOfNumbers.items[2];

    return Range{
        .destinationStart = destinationStart,
        .sourceStart = sourceStart,
        .range = range,
    };
}

pub fn readRanges(input: String) !std.ArrayList(Range) {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var result = std.ArrayList(Range).init(allocator);
    var spaceIterator = std.mem.tokenizeSequence(u8, input, "\n");
    while (spaceIterator.next()) |range| {
        try result.append(try readRange(range));
    }

    return result;
}

pub fn applyRange(i: i64, range: Range) i64 {
    if (range.sourceStart <= i and i <= range.sourceStart + range.range) {
        return range.destinationStart + (i - range.sourceStart);
    } else {
        return -1;
    }
}
