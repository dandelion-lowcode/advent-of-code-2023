const std = @import("std");
const str = @embedFile("inputs/day20.txt");
const ArrayList = std.ArrayList;
const Queue = @import("queue.zig").Queue;

const Input = ArrayList(Module);
const Module = struct {
    name: []const u8,
    type: u8,
    destinations: ArrayList([]const u8),
    isOn: bool,
};

const Pulse = struct {
    from: []const u8,
    moduleNameTarget: []const u8,
    pitchIsHigh: bool,
};

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var input = getInput();
    const broadcast = getBroadcaster(&input);

    var queue = Queue(Pulse).init(allocator);

    for (broadcast.destinations.items) |destination| {
        queue.enqueue(Pulse{
            .from = "broadcast",
            .moduleNameTarget = destination,
            .pitchIsHigh = false,
        }) catch unreachable;
    }

    while (!queue.isEmpty()) {
        const pulse = queue.dequeue() orelse unreachable;
        std.debug.print("{s} -{s}-> {s}\n", .{ pulse.from, if (pulse.pitchIsHigh) "high" else "low", pulse.moduleNameTarget });

        const isHigh = pulse.pitchIsHigh;

        const module = findModule(&input, pulse.moduleNameTarget);

        // Flip-flop modules (prefix %) are either on or off; they are initially off. If a flip-flop module receives a high pulse, it is ignored and nothing happens. However, if a flip-flop module receives a low pulse, it flips between on and off. If it was off, it turns on and sends a high pulse. If it was on, it turns off and sends a low pulse.
        if (module.type == '%') {
            if (isHigh == false) {
                module.isOn = !module.isOn;
                for (module.destinations.items) |destination| {
                    queue.enqueue(Pulse{
                        .from = module.name,
                        .moduleNameTarget = destination,
                        .pitchIsHigh = module.isOn,
                    }) catch unreachable;
                }
            }
        }
        // Conjunction modules (prefix &) remember the type of the most recent pulse received from each of their connected input modules; they initially default to remembering a low pulse for each input. When a pulse is received, the conjunction module first updates its memory for that input. Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.
        else if (module.type == '&') {
            module.isOn = isHigh;

            var allHigh = true;
            for (module.destinations.items) |destination| {
                const m = findModule(&input, destination);
                if (m.isOn == false) {
                    allHigh = false;
                    break;
                }
            }

            for (module.destinations.items) |destination| {
                queue.enqueue(Pulse{
                    .from = module.name,
                    .moduleNameTarget = destination,
                    .pitchIsHigh = !allHigh,
                }) catch unreachable;
            }
        }
    }
}

pub fn printInput(input: *Input) void {
    for (input.items) |it| {
        printModule(it);
    }
}

pub fn printModule(module: *const Module) void {
    std.debug.print("{u} {s} ->", .{ module.type, module.name });
    for (module.destinations.items) |destination| {
        std.debug.print(" {s}", .{destination});
    }
    std.debug.print("\n", .{});
}

pub fn getBroadcaster(i: *Input) *Module {
    return findModule(i, "roadcaster");
}

pub fn findModule(i: *Input, name: []const u8) *Module {
    if (std.mem.eql(u8, name, "broadcast")) {
        return getBroadcaster(i);
    }

    for (i.items) |*it| {
        if (std.mem.eql(u8, it.name, name)) {
            return it;
        }
    }
    unreachable;
}

pub fn getInput() Input {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var line_iterator = std.mem.tokenizeScalar(u8, str, '\n');

    var modules = ArrayList(Module).init(allocator);
    while (line_iterator.next()) |line| {
        var spacer_iterator = std.mem.tokenizeSequence(u8, line, " -> ");
        const left_side = spacer_iterator.next() orelse "";
        const right_side = spacer_iterator.next() orelse "";

        const name = left_side[1..];

        var destinations = ArrayList([]const u8).init(allocator);
        var destination_iterator = std.mem.tokenizeSequence(u8, right_side, ", ");
        while (destination_iterator.next()) |destination| {
            destinations.append(destination) catch unreachable;
        }

        const firstLetter = left_side[0];
        const t = if (firstLetter == 'b') ('%') else firstLetter;

        const module = Module{
            .name = name,
            .destinations = destinations,
            .type = t,
            .isOn = false,
        };
        modules.append(module) catch unreachable;
    }
    return modules;
}
