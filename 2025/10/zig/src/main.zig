const std = @import("std");
const print = std.debug.print;

const filename = "testinput";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try part1(file);
    // try part(file, 2);
}

const Machine = struct {
    allocator: std.mem.Allocator,
    lamps: u32,
    buttons: std.ArrayList(u16),
    joltage: std.ArrayList(u16),

    fn init(allocator: std.mem.Allocator, line: []const u8) !*Machine {
        var m = try allocator.create(Machine);
        m.allocator = allocator;
        m.lamps = 0;
        m.buttons = std.ArrayList(u16).empty;
        m.joltage = std.ArrayList(u16).empty;
        var it = std.mem.splitScalar(u8, line, ' ');
        while (it.next()) |part| {
            if (part[0] == '[') {
                var i: u5 = 0;
                for (part[1 .. part.len - 1]) |c| {
                    m.lamps |= (@as(u32, @intFromBool(c != '.'))) << i;
                    i += 1;
                }
                //
            } else if (part[0] == '(') {
                var it2 = std.mem.splitScalar(u8, part[1 .. part.len - 1], ',');
                var mask: u16 = 0;
                while (it2.next()) |num_s| {
                    const n = try std.fmt.parseUnsigned(u16, num_s, 10);
                    mask |= @as(u16, 1) << @truncate(n);
                }
                try m.buttons.append(allocator, mask);
            } else {
                var it2 = std.mem.splitScalar(u8, part[1 .. part.len - 1], ',');
                while (it2.next()) |num_s| {
                    const n = try std.fmt.parseUnsigned(u16, num_s, 10);
                    try m.joltage.append(allocator, n);
                }
            }
        }
        return m;
    }

    fn deinit(self: *Machine) void {
        self.buttons.deinit(self.allocator);
        self.joltage.deinit(self.allocator);
    }

    fn print(self: *Machine) void {
        std.debug.print("*** lamps: {b:13} {d}\n", .{ self.lamps, self.lamps });
        std.debug.print("buttons: {d}\n", .{self.buttons.items.len});
        for (0..self.buttons.items.len) |i| {
            std.debug.print("\t{b:13} {d}\n", .{ self.buttons.items[i], self.buttons.items[i] });
        }
        std.debug.print("joltage: {any}\n", .{self.joltage.items});
    }
};

fn part1(file: std.fs.File) !void {
    const allocator = std.heap.page_allocator;

    var result1: usize = 0;
    var result2: usize = 0;
    var buf: [250]u8 = undefined;
    var it = LineIterator.init(file, &buf);

    while (try it.next()) |line| {
        const m = try Machine.init(allocator, line);
        defer m.deinit();
        m.print();
        const len1 = bfs_xor(m);
        const len2 = bfs_inc(m);

        std.debug.print("len1 = {d}, len2 = {d}\n", .{ len1, len2 });

        result1 += len1;
        result2 += len2;
    }

    std.debug.print("buttons: {d}\n", .{result1});
    std.debug.print("joltage: {d}\n", .{result2});
}

const MAX_SIZE = 0xffff;
const NOT_VISITED = 0xff;

fn bfs_xor(m: *const Machine) usize {
    var path = [_]u16{NOT_VISITED} ** MAX_SIZE;
    var queue = [_]u16{0} ** MAX_SIZE;

    var head: usize = 0;
    var tail: usize = 1;
    path[0] = 0;

    while (head < tail) {
        const v = queue[head];
        head += 1;

        if (v == m.lamps) {
            break;
        }

        for (m.buttons.items) |mask| {
            const next = v ^ mask;

            if (path[next] == NOT_VISITED) {
                path[next] = v;
                queue[tail] = next;
                tail += 1;
            }
        }
    }
    // std.debug.print("matched, tracing the path\n", .{});

    // trace back the path
    var length: usize = 0;
    var v = m.lamps;
    while (v != 0) {
        v = path[v];
        length += 1;
    }
    return length;
}

fn bfs_inc(m: *const Machine) usize {
    var path = [_]u16{NOT_VISITED} ** MAX_SIZE;
    var queue = [_]u16{0} ** MAX_SIZE;

    var target: u256 = 0;
    var head: usize = 0;
    var tail: usize = 1;
    path[0] = 0;

    for (m.joltage.items, 0..) |v, i| {
        const mask: u256 = @as(u256, v) << (@as(u8, @intCast(i)) * 16);
        target |= mask;
    }

    while (head < tail) {
        const v = queue[head];
        head += 1;

        if (v == m.lamps) {
            break;
        }

        for (m.buttons.items) |mask| {
            const next = v ^ mask;

            if (path[next] == NOT_VISITED) {
                path[next] = v;
                queue[tail] = next;
                tail += 1;
            }
        }
    }
    // std.debug.print("matched, tracing the path\n", .{});

    // trace back the path
    var length: usize = 0;
    var v = m.lamps;
    while (v != 0) {
        v = path[v];
        length += 1;
    }
    return length;
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
