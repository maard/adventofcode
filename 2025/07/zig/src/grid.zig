const std = @import("std");

// load a file as a rectangular grid/matrix in O(1) allocations.
// line endings are removed, so the representation is compact.
// all lines must be of the same length.
pub const Grid = struct {
    allocator: std.mem.Allocator,
    contents: ?[]u8 = null,
    width: usize = 0,
    height: usize = 0,
    data: []u8 = undefined,
    new_data: []u8 = undefined,

    pub fn init_from_file(allocator: std.mem.Allocator, filename: []const u8, max_file_len: usize) !Grid {
        const contents = try std.fs.cwd().readFileAlloc(allocator, filename, max_file_len);
        var self = try init_from_contents(allocator, contents);
        self.contents = contents;
        return self;
    }

    pub fn init_from_contents(allocator: std.mem.Allocator, contents: []const u8) !Grid {
        var it = std.mem.tokenizeAny(u8, contents, "\n\r");
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
        if (self.contents != null) self.allocator.free(self.contents.?);
    }

    pub fn at(self: *Grid, x: usize, y: usize) u8 {
        return self.data[y * self.width + x];
    }

    pub fn row(self: *Grid, y: usize) []const u8 {
        return self.data[y * self.width .. (y + 1) * self.width];
    }

    pub fn set(self: *Grid, x: usize, y: usize, v: u8) void {
        self.data[y * self.width + x] = v;
    }

    pub fn set_new(self: *Grid, x: usize, y: usize, v: u8) void {
        self.new_data[y * self.width + x] = v;
    }

    pub fn commit(self: *Grid) void {
        @memmove(self.data, self.new_data);
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
