const std = @import("std");
const c = @cImport(
    @cInclude("libpq-fe.h"),
);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const connection_string = "postgresql://postgres:postgres@localhost:54322/postgres";

    var parse_info_response = try allocator.alloc(u8, 1024);
    defer allocator.free(parse_info_response);

    var c_buf: [*c]u8 = @ptrCast(
        &parse_info_response.ptr,
    );

    const params = c.PQconninfoParse(
        connection_string,
        &c_buf,
    ) orelse return error.ConnectionParsingError;
    _ = params;

    // var connection_option: *c.PQconninfoOption = null;
    // var i: u8 = 2;
    // while (params[i].keyword != null) : (i += 1) {
    //     std.debug.print("{s}:{s}\n", .{
    //         params[i].keyword,
    //         params[i].val orelse @as([*c]const u8, @ptrCast("")),
    //     });
    // }

    const connection = c.PQconnectdb(connection_string);
    defer c.PQfinish(connection);

    switch (c.PQstatus(connection)) {
        c.CONNECTION_OK => {
            std.debug.print("Connection ok\n", .{});
        },
        c.CONNECTION_BAD => {
            std.debug.print("Bad connection\n", .{});
            return error.DbConnectionError;
        },
        c.CONNECTION_STARTED => {
            std.debug.print("Connecting\n", .{});
        },
        c.CONNECTION_MADE => {
            std.debug.print("Connected to server\n", .{});
        },
        else => {
            std.debug.print("Some other code {d}\n", .{
                c.PQstatus(connection),
            });
        },
    }

    const result = c.PQexec(connection,
        \\ SELECT pg_catalog.set_config
        \\ ('search_path', '', false);
        \\ SELECT 'FOO' as FOO;
    ) orelse return error.ErrorExecutingQuery;

    switch (c.PQresultStatus(result)) {
        c.PGRES_FATAL_ERROR => |r| {
            std.debug.print("fatal error: {d}\n{s}", .{
                r,
                c.PQerrorMessage(connection),
            });
        },
        else => |r| {
            std.debug.print("{s}\n", .{c.PQgetvalue(
                result,
                0,
                0,
            )});
            std.debug.print("result: {d}", .{r});
        },
    }
    defer c.PQclear(result);
}
