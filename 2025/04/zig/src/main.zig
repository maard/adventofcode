const std = @import("std");
const zig = @import("zig");

const filename = "input";
const max_file_len = 20_000;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd().readFileAlloc(allocator, filename, max_file_len);
    defer allocator.free(contents);

    var grid = try Grid.initFromLines(allocator, contents);
    defer grid.deinit();

    // try part1(&grid);
    try part2(&grid);
}

fn part1(grid: *Grid) !void {
    var result: usize = 0;

    for (0..grid.height) |y| {
        for (0..grid.width) |x| {
            if (grid.at(x, y) == '@' and grid.busy_neighbors(x, y) < 4) {
                grid.set(x, y, 'x');
                result += 1;
            }
        }
    }
    grid.commit();
    grid.print();
    std.debug.print("{d}\n", .{result});
}

fn part2(grid: *Grid) !void {
    var result: usize = 0;

    while (true) {
        var removed: usize = 0;
        for (0..grid.height) |y| {
            for (0..grid.width) |x| {
                if (grid.at(x, y) == '@' and grid.busy_neighbors(x, y) < 4) {
                    grid.set(x, y, '.');
                    removed += 1;
                }
            }
        }
        result += removed;
        grid.commit();
        if (removed == 0) break;
    }
    grid.print();
    std.debug.print("{d}\n", .{result});
}

const Grid = struct {
    allocator: std.mem.Allocator,
    width: usize = 0,
    height: usize = 0,
    data: []u8 = undefined,
    new_data: []u8 = undefined,

    pub fn initFromLines(allocator: std.mem.Allocator, contents: []const u8) !Grid {
        var it = std.mem.splitScalar(u8, contents, '\n');
        var self = Grid{
            .allocator = allocator,
            .data = try allocator.alloc(u8, contents.len),
            .new_data = try allocator.alloc(u8, contents.len),
        };

        while (it.next()) |line| {
            if (line.len == 0) break;
            if (self.width == 0) self.width = line.len;
            // std.debug.print("{d}: {s}\n", .{ self.height, line });

            @memmove(self.data[self.height * self.width .. (self.height + 1) * self.width], line);
            self.height += 1;
        }
        @memmove(self.new_data, self.data);
        return self;
    }

    pub fn deinit(self: *Grid) void {
        self.allocator.free(self.data);
        self.allocator.free(self.new_data);
    }

    pub fn at(self: *Grid, x: usize, y: usize) u8 {
        return self.data[y * self.height + x];
    }

    pub fn set(self: *Grid, x: usize, y: usize, v: u8) void {
        self.new_data[y * self.height + x] = v;
    }

    pub fn commit(self: *Grid) void {
        @memmove(self.data, self.new_data);
    }

    // 7 0 1
    // 6 . 2
    // 5 4 3
    pub fn valid_directions(self: *Grid, x: usize, y: usize) u8 {
        var mask: u8 = 0xff;
        if (x == 0) {
            mask &= 0x1f;
        } else if (x == self.width - 1) {
            mask &= 0xf1;
        }
        if (y == 0) {
            mask &= 0x7c;
        } else if (y == self.height - 1) {
            mask &= 0xc7;
        }
        return mask;
    }

    pub fn busy_neighbors(self: *Grid, x: usize, y: usize) u8 {
        var result: u8 = 0;
        const mask = self.valid_directions(x, y);
        if (mask & 1 != 0 and self.at(x, y - 1) == '@') result += 1;
        if (mask & 2 != 0 and self.at(x + 1, y - 1) == '@') result += 1;
        if (mask & 4 != 0 and self.at(x + 1, y) == '@') result += 1;
        if (mask & 8 != 0 and self.at(x + 1, y + 1) == '@') result += 1;
        if (mask & 16 != 0 and self.at(x, y + 1) == '@') result += 1;
        if (mask & 32 != 0 and self.at(x - 1, y + 1) == '@') result += 1;
        if (mask & 64 != 0 and self.at(x - 1, y) == '@') result += 1;
        if (mask & 128 != 0 and self.at(x - 1, y - 1) == '@') result += 1;
        return result;
    }

    pub fn print(self: *Grid) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                std.debug.print("{c}", .{self.at(x, y)});
            }
            std.debug.print("\n", .{});
        }
    }
};
