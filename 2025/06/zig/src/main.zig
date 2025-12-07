const std = @import("std");
const zig = @import("zig");

const filename = "input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    try part2();
}

fn part1(file: std.fs.File) !void {
    var buf: [4000]u8 = undefined;

    var result: usize = 0;
    var it = LineIterator.init(file, &buf);
    const allocator = std.heap.page_allocator;

    var nums = std.ArrayList(usize).empty;
    defer nums.deinit(allocator);

    var ops = std.ArrayList(u8).empty;
    defer ops.deinit(allocator);

    var per_line: usize = 0;
    while (try it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " ");

        const is_ops = trimmed.len > 0 and (trimmed[0] == '+' or trimmed[0] == '*');
        if (is_ops) {
            const num_lines = @divExact(nums.items.len, per_line);

            var it2 = std.mem.tokenizeSequence(u8, trimmed, " ");
            var i: usize = 0;
            while (it2.next()) |op| {
                const is_add = op[0] == '+';
                var column_result: usize = 0;
                for (0..num_lines) |line_n| {
                    const n = nums.items[line_n * per_line + i];
                    if (is_add) {
                        column_result += n;
                    } else {
                        column_result = if (line_n == 0) n else column_result * n;
                    }
                }
                result += column_result;
                i += 1;
            }

            break;
        } else {
            var it2 = std.mem.tokenizeSequence(u8, trimmed, " ");
            while (it2.next()) |num_s| {
                const n = try std.fmt.parseUnsigned(usize, num_s, 10);
                try nums.append(allocator, n);
            }

            if (per_line == 0) per_line = nums.items.len;
        }
    }
    std.debug.print("{d}\n", .{result});
}

fn part2() !void {
    const allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd().readFileAlloc(allocator, filename, 20_000);
    defer allocator.free(contents);

    var result: usize = 0;

    var line_len_it = std.mem.tokenizeAny(u8, contents, "\r\n");
    const line0 = line_len_it.next().?;
    const line_len = line0.len;

    var line_with_ending_len = line_len;
    while (line_with_ending_len < contents.len and (contents[line_with_ending_len] == '\n' or contents[line_with_ending_len] == '\r')) line_with_ending_len += 1;

    const num_lines = @as(usize, @divFloor(contents.len, line_len));

    var nums = try allocator.alloc(usize, num_lines - 1);
    defer allocator.free(nums);

    var i: usize = line_len;
    var op: u8 = ' ';
    var num: usize = 0;
    var num_len: usize = 0;
    while (i > 0) {
        i -= 1;
        var done_col = true;
        for (0..num_lines) |line_n| {
            const c = contents[line_n * line_with_ending_len + i];
            if (line_n == num_lines - 1 and !done_col) {
                nums[num_len] = num;
                num_len += 1;
                num = 0;
                if (c == '+') {
                    op = '+';
                } else if (c == '*') {
                    op = '*';
                }
            } else if (c != ' ') {
                done_col = false;
                num = num * 10 + c - '0';
            }
        }
        if (done_col or i == 0) {
            var col_result = nums[0];
            for (1..num_len) |j| {
                if (op == '+') {
                    col_result += nums[j];
                } else {
                    col_result *= nums[j];
                }
            }
            num_len = 0;
            result += col_result;
        }
    }

    std.debug.print("{d}\n", .{result});
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
