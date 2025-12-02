const std = @import("std");
const zig = @import("zig");

const filename = "input";

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd().readFileAlloc(allocator, filename, 10_000);
    defer allocator.free(contents);

    try part1(contents);
    try part2(contents);
}

fn part1(data: []u8) !void {
    var it = std.mem.splitScalar(u8, data, ',');
    var buf: [20]u8 = undefined;
    var result: usize = 0;

    while (it.next()) |pair| {
        var it2 = std.mem.splitScalar(u8, pair, '-');

        const lower = it2.next().?;
        const upper = it2.next().?;

        const a = @as(usize, @intCast(try std.fmt.parseInt(i64, lower, 10)));
        const b = @as(usize, @intCast(try std.fmt.parseInt(i64, upper, 10)));
        l: for (a..b + 1) |n| {
            var writer = std.io.Writer.fixed(&buf);
            try writer.print("{d}", .{n});
            const len = writer.buffered().len;
            if (len % 2 != 0) continue;
            const len2 = len / 2;
            // try std.fmt.bufPrint(buf, "{d}", .{n});
            for (0..len2) |i| {
                if (buf[i] != buf[len2 + i]) continue :l;
            }
            result += n;
        }
    }

    std.debug.print("{d}\n", .{result});
}

fn part2(data: []u8) !void {
    var it = std.mem.splitScalar(u8, data, ',');
    var buf: [20]u8 = undefined;
    var result: usize = 0;

    while (it.next()) |pair| {
        var it2 = std.mem.splitScalar(u8, pair, '-');

        const lower = it2.next().?;
        const upper = it2.next().?;

        const a = @as(usize, @intCast(try std.fmt.parseInt(i64, lower, 10)));
        const b = @as(usize, @intCast(try std.fmt.parseInt(i64, upper, 10)));
        for (a..b + 1) |n| {
            var writer = std.io.Writer.fixed(&buf);
            try writer.print("{d}", .{n});
            const s = writer.buffered();
            const len = s.len;

            for (1..(len / 2) + 1) |sub_len| {
                if (len % sub_len != 0) continue;
                const repeats = len / sub_len;
                const first = s[0..sub_len];
                var ok = true;

                for (1..repeats) |i| {
                    if (!std.mem.eql(u8, first, s[i * sub_len .. (i + 1) * sub_len])) {
                        ok = false;
                        break;
                    }
                }
                if (ok) {
                    result += n;
                    break;
                }
            }
        }
    }

    std.debug.print("{d}\n", .{result});
}
