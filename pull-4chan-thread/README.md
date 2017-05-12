# pull-4chan-thread

## What

This utility has three components:
* `pull-4chan-thread.pl` - Script adapted from fragments of [term-chan](https://github.com/eon8ight/term-chan) that download all images in a given thread.
* `autopull.sh` - Reads a list of threads (see example.txt) and calls `pull-4chan-thread.pl` on each of them. Also does cleanup, such as automatically removing any dead threads, removing duplicates, etc.
* A .txt file containing exactly one 4chan thread link per line, for reading by `autopull.sh`

## Why

I lost my /c/ folder a while ago and needed a quick way to re-download as much as possible.

## When

I set up the autopull script to run as an hourly cronjob.

