# build_aseprite_on_mac.sh

Build. Aseprite. On. Mac. Whatelsecoulditbe.

### Seriously, what does it do?

Run that `./build_aseprite_on_mac.sh` and it puts `Aseprite.app` into your `/Applications`.

The script should work on both mac of Apple Silicon and Intel, but I only have tested on Apple Silicon.

### Why don't you make a homebrew formula?

Because I am too lazy to learn ruby? :-p

Really, that is one of reasons. And it seems like a homebrew formula has to support mac(both Apple Silicon and Intel) and linux. That's just too much work for me, and iirc, usually a decent linux distribution has prebuilt packages for Aseprite, for example Arch has it on AUR.

So simply writting a build script seems good enough imo.

### I have this huge bug, I hate you!

Calm down, my script does nothing more than [what official doc instructs to do](https://github.com/aseprite/aseprite/blob/main/INSTALL.md). If you are absolutely sure the bug is about build process, do let me know in github issue.
