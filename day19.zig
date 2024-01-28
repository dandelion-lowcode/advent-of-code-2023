const std = @import("std");
const str = @embedFile("inputs/day19.txt");
const ArrayList = std.ArrayList;

const Input = struct {
    workflows: ArrayList(Workflow),
    ratings: ArrayList(Rating),
};

const RuleCondition = struct {
    index: u8,
    isGreaterThan: bool,
    value: i64,
    tag: [3]u8,
};

const Rule = union(enum) {
    reject: void,
    accept: void,
    condition: RuleCondition,
    jump: [3]u8,
};

const Workflow = struct {
    tag: [3]u8,
    rules: [3]Rule,
    rulesHowMany: usize,
};

const Rating = struct {
    x: i64,
    m: i64,
    a: i64,
    s: i64,
};

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    _ = allocator;

    const input = getInput();
    const w = input.workflows.items[0];
    _ = w;
    const idx = "in ";
    const matchingWorkflow = locateWorkflow(&input, idx);
    std.debug.print("matchingWorkflow: {}\n", .{matchingWorkflow});
}

pub fn locateWorkflow(input: *const Input, tag: *const [3]u8) Workflow {
    const workflows = input.workflows.items;
    for (workflows) |workflow| {
        if (std.mem.eql(u8, &workflow.tag, tag)) {
            return workflow;
        }
    }
    @panic("no matching workflow");
}

pub fn getInput() Input {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var double_line_iterator = std.mem.tokenizeSequence(u8, str, "\n\n");
    const workflows_str = double_line_iterator.next() orelse "";
    var workflow_iterator = std.mem.tokenizeScalar(u8, workflows_str, '\n');

    var workflows = ArrayList(Workflow).init(allocator);
    var ratings = ArrayList(Rating).init(allocator);

    while (workflow_iterator.next()) |line| {
        const workflow = parseWorkflow(line);
        workflows.append(workflow) catch unreachable;
    }

    const ratings_str = double_line_iterator.next() orelse "";
    var ratings_iterator = std.mem.tokenizeSequence(u8, ratings_str, "\n");
    while (ratings_iterator.next()) |line| {
        const rating = parseRating(line);
        ratings.append(rating) catch unreachable;
    }

    return Input{
        .workflows = workflows,
        .ratings = ratings,
    };
}

pub fn parseRating(line: []const u8) Rating {
    var comma_splitter = std.mem.tokenizeScalar(u8, line[1 .. line.len - 1], ',');

    var x: ?i64 = null;
    var m: ?i64 = null;
    var a: ?i64 = null;
    var s: ?i64 = null;

    while (comma_splitter.next()) |token| {
        var colon_splitter = std.mem.tokenizeScalar(u8, token, '=');
        const key = (colon_splitter.next() orelse "")[0];
        const valueStr = colon_splitter.next() orelse "";
        const value: i64 = std.fmt.parseInt(i64, valueStr, 10) catch unreachable;

        switch (key) {
            'x' => x = value,
            'm' => m = value,
            'a' => a = value,
            's' => s = value,
            else => unreachable,
        }
    }

    const r = Rating{
        .x = x.?,
        .m = m.?,
        .a = a.?,
        .s = s.?,
    };

    return r;
}

pub fn parseWorkflow(line: []const u8) Workflow {
    var open_brace_splitter = std.mem.tokenizeScalar(u8, line, '{');
    const tag = open_brace_splitter.next() orelse "";
    var after_bracket = open_brace_splitter.next() orelse "";
    const rulesStr = after_bracket[0 .. after_bracket.len - 1];
    var comma_splitter = std.mem.tokenizeScalar(u8, rulesStr, ',');
    var rules: [3]Rule = undefined;
    var ruleIdx: usize = 0;
    while (comma_splitter.next()) |ruleStr| : (ruleIdx += 1) {
        const rule = parseRule(ruleStr);
        rules[ruleIdx] = rule;
    }

    const other = [3]u8{ tag[0], tag[1], ' ' };
    const fullTag = if (tag.len == 3) (tag[0..3].*) else (other);

    return Workflow{
        .tag = fullTag,
        .rules = rules,
        .rulesHowMany = ruleIdx,
    };
}

pub fn parseRule(line: []const u8) Rule {
    if (line.len == 1) {
        switch (line[0]) {
            'A' => return Rule.accept,
            'R' => return Rule.reject,
            else => unreachable,
        }
    }

    if (std.mem.indexOfScalar(u8, line, ':') == null) {
        const other = [3]u8{ line[0], line[1], ' ' };
        const fullTag = if (line.len == 3) (line[0..3].*) else (other);
        return Rule{ .jump = fullTag };
    }

    var colon_splitter = std.mem.tokenizeScalar(u8, line, ':');
    const expressionStr = colon_splitter.next() orelse "";
    const tag = colon_splitter.next() orelse "";
    const index = expressionStr[0];
    const isGreaterThan = expressionStr[1] == '>';
    const valueStr = expressionStr[2..expressionStr.len];

    const value: i64 = std.fmt.parseInt(i64, valueStr, 10) catch unreachable;

    const fullTag = if (tag.len == 3) (tag[0..3].*) else (if (tag.len == 1) ([3]u8{ tag[0], ' ', ' ' }) else (([3]u8{ tag[0], tag[1], ' ' })));

    return Rule{ .condition = .{
        .index = index,
        .isGreaterThan = isGreaterThan,
        .value = value,
        .tag = fullTag,
    } };
}
