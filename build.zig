const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.

fn getCFlags(b: *std.Build, mode: std.builtin.OptimizeMode) []const []const u8 {
    var flags = std.ArrayList([]const u8).init(b.allocator);
    flags.appendSlice(&.{
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wshadow",
        "-Wconversion",
        "-Wsign-conversion",
        "-Wnull-dereference",
        "-Wstrict-prototypes",
        "-Wmissing-prototypes",
        "-Wcast-align",
        "-Wcast-qual",
        "-Wfloat-equal",
        "-Wvla",
        "-fstack-protector-strong",
    }) catch unreachable;

    switch (mode) {
        .Debug => {
            flags.append("-fsanitize=undefined") catch unreachable;
            flags.append("-g") catch unreachable;
        },
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => flags.append("-O2") catch unreachable,
    }

    return flags.toOwnedSlice() catch unreachable;
}

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    const use_custom_libc = b.option(bool, "use_custom_libc", "Use custom libc.zig") orelse false;
    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const c_flags = getCFlags(b, optimize);
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    // b.installArtifact(lib);

    // This creates another `std.Build.Step.Compile`, but this one builds an executable
    // rather than a static library.
    const exe = b.addExecutable(.{
        .name = "threadpool",
        .target = target,
        .optimize = optimize,
    });

    exe.addCSourceFiles(.{
        .files = &.{
            "src/threadpool.c",
        },
        .flags = c_flags,
    });
    exe.addIncludePath(b.path("src"));

    exe.linkSystemLibrary("z");
    exe.linkLibC();
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // for each test binary
    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = &[_][]const u8{
        "tests/test_threadpool.zig",
    };

    if (use_custom_libc) {
        exe.setLibCFile(b.path("ci/libc.zig"));
    }

    const test_step = b.step("test", "Run unit tests");
    for (tests) |test_file| {
        const test_exe = b.addTest(.{
            .target = target,
            .optimize = optimize,
            .test_runner = .{
                .path = b.path("test_runner.zig"),
                .mode = .simple,
            },
            .root_source_file = b.path(test_file),
        });

        test_exe.addCSourceFiles(.{
            .files = &.{"src/threadpool.c"},
            .flags = c_flags,
        });
        test_exe.addIncludePath(b.path("src"));
        test_exe.linkSystemLibrary("z");
        test_exe.linkLibC();

        if (use_custom_libc) {
            test_exe.setLibCFile(b.path("ci/libc.zig"));
        }

        const run_test = b.addRunArtifact(test_exe);

        test_step.dependOn(&run_test.step);
    }
}
