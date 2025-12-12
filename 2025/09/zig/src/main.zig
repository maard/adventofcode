const std = @import("std");
const print = std.debug.print;

const filename = "input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    // try part(file, 2);
}

const Point = struct {
    x: i32,
    y: i32,
};

fn part1(file: std.fs.File) !void {
    const allocator = std.heap.page_allocator;

    const points = try load_points(allocator, file);
    defer allocator.free(points);

    const len = points.len;
    const storage_len = len * (len - 1) / 2;
    var distances_a = try std.ArrayList(u64).initCapacity(allocator, storage_len); // half the square
    _ = distances_a.addManyAtAssumeCapacity(0, storage_len);
    var distances = try distances_a.toOwnedSlice(allocator);
    defer allocator.free(distances);

    var n: usize = 0;
    for (0..len) |i| {
        const p0 = points[i];
        for (i + 1..len) |j| {
            const p1 = points[j];
            const area = @as(u64, @abs(p0.x - p1.x) + 1) * @as(u64, @abs(p0.y - p1.y) + 1);
            distances[n] = area;
            n += 1;
        }
    }

    const ctx = Context{};
    std.sort.heap(u64, distances, ctx, cmp_u64);

    const result = distances[0];

    std.debug.print("{d}\n", .{result});
}

const Context = struct {};

fn cmp_u64(_: Context, l: u64, r: u64) bool {
    return l > r;
}

fn load_points(allocator: std.mem.Allocator, file: std.fs.File) ![]Point {
    var buf: [30]u8 = undefined;
    var it = LineIterator.init(file, &buf);
    var points = std.ArrayList(Point).empty;

    while (try it.next()) |line| {
        var itp = std.mem.splitScalar(u8, line, ',');
        const x = itp.next().?;
        const y = itp.next().?;
        const p = Point{
            .x = try std.fmt.parseUnsigned(i32, x, 10),
            .y = try std.fmt.parseUnsigned(i32, y, 10),
        };
        try points.append(allocator, p);
    }
    return points.toOwnedSlice(allocator);
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
