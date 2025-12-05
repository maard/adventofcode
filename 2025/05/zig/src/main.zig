const std = @import("std");
const zig = @import("zig");

const filename = "input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    try part2(file);
}

const pair = struct {
    first: usize,
    second: usize,
};

fn part1(file: std.fs.File) !void {
    var buf: [128]u8 = undefined;

    var result: usize = 0;
    var it = LineIterator.init(file, &buf);
    const allocator = std.heap.page_allocator;

    var ranges = std.ArrayList(pair).empty;
    defer ranges.deinit(allocator);

    var in_list = false;

    while (try it.next()) |line| {
        if (line.len == 0) {
            if (in_list) break;
            in_list = true;
            continue;
        }
        if (!in_list) {
            var it2 = std.mem.splitScalar(u8, line, '-');
            const from = it2.next().?;
            const to = it2.next().?;
            const first = @as(usize, @intCast(try std.fmt.parseInt(i64, from, 10)));
            const second = @as(usize, @intCast(try std.fmt.parseInt(i64, to, 10)));
            try ranges.append(allocator, .{ .first = first, .second = second });
            continue;
        }
        const v = @as(usize, @intCast(try std.fmt.parseInt(i64, line, 10)));
        for (ranges.items) |p| {
            if (p.first <= v and v <= p.second) {
                result += 1;
                break;
            }
        }
    }
    std.debug.print("{d}\n", .{result});
}

const Context = struct {};

fn part2(file: std.fs.File) !void {
    var buf: [128]u8 = undefined;

    var result: usize = 0;
    var it = LineIterator.init(file, &buf);
    const allocator = std.heap.page_allocator;

    var ranges = std.ArrayList(pair).empty;
    defer ranges.deinit(allocator);

    while (try it.next()) |line| {
        if (line.len == 0) break;
        var it2 = std.mem.splitScalar(u8, line, '-');
        const from = it2.next().?;
        const to = it2.next().?;
        const first = @as(usize, @intCast(try std.fmt.parseInt(i64, from, 10)));
        const second = @as(usize, @intCast(try std.fmt.parseInt(i64, to, 10)));
        try ranges.append(allocator, .{ .first = first, .second = second });
    }

    const ranges_slice = try ranges.toOwnedSlice(allocator);
    defer allocator.free(ranges_slice);

    const ctx = Context{};
    std.sort.heap(pair, ranges_slice, ctx, cmp_ranges);

    var prev_from: usize = 0;
    var prev_to: usize = 0;

    for (ranges_slice) |p| {
        if (prev_from == 0) {
            prev_from = p.first;
            prev_to = p.second;
            continue;
        }
        if (prev_to < p.first) {
            result += prev_to - prev_from + 1;
            prev_from = p.first;
            prev_to = p.second;
        } else {
            prev_to = @max(prev_to, p.second);
        }
    }
    result += prev_to - prev_from + 1;

    std.debug.print("{d}\n", .{result});
}

fn cmp_ranges(_: Context, a: pair, b: pair) bool {
    return a.first < b.first;
}

pub const LineIterator = struct {
    reader: std.fs.File.Reader,
    buf: []u8,

    pub fn init(file: std.fs.File, buf: []u8) LineIterator {
        return .{
            .reader = file.reader(buf),
            .buf = buf,
        };
    }

    pub fn next(self: *LineIterator) !?[]const u8 {
        const line = try self.reader.interface.takeDelimiter('\n');
        if (line == null) return null;

        return std.mem.trim(u8, line.?, "\r\n");
    }
};
