const std = @import("std");

const c = @cImport({
    @cInclude("threadpool.h");
});

test "test add adds successfully" {
    // const result: c_int = c.add(5, 2);
    const result: i32 = c.add(5, 2);

    try std.testing.expectEqual(result, 5 + 2);
}
