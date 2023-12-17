const std = @import("std");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const line = "4 3 2 1 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14 -15 -16";
    var tokenized = std.mem.tokenize(u8, line, " ");
    var numbers = std.ArrayList(i64).init(allocator);
    while (tokenized.next()) |token| {
        const number = std.fmt.parseInt(i64, token, 10) catch unreachable;
        numbers.append(number) catch unreachable;
    }

    var listOfLists = std.ArrayList(std.ArrayList(i64)).init(allocator);
    listOfLists.append(numbers) catch unreachable;
    var array = numbers;
    while (!allZeros(array)) {
        array = diffArray(array);
        listOfLists.append(array) catch unreachable;
    }

    // Add a 0 to the end of the last list
    listOfLists.items[listOfLists.items.len - 1].append(0) catch unreachable;

    var I: i32 = @as(i32, @intCast(listOfLists.items.len)) - 2;
    while (I >= 0) : (I -= 1) {
        const idx = @as(usize, @intCast(I));
        const lastOfNext = listOfLists.items[idx + 1].items[listOfLists.items[idx + 1].items.len - 1];
        const lastOfCurrent = listOfLists.items[idx].items[listOfLists.items[idx].items.len - 1];
        const newItem = lastOfCurrent + lastOfNext;
        listOfLists.items[idx].append(newItem) catch unreachable;

        for (listOfLists.items, 0..) |list, it| {
            std.debug.print("list {d}: ", .{it});
            printNumbers(list);
        }

        std.debug.print("--------------------\n", .{});
    }

    const lastOfFirst = listOfLists.items[0].items[listOfLists.items[0].items.len - 1];
    std.debug.print("result: {d}\n", .{lastOfFirst});
}

fn printNumbers(numbers: std.ArrayList(i64)) void {
    for (numbers.items) |number| {
        std.debug.print("{d} ", .{number});
    }
    std.debug.print("\n", .{});
}

fn diffArray(numbers: std.ArrayList(i64)) std.ArrayList(i64) {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var diffs = std.ArrayList(i64).init(allocator);
    for (1..numbers.items.len) |i| {
        const diff = numbers.items[i] - numbers.items[i - 1];
        diffs.append(diff) catch unreachable;
    }
    return diffs;
}

fn allZeros(numbers: std.ArrayList(i64)) bool {
    for (numbers.items) |number| {
        if (number != 0) {
            return false;
        }
    }
    return true;
}
