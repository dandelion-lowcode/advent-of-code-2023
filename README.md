# 🎄 Advent of Code 2023

> [Advent of Code](https://adventofcode.com) is an Advent calendar of small programming puzzles for a variety of skill sets and skill levels that can be solved in any programming language you like. People use them as interview prep, company training, university coursework, practice problems, a speed contest, or to challenge each other.

This year, I'm trying [Zig](https://ziglang.org/), "a general-purpose programming language and toolchain for maintaining robust, optimal and reusable software".

Zig is basically C with better ergonomics regarding loops, optionals, metaprogramming, memory management, and more much stuff. For Advent of Code, it is slightly cumbersome because you must handle memory manually, which is not super relevant in this type of problems. Still, it's an interesting exercise being conscious of [where are the bytes](https://ziglang.org/documentation/master/#Where-are-the-bytes) at all times.

## Usage

[Install Zig](https://ziglang.org/download/) and run each file separately:

```bash
zig run dayXX.zig
```

## Tests

```bash
zig test dayXX.zig
```

## Comments

Some days, I learn something new about the language -- which is the ultimate goal!

- Day01. Getting the gist of the language in general. Learning about `std.mem.tokenize`, `std.mem.replace`, allocators, and `dupe`.
- Day02. `std.fmt.parseInt`, `std.mem.eql`.
- Day03. Matrices and handling type coercion.
- Day04. `std.ArrayList`, `std.AutoHashMap`.
- Day07. enums.
- Day08. `.*`.
