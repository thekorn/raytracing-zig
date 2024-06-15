# Raytracing in one Weekend in Zig

Read the book at:
https://raytracing.github.io/books/RayTracingInOneWeekend.html

## requirements

- Zig >= 0.13.0

## render the scene

```bash
$ zig build run && open out.ppm
```

## unit testing

```bash
$ zig build test --summary all
```

## convert the result to png

```bash
$ docker run -v $(pwd):/imgs dpokidov/imagemagick /imgs/out.ppm /imgs/current.png
```

## build options

```bash
$ zig build -Doptimize=ReleaseFast
$ zig build -Doptimize=ReleaseSmall
```

## Benchmarking

```bash
$ hyperfine -N --warmup 3 './zig-out/bin/raytracing-zig'

Benchmark 1: ./zig-out/bin/raytracing-zig
  Time (mean ± σ):     151.5 ms ±   3.4 ms    [User: 147.4 ms, System: 1.9 ms]
  Range (min … max):   149.4 ms … 163.4 ms    20 runs
```

## Current rendering

![curret rendering](./current.png)

## References

<<<<<<< HEAD
 * https://github.com/ryoppippi/Ray-Tracing-in-One-Weekend.zig
 * https://github.com/jpaquim/raytracing-zig
=======
- https://github.com/ryoppippi/Ray-Tracing-in-One-Weekend.zig
- https://github.com/jpaquim/raytracing-zig
>>>>>>> 37aaba85ba81eb541b0da8626a0e963d6a1f2f3f
