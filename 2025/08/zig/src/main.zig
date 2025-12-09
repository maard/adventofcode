const std = @import("std");
const assert = std.debug.assert;
const uninit_gr = std.math.maxInt(usize);

const filename = "input";
const max_circuits = 1000;

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part(file, 1);
    try part(file, 2);
}

const Point3D = struct {
    x: u32,
    y: u32,
    z: u32,
    gr: usize = uninit_gr,

    fn distance(self: *Point3D, p: *Point3D) f32 {
        const x1 = @as(f32, @floatFromInt(self.x));
        const y1 = @as(f32, @floatFromInt(self.y));
        const z1 = @as(f32, @floatFromInt(self.z));
        const x2 = @as(f32, @floatFromInt(p.x));
        const y2 = @as(f32, @floatFromInt(p.y));
        const z2 = @as(f32, @floatFromInt(p.z));
        return std.math.hypot(std.math.hypot(x1 - x2, y1 - y2), z1 - z2);
    }
};

const Distance = struct {
    dist: f32,
    p0: usize,
    p1: usize,
};

const inner = struct {
    buf: []*Point3D,
    len: usize,

    fn init(allocator: std.mem.Allocator, max_len: usize) !inner {
        return inner{
            .buf = try allocator.alloc(*Point3D, max_len),
            .len = 0,
        };
    }

    fn append(self: *inner, p: *Point3D) !void {
        if (self.len >= self.buf.len) return error.OutOfMemory;
        self.buf[self.len] = p;
        self.len += 1;
    }

    fn slice(self: *inner) []*Point3D {
        return self.buf[0..self.len];
    }

    fn merge(self: *inner, i: *inner) !void {
        if (self.len + i.len >= self.buf.len) return error.OutOfMemory;
        @memmove(self.buf[self.len .. self.len + i.len], i.slice());
        self.len += i.len;
    }

    fn empty(self: *inner) void {
        self.len = 0;
    }
};

fn part(file: std.fs.File, part_n: i32) !void {
    const allocator = std.heap.page_allocator;

    var points = try load_points(allocator, file);
    defer allocator.free(points);

    const len = points.len;
    const storage_len = len * (len - 1) / 2;
    var distances_a = try std.ArrayList(Distance).initCapacity(allocator, storage_len); // half the square
    _ = distances_a.addManyAtAssumeCapacity(0, storage_len);
    var distances = try distances_a.toOwnedSlice(allocator);
    defer allocator.free(distances);

    var n: usize = 0;
    for (0..len) |i| {
        for (i + 1..len) |j| {
            const dist = points[i].distance(&points[j]);
            const d = Distance{
                .dist = dist,
                .p0 = i,
                .p1 = j,
            };
            distances[n] = d;
            n += 1;
        }
    }
    assert(n == storage_len);

    const ctx = Context{};
    std.sort.heap(Distance, distances, ctx, less_than_distance);

    var groups = try allocator.alloc(inner, len);
    defer allocator.free(groups);

    for (0..len) |i| {
        groups[i] = try inner.init(allocator, len);
    }

    var result2: usize = 0;
    var max_gr: usize = 0;
    for (distances, 0..) |d, i| {
        if (part_n == 1 and i >= max_circuits) break;
        // std.debug.print("{any} {any} {any}\n", .{ d, points[d.p0], points[d.p1] });
        if (points[d.p0].gr == uninit_gr and points[d.p1].gr == uninit_gr) {
            points[d.p0].gr = max_gr;
            points[d.p1].gr = max_gr;
            try groups[max_gr].append(&points[d.p0]);
            try groups[max_gr].append(&points[d.p1]);
            std.debug.print("create group {d} with points {any} and {any}\n", .{ max_gr, points[d.p0], points[d.p1] });
            max_gr += 1;
        } else if (points[d.p0].gr == uninit_gr) {
            points[d.p0].gr = points[d.p1].gr;
            try groups[points[d.p1].gr].append(&points[d.p0]);
            std.debug.print("group {d} << {any}\n", .{ points[d.p1].gr, points[d.p0] });
        } else if (points[d.p1].gr == uninit_gr) {
            points[d.p1].gr = points[d.p0].gr;
            try groups[points[d.p0].gr].append(&points[d.p1]);
            std.debug.print("group {d} << {any}\n", .{ points[d.p0].gr, points[d.p1] });
        } else if (points[d.p0].gr != points[d.p1].gr) {
            const min = @min(points[d.p0].gr, points[d.p1].gr);
            const max = @max(points[d.p0].gr, points[d.p1].gr);

            std.debug.print("merge group {d} << {d}: {any} << {any}\n", .{
                min,
                max,
                groups[min].slice(),
                groups[max].slice(),
            });

            for (groups[max].slice()) |p| {
                p.gr = min;
            }
            try groups[min].merge(&groups[max]);
            groups[max].empty();
        }

        if (part_n == 2 and groups[0].len == len) { // part 2
            result2 = points[d.p0].x * points[d.p1].x;
            break;
        }
    }

    std.sort.heap(inner, groups, ctx, inner_len_cmp);

    // std.debug.print("{d}\n", .{groups[0].len});
    // std.debug.print("{d}\n", .{groups[1].len});
    // std.debug.print("{d}\n", .{groups[2].len});
    const result1 = groups[0].len * groups[1].len * groups[2].len;

    std.debug.print("part 1: {d}\n", .{result1});
    std.debug.print("part 2: {d}\n", .{result2});
}

const Context = struct {};

fn less_than_distance(_: Context, l: Distance, r: Distance) bool {
    return l.dist < r.dist;
}

fn inner_len_cmp(_: Context, l: inner, r: inner) bool {
    return l.len > r.len; // reverse
}

fn load_points(allocator: std.mem.Allocator, file: std.fs.File) ![]Point3D {
    var buf: [30]u8 = undefined;
    var it = LineIterator.init(file, &buf);
    var points = std.ArrayList(Point3D).empty;

    while (try it.next()) |line| {
        var itp = std.mem.splitScalar(u8, line, ',');
        const x = itp.next().?;
        const y = itp.next().?;
        const z = itp.next().?;
        const p = Point3D{
            .x = try std.fmt.parseUnsigned(u32, x, 10),
            .y = try std.fmt.parseUnsigned(u32, y, 10),
            .z = try std.fmt.parseUnsigned(u32, z, 10),
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
