const std = @import("std");
const Reader = std.io.Reader;
const filename = "input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    try part2(file);
}

fn part1(file: std.fs.File) !void {
    var buf: [128]u8 = undefined;

    var result: usize = 0;
    var it = LineIterator.init(file, &buf);

    while (try it.next()) |line| {
        var max1 = line[0];
        var max2 = line[1];
        for (line[2..]) |c| {
            if (max1 < max2) {
                max1 = max2;
                max2 = c;
            } else {
                max2 = @max(max2, c);
            }
        }
        result += (max1 - '0') * 10 + max2 - '0';
    }
    std.debug.print("{d}\n", .{result});
}

fn part2(file: std.fs.File) !void {
    var buf: [128]u8 = undefined;

    var result: usize = 0;
    var it = LineIterator.init(file, &buf);

    while (try it.next()) |line| {
        var max: [12]u8 = undefined;
        @memmove(max[0..12], line[0..12]);
        for (line[12..]) |c| {
            var shrunk = false;
            for (0..11) |i| {
                if (max[i] < max[i + 1]) {
                    @memmove(max[i..11], max[i + 1 .. 12]);
                    shrunk = true;
                    break;
                }
            }
            max[11] = if (shrunk) c else @max(max[11], c);
        }
        var line_max: usize = 0;
        for (0..12) |i| {
            line_max = line_max * 10 + max[i] - '0';
        }
        result += line_max;
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
