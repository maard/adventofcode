const std = @import("std");
const zig = @import("zig");

const filename = "input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    try part2(file);
}

fn part1(file: std.fs.File) !void {
    var buf: [10]u8 = undefined;
    var reader = file.reader(&buf);
    var count: i32 = 0;
    var current: i32 = 50;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        line[0] = if (line[0] == 'L') '-' else '+';
        const buf2 = std.mem.trim(u8, line, "\r\n");
        const v = try std.fmt.parseInt(i32, buf2, 10);
        current = @rem(current + v, 100);
        if (current == 0) count += 1;
    }
    std.debug.print("{d}\n", .{count});
}
fn part2(file: std.fs.File) !void {
    var buf: [10]u8 = undefined;
    var reader = file.reader(&buf);
    var count: i32 = 0;
    var current: i32 = 50;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        line[0] = if (line[0] == 'L') '-' else '+';
        const buf2 = std.mem.trim(u8, line, "\r\n");
        const v = try std.fmt.parseInt(i32, buf2, 10);
        const new = current + v;
        var increase: i32 = @intCast(@abs(@divTrunc(new, 100)));
        if (current != 0 and new <= 0) increase += 1;
        count += increase;
        current = @rem(@rem(new, 100) + 100, 100);
        // std.debug.print("v={d}, new={d}, increase={d}, current={d}, count={d}\n", .{ v, new, increase, current, count });
    }
    std.debug.print("{d}\n", .{count});
}
