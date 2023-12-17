const std = @import("std");
const expect = std.testing.expect;
const str = @embedFile("inputs/day07.txt");
const Allocator = std.mem.Allocator;

const Card = enum { A, K, Q, J, T, NINE, EIGHT, SEVEN, SIX, FIVE, FOUR, THREE, TWO };
const Hand = [5]Card;
const HandType = enum { HIGH_CARD, ONE_PAIR, TWO_PAIR, THREE_OF_A_KIND, FULL_HOUSE, FOUR_OF_A_KIND, FIVE_OF_A_KIND };

const BidHand = struct {
    hand: Hand,
    bid: u64,
    handType: HandType,
};

const Input = std.ArrayList(BidHand);

pub fn main() !void {
    const p1 = try getTotalWinnings(getType, getCardValue);
    const p2 = try getTotalWinnings(getTypeJoker, getCardValueJoker);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

fn getTotalWinnings(comptime getHandTypeFn: fn (Allocator, Hand) HandType, comptime getCardValueFn: fn (Card) u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try getInput(allocator, getHandTypeFn);
    const sortedInput = bubbleSort(input, getCardValueFn);

    var winnings: u64 = 0;
    for (sortedInput.items, 0..) |bid_hand, idx| {
        const integerIndex = @as(u64, @intCast(idx));
        winnings += bid_hand.bid * (integerIndex + 1);
    }
    return winnings;
}

fn getInput(allocator: Allocator, comptime getHandTypeFn: fn (Allocator, Hand) HandType) !Input {
    var res = std.ArrayList(BidHand).init(allocator);

    var lineIterator = std.mem.tokenizeSequence(u8, str, "\n");
    while (lineIterator.next()) |line| {
        var spaceIterator = std.mem.tokenizeSequence(u8, line, " ");
        const hand = try getHand(spaceIterator.next() orelse unreachable);
        const bidText = spaceIterator.next() orelse unreachable;
        const bid = try std.fmt.parseInt(u64, bidText, 10);
        const handType = getHandTypeFn(allocator, hand);
        try res.append(.{ .hand = hand, .bid = bid, .handType = handType });
    }

    return res;
}

fn expandJs(allocator: Allocator, hand: Hand, idx: usize) std.ArrayList(Hand) {
    var res = std.ArrayList(Hand).init(allocator);

    if (idx == 5) {
        res.append(hand) catch unreachable;
        return res;
    }

    if (hand[idx] == Card.J) {
        var newHand = hand;
        const otherLetters = [_]Card{
            Card.A,
            Card.K,
            Card.Q,
            Card.T,
            Card.NINE,
            Card.EIGHT,
            Card.SEVEN,
            Card.SIX,
            Card.FIVE,
            Card.FOUR,
            Card.THREE,
            Card.TWO,
        };

        for (otherLetters) |letter| {
            newHand[idx] = letter;
            const newRes = expandJs(allocator, newHand, idx + 1);
            res.appendSlice(newRes.items) catch unreachable;
        }
    } else {
        const newRes = expandJs(allocator, hand, idx + 1);
        res.appendSlice(newRes.items) catch unreachable;
    }

    return res;
}

fn bubbleSort(input: Input, comptime getCardValueFn: fn (Card) u8) Input {
    const n = input.items.len;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            if (i == j) continue;
            const bh1 = input.items[i];
            const bh2 = input.items[j];

            const h1_type = bh1.handType;
            const h2_type = bh2.handType;
            const cmp = isMorePowerfulHand(bh1.hand, bh2.hand, h1_type, h2_type, getCardValueFn);

            if (cmp) {
                std.mem.swap(BidHand, &input.items[i], &input.items[j]);
            }
        }
    }
    return input;
}

fn getHand(handStr: []const u8) !Hand {
    var hand: Hand = undefined;
    for (handStr, 0..) |c, idx| {
        const card = switch (c) {
            'A' => Card.A,
            'K' => Card.K,
            'Q' => Card.Q,
            'J' => Card.J,
            'T' => Card.T,
            '9' => Card.NINE,
            '8' => Card.EIGHT,
            '7' => Card.SEVEN,
            '6' => Card.SIX,
            '5' => Card.FIVE,
            '4' => Card.FOUR,
            '3' => Card.THREE,
            '2' => Card.TWO,
            else => @panic("Invalid card"),
        };
        hand[idx] = card;
    }

    return hand;
}

fn getCardValue(c: Card) u8 {
    return switch (c) {
        Card.A => 14,
        Card.K => 13,
        Card.Q => 12,
        Card.J => 11,
        Card.T => 10,
        Card.NINE => 9,
        Card.EIGHT => 8,
        Card.SEVEN => 7,
        Card.SIX => 6,
        Card.FIVE => 5,
        Card.FOUR => 4,
        Card.THREE => 3,
        Card.TWO => 2,
    };
}

fn getCardValueJoker(c: Card) u8 {
    return switch (c) {
        Card.A => 14,
        Card.K => 13,
        Card.Q => 12,
        Card.T => 11,
        Card.NINE => 10,
        Card.EIGHT => 9,
        Card.SEVEN => 8,
        Card.SIX => 7,
        Card.FIVE => 6,
        Card.FOUR => 5,
        Card.THREE => 4,
        Card.TWO => 3,
        Card.J => 2,
    };
}

fn isMorePowerfulHand(h1: Hand, h2: Hand, h1_type: HandType, h2_type: HandType, comptime getCardValueFn: fn (Card) u8) bool {
    if (h1_type != h2_type) {
        return @intFromEnum(h1_type) > @intFromEnum(h2_type);
    }

    for (0..5) |i| {
        const h1_card = h1[i];
        const h2_card = h2[i];
        if (h1_card != h2_card) {
            const h1_card_value = getCardValueFn(h1_card);
            const h2_card_value = getCardValueFn(h2_card);
            return h1_card_value > h2_card_value;
        }
    }

    unreachable;
}

fn getTypeJoker(allocator: Allocator, hand: Hand) HandType {
    const expansions = expandJs(allocator, hand, 0);
    var mostPowerfulHandType: HandType = HandType.HIGH_CARD;

    for (expansions.items) |expansion| {
        const expansionType = getType(allocator, expansion);
        if (expansionType == HandType.FIVE_OF_A_KIND) {
            return HandType.FIVE_OF_A_KIND;
        }
        if (@intFromEnum(expansionType) > @intFromEnum(mostPowerfulHandType)) {
            mostPowerfulHandType = expansionType;
        }
    }

    return mostPowerfulHandType;
}

fn getType(_: Allocator, hand: Hand) HandType {
    if (isKOfAKind(hand, 5)) return HandType.FIVE_OF_A_KIND;
    if (isKOfAKind(hand, 4)) return HandType.FOUR_OF_A_KIND;
    if (isKOfAKind(hand, 3)) {
        return if (isKOfAKind(hand, 2))
            HandType.FULL_HOUSE
        else
            HandType.THREE_OF_A_KIND;
    }
    if (countPairs(hand) == 2) return HandType.TWO_PAIR;
    if (countPairs(hand) == 1) return HandType.ONE_PAIR;
    return HandType.HIGH_CARD;
}

fn isKOfAKind(hand: Hand, k: u8) bool {
    var counts = [_]u8{0} ** 15;
    for (hand) |card| {
        const index = getCardValue(card);
        counts[index] += 1;
    }
    // Check if some has k of a kind
    for (counts) |count| {
        if (count == k) return true;
    }
    return false;
}

fn countPairs(hand: Hand) u8 {
    var counts = [_]u8{0} ** 15;
    for (hand) |card| {
        const index = @intFromEnum(card);
        counts[index] += 1;
    }
    var pairs: u8 = 0;
    for (counts) |count| {
        if (count == 2) pairs += 1;
    }
    return pairs;
}

test "Five of a kind" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.A, Card.A, Card.A, Card.A }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.K, Card.K, Card.K, Card.K, Card.K }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.Q, Card.Q, Card.Q, Card.Q, Card.Q }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.J, Card.J, Card.J, Card.J, Card.J }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.T, Card.T, Card.T, Card.T, Card.T }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.NINE }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.SIX, Card.SIX, Card.SIX, Card.SIX, Card.SIX }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FIVE, Card.FIVE, Card.FIVE, Card.FIVE }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.FOUR, Card.FOUR, Card.FOUR, Card.FOUR }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.THREE, Card.THREE, Card.THREE, Card.THREE, Card.THREE }) == HandType.FIVE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.TWO, Card.TWO, Card.TWO, Card.TWO, Card.TWO }) == HandType.FIVE_OF_A_KIND);
}

test "Four of a kind" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.A, Card.A, Card.A, Card.K }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.K, Card.K, Card.K, Card.K, Card.Q }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.Q, Card.Q, Card.Q, Card.Q, Card.J }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.J, Card.J, Card.J, Card.J, Card.T }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.T, Card.T, Card.T, Card.T, Card.NINE }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.EIGHT }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SEVEN }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SIX }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.SIX, Card.SIX, Card.SIX, Card.SIX, Card.FIVE }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FIVE, Card.FIVE, Card.FIVE, Card.FOUR }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.FOUR, Card.FOUR, Card.FOUR, Card.THREE }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.THREE, Card.THREE, Card.THREE, Card.THREE, Card.TWO }) == HandType.FOUR_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.TWO, Card.TWO, Card.TWO, Card.TWO, Card.A }) == HandType.FOUR_OF_A_KIND);
}

test "Full house" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.A, Card.A, Card.K, Card.K }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.K, Card.K, Card.K, Card.Q, Card.Q }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.Q, Card.Q, Card.Q, Card.J, Card.J }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.J, Card.J, Card.J, Card.T, Card.T }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.T, Card.T, Card.T, Card.NINE, Card.NINE }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.NINE, Card.NINE, Card.NINE, Card.EIGHT, Card.EIGHT }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SEVEN, Card.SEVEN }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SIX, Card.SIX }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.SIX, Card.SIX, Card.SIX, Card.FIVE, Card.FIVE }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FIVE, Card.FIVE, Card.FOUR, Card.FOUR }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.FOUR, Card.FOUR, Card.THREE, Card.THREE }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.THREE, Card.THREE, Card.THREE, Card.TWO, Card.TWO }) == HandType.FULL_HOUSE);
    try expect(getType(t_aloc, .{ Card.TWO, Card.TWO, Card.TWO, Card.A, Card.A }) == HandType.FULL_HOUSE);
}

test "Three of a kind" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.A, Card.A, Card.K, Card.Q }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.K, Card.K, Card.K, Card.Q, Card.J }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.Q, Card.Q, Card.Q, Card.J, Card.T }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.J, Card.J, Card.J, Card.T, Card.NINE }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.T, Card.T, Card.T, Card.NINE, Card.EIGHT }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.NINE, Card.NINE, Card.NINE, Card.EIGHT, Card.SEVEN }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SEVEN, Card.SIX }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SIX, Card.FIVE }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.SIX, Card.SIX, Card.SIX, Card.FIVE, Card.FOUR }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FIVE, Card.FIVE, Card.FOUR, Card.THREE }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.FOUR, Card.FOUR, Card.THREE, Card.TWO }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.THREE, Card.THREE, Card.THREE, Card.TWO, Card.A }) == HandType.THREE_OF_A_KIND);
    try expect(getType(t_aloc, .{ Card.TWO, Card.TWO, Card.TWO, Card.A, Card.K }) == HandType.THREE_OF_A_KIND);
}

test "Two pair" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.A, Card.K, Card.K, Card.Q }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.K, Card.K, Card.Q, Card.Q, Card.J }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.Q, Card.Q, Card.J, Card.J, Card.T }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.J, Card.J, Card.T, Card.T, Card.NINE }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.T, Card.T, Card.NINE, Card.NINE, Card.EIGHT }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.NINE, Card.NINE, Card.EIGHT, Card.EIGHT, Card.SEVEN }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.EIGHT, Card.SEVEN, Card.SEVEN, Card.SIX }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SEVEN, Card.SIX, Card.SIX, Card.FIVE }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.SIX, Card.SIX, Card.FIVE, Card.FIVE, Card.FOUR }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FIVE, Card.FOUR, Card.FOUR, Card.THREE }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.FOUR, Card.THREE, Card.THREE, Card.TWO }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.THREE, Card.THREE, Card.TWO, Card.TWO, Card.A }) == HandType.TWO_PAIR);
    try expect(getType(t_aloc, .{ Card.TWO, Card.TWO, Card.A, Card.A, Card.K }) == HandType.TWO_PAIR);
}

test "One pair" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.A, Card.K, Card.Q, Card.J }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.K, Card.K, Card.Q, Card.J, Card.T }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.Q, Card.Q, Card.J, Card.T, Card.NINE }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.J, Card.J, Card.T, Card.NINE, Card.EIGHT }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.T, Card.T, Card.NINE, Card.EIGHT, Card.SEVEN }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.NINE, Card.NINE, Card.EIGHT, Card.SEVEN, Card.SIX }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.EIGHT, Card.SEVEN, Card.SIX, Card.FIVE }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SEVEN, Card.SIX, Card.FIVE, Card.FOUR }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.SIX, Card.SIX, Card.FIVE, Card.FOUR, Card.THREE }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FIVE, Card.FOUR, Card.THREE, Card.TWO }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.FOUR, Card.THREE, Card.TWO, Card.A }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.THREE, Card.THREE, Card.TWO, Card.A, Card.K }) == HandType.ONE_PAIR);
    try expect(getType(t_aloc, .{ Card.TWO, Card.TWO, Card.A, Card.K, Card.Q }) == HandType.ONE_PAIR);
}

test "High card" {
    const t_aloc = std.testing.allocator;
    try expect(getType(t_aloc, .{ Card.A, Card.K, Card.Q, Card.J, Card.T }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.K, Card.Q, Card.J, Card.T, Card.NINE }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.Q, Card.J, Card.T, Card.NINE, Card.EIGHT }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.J, Card.T, Card.NINE, Card.EIGHT, Card.SEVEN }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.T, Card.NINE, Card.EIGHT, Card.SEVEN, Card.SIX }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.NINE, Card.EIGHT, Card.SEVEN, Card.SIX, Card.FIVE }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.EIGHT, Card.SEVEN, Card.SIX, Card.FIVE, Card.FOUR }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.SEVEN, Card.SIX, Card.FIVE, Card.FOUR, Card.THREE }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.SIX, Card.FIVE, Card.FOUR, Card.THREE, Card.TWO }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.FIVE, Card.FOUR, Card.THREE, Card.TWO, Card.A }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.FOUR, Card.THREE, Card.TWO, Card.A, Card.K }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.THREE, Card.TWO, Card.A, Card.K, Card.Q }) == HandType.HIGH_CARD);
    try expect(getType(t_aloc, .{ Card.TWO, Card.A, Card.K, Card.Q, Card.J }) == HandType.HIGH_CARD);
}

test "More powerful hands" {
    try expect(isMorePowerfulHand(.{ Card.A, Card.A, Card.A, Card.A, Card.A }, .{ Card.K, Card.K, Card.K, Card.K, Card.K }, HandType.FIVE_OF_A_KIND, HandType.FOUR_OF_A_KIND, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.K, Card.K, Card.K, Card.K, Card.K }, .{ Card.Q, Card.Q, Card.Q, Card.Q, Card.Q }, HandType.FOUR_OF_A_KIND, HandType.FULL_HOUSE, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.Q, Card.Q, Card.Q, Card.Q, Card.Q }, .{ Card.J, Card.J, Card.J, Card.J, Card.J }, HandType.FULL_HOUSE, HandType.THREE_OF_A_KIND, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.J, Card.J, Card.J, Card.J, Card.J }, .{ Card.T, Card.T, Card.T, Card.T, Card.T }, HandType.THREE_OF_A_KIND, HandType.TWO_PAIR, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.T, Card.T, Card.T, Card.T, Card.T }, .{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.NINE }, HandType.TWO_PAIR, HandType.ONE_PAIR, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.NINE }, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT }, HandType.ONE_PAIR, HandType.HIGH_CARD, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT }, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValue));
    try expect(isMorePowerfulHand(.{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN }, .{ Card.SIX, Card.SIX, Card.SIX, Card.SIX, Card.SIX }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValue));
}

test "More powerful hands joker" {
    // When joker is a quintuple
    try expect(isMorePowerfulHand(.{ Card.A, Card.A, Card.A, Card.A, Card.J }, .{ Card.K, Card.K, Card.K, Card.K, Card.K }, HandType.FIVE_OF_A_KIND, HandType.FOUR_OF_A_KIND, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.K, Card.K, Card.K, Card.K, Card.J }, .{ Card.Q, Card.Q, Card.Q, Card.Q, Card.Q }, HandType.FOUR_OF_A_KIND, HandType.FULL_HOUSE, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.Q, Card.Q, Card.Q, Card.Q, Card.J }, .{ Card.J, Card.J, Card.J, Card.J, Card.J }, HandType.FULL_HOUSE, HandType.THREE_OF_A_KIND, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.J, Card.J, Card.J, Card.J, Card.J }, .{ Card.T, Card.T, Card.T, Card.T, Card.T }, HandType.THREE_OF_A_KIND, HandType.TWO_PAIR, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.T, Card.T, Card.T, Card.T, Card.J }, .{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.NINE }, HandType.TWO_PAIR, HandType.ONE_PAIR, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.J }, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT }, HandType.ONE_PAIR, HandType.HIGH_CARD, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.J }, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.J }, .{ Card.SIX, Card.SIX, Card.SIX, Card.SIX, Card.SIX }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValueJoker));

    // When joker is a pair
    try expect(isMorePowerfulHand(.{ Card.A, Card.A, Card.A, Card.A, Card.K }, .{ Card.K, Card.K, Card.K, Card.K, Card.Q }, HandType.FIVE_OF_A_KIND, HandType.FOUR_OF_A_KIND, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.K, Card.K, Card.K, Card.K, Card.Q }, .{ Card.Q, Card.Q, Card.Q, Card.Q, Card.J }, HandType.FOUR_OF_A_KIND, HandType.FULL_HOUSE, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.Q, Card.Q, Card.Q, Card.Q, Card.J }, .{ Card.J, Card.J, Card.J, Card.J, Card.T }, HandType.FULL_HOUSE, HandType.THREE_OF_A_KIND, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.J, Card.J, Card.J, Card.J, Card.T }, .{ Card.T, Card.T, Card.T, Card.T, Card.NINE }, HandType.THREE_OF_A_KIND, HandType.TWO_PAIR, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.T, Card.T, Card.T, Card.T, Card.NINE }, .{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.EIGHT }, HandType.TWO_PAIR, HandType.ONE_PAIR, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.EIGHT }, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SEVEN }, HandType.ONE_PAIR, HandType.HIGH_CARD, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SEVEN }, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SIX }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SIX }, .{ Card.SIX, Card.SIX, Card.SIX, Card.SIX, Card.FIVE }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValueJoker));

    // When joker is a single
    try expect(isMorePowerfulHand(.{ Card.A, Card.A, Card.A, Card.A, Card.Q }, .{ Card.K, Card.K, Card.K, Card.K, Card.J }, HandType.FIVE_OF_A_KIND, HandType.FOUR_OF_A_KIND, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.K, Card.K, Card.K, Card.K, Card.J }, .{ Card.Q, Card.Q, Card.Q, Card.Q, Card.T }, HandType.FOUR_OF_A_KIND, HandType.FULL_HOUSE, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.Q, Card.Q, Card.Q, Card.Q, Card.T }, .{ Card.J, Card.J, Card.J, Card.J, Card.NINE }, HandType.FULL_HOUSE, HandType.THREE_OF_A_KIND, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.J, Card.J, Card.J, Card.J, Card.NINE }, .{ Card.T, Card.T, Card.T, Card.T, Card.EIGHT }, HandType.THREE_OF_A_KIND, HandType.TWO_PAIR, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.T, Card.T, Card.T, Card.T, Card.EIGHT }, .{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.SEVEN }, HandType.TWO_PAIR, HandType.ONE_PAIR, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.NINE, Card.NINE, Card.NINE, Card.NINE, Card.SEVEN }, .{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SIX }, HandType.ONE_PAIR, HandType.HIGH_CARD, getCardValueJoker));
    try expect(isMorePowerfulHand(.{ Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.EIGHT, Card.SIX }, .{ Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.SEVEN, Card.FIVE }, HandType.HIGH_CARD, HandType.HIGH_CARD, getCardValueJoker));
}

test "Correct result Part 1" {
    const p1 = try getTotalWinnings(getType, getCardValue);
    try expect(p1 == 246795406);
}

test "Correct result Part 2" {
    const p2 = try getTotalWinnings(getTypeJoker, getCardValueJoker);
    try expect(p2 == 249356515);
}
