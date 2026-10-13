# Code Generation Examples

This repository contains an example of code generation running inside an AI agent, which I presented at Berlin.rb on October 13th, 2026. Instead of hand-writing parsers for every input format, the agent writes the code it needs to handle new kinds of input on the fly and then runs it.

The post [Let Your Software Write Its Own Code](http://cymerys.com/w/let-your-software-write-its-own-code) describes the concept in more detail.

## Structure

- `csv_import/` - a CSV importer that uses a code-generating AI agent to accept a variety of inputs.
- `data/` - simple data files you can use as inputs for the importer.

## Security warning

This is only a prototype. It doesn't use a proper sandbox: the generated code runs in a subprocess, which is **not secure**. Don't run it against untrusted input or in any environment where that matters.
