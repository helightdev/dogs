<h1 align="left">
    DOGs
    <a href="https://discord.gg/6HKuGSzYKJ">
        <img src="https://img.shields.io/discord/1060355106522017924?label=discord" alt="discord">
    </a>
    <a href="https://helightdev.gitbook.io/darwin">
        <img src="https://img.shields.io/badge/docs-gitbook.com-346ddb.svg" alt="gitbook">
    </a>
    <a href="https://github.com/invertase/melos">
        <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg" alt="melos">
    </a>
</h1>

DOGs, short for Dart Object Graphs, is a universal serialization library for
dart making strong use of code generation to reduce boilerplate massively.
Dogs can be easily extended to support a wide array of encodings and comes
with json support out of the box.

## Silent Code Generation
A neat point about dogs 'darwin like' **non-intrusive** code generation is,
that it has almost **zero boilerplate** and generally **doesn't require
importing or referencing generated source code**, except for just a few
cases. This allows you to keep on working on your code, without having to
wait for the build runner to create your required files for every new service
you create and plan to use. This also **minimizes conflicts** with other
external generators and helps to prevent unexpected build runner crashes.