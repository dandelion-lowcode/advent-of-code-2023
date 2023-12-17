const std = @import("std");
const str = @embedFile("inputs/day04.txt");
const Allocator = std.mem.Allocator;

const N_WINNING = 10;
const NUM_MAX = 100;
const NUM_CARDS = 194;
const Card = [NUM_MAX]u8;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const cards = try getCards(allocator);
    const p1 = part1(allocator, cards);
    const p2 = part2(allocator, cards);

    std.debug.print("Part 1: {!d}\n", .{p1});
    std.debug.print("Part 2: {!d}\n", .{p2});
}

pub fn getCards(allocator: Allocator) !std.ArrayList(Card) {
    var lineIterator = std.mem.tokenizeSequence(u8, str, "\n");
    var cards = std.ArrayList(Card).init(allocator);
    while (lineIterator.next()) |line| {
        try cards.append(try getCard(line));
    }
    return cards;
}

pub fn part1(allocator: Allocator, cards: std.ArrayList(Card)) !u32 {
    var res: u32 = 0;
    for (cards.items) |card| {
        const score = try getLineScore(card, allocator);
        if (score > 0) {
            res += std.math.pow(u32, 2, score - 1);
        }
    }
    return res;
}

pub fn part2(allocator: Allocator, cards: std.ArrayList(Card)) !u32 {
    // Initialize an array of size NUM_CARDS with 1s
    var cardCount = [_]u32{1} ** NUM_CARDS;

    for (cards.items, 0..) |card, idx| {
        const score = try getLineScore(card, allocator);
        const currentCount = cardCount[idx];
        var i: usize = 0;
        while (i < score) : (i += 1) {
            cardCount[idx + i + 1] += currentCount;
        }
    }

    var res: u32 = 0;
    for (cardCount) |count| {
        res += count;
    }

    return res;
}

pub fn getCard(line: []const u8) !Card {
    var splitByColon = std.mem.tokenizeSequence(u8, line, ":");
    _ = splitByColon.next() orelse "";
    const numbersPart = splitByColon.next() orelse "";

    var splitNumbersBySpace = std.mem.tokenizeSequence(u8, numbersPart, " ");
    var numbers: [NUM_MAX]u8 = undefined;

    var i: usize = 0;
    while (splitNumbersBySpace.next()) |number| : (i += 1) {
        numbers[i] = try std.fmt.parseInt(u8, number, 10);
    }

    return numbers;
}

pub fn getLineScore(card: Card, allocator: Allocator) !u32 {
    var my_hash_map = std.AutoHashMap(u8, void).init(allocator);
    defer my_hash_map.deinit();

    for (card[0..N_WINNING]) |number| {
        try my_hash_map.put(number, {});
    }

    var lineScore: u32 = 0;
    for (card[N_WINNING..NUM_MAX]) |number| {
        if (my_hash_map.get(number)) |_| {
            lineScore += 1;
        }
    }
    return lineScore;
}
