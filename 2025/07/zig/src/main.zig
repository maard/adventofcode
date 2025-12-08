const std = @import("std");
const Grid = @import("grid.zig").Grid;

const filename = "input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    try part2();
}

fn part1(file: std.fs.File) !void {
    var buf: [150]u8 = undefined;

    var result: usize = 0;
    var it = LineIterator.init(file, &buf);
    const allocator = std.heap.page_allocator;

    const line0 = (try it.next()).?;

    var last_line = try allocator.alloc(u8, line0.len);
    defer allocator.free(last_line);
    @memmove(last_line, line0);

    while (try it.next()) |line| {
        for (line, 0..) |c, i| {
            if (c == '^' and (last_line[i] == '|' or last_line[i] == 'S')) {
                last_line[i] = '.';
                last_line[i - 1] = '|';
                last_line[i + 1] = '|';
                result += 1;
            }
        }
    }

    std.debug.print("{d}\n", .{result});
}

fn part2() !void {
    const allocator = std.heap.page_allocator;
    var grid = try Grid.init_from_file(allocator, filename, 21_000);
    defer grid.deinit();

    const i = std.mem.indexOf(u8, grid.row(0), "S").?;

    var sums = try allocator.alloc(usize, grid.width);
    defer allocator.free(sums);
    @memset(sums, 0);

    sums[i] = 1;
    for (1..grid.height) |y| {
        for (0..grid.width) |x| {
            if (grid.at(x, y) == '^') {
                sums[x - 1] += sums[x];
                sums[x + 1] += sums[x];
                sums[x] = 0;
            }
        }
    }

    var result: usize = 0;
    for (sums) |n| {
        result += n;
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
