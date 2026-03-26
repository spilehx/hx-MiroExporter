# MiroExporter

`MiroExporter` is a command line tool for working with Miro `.rtb` backup files.

After downloading a backup of your miro board, you can use this tool to extract the `.rtb` file and view its content.
Useful if you want to make sure you keep all the resources that are in the miro board.

The project extracts `.rtb` archives, preserves the raw exported files, and builds a structured offline output that lets a user inspect as much of the board data as possible without using the Miro platform.






## Quick install

> [!NOTE]
> This has only been tested on Ubuntu/debian systems.

To install the latest version, open a terminal and run this command.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/spilehx/hx-MiroExporter/refs/heads/main/tools/install.sh)"
```

This will, run a script that will:
 - Download the latest release binary with `curl`, 
 - Make it executable 
 - Runs `./MiroExporter install`
 - and removes the temporary download directory.

You will then have `MiroExporter` on your command line and a link in your launcher to start in interactive gui mode.  


> [!IMPORTANT]
> Needless to say, putting random commands in your terminal is risky, so have a look at [the install script](https://github.com/spilehx/hx-MiroExporter/blob/main/tools/install.sh) if you want to check


## Commands

```bash
MiroExporter extract <path-to-file.rtb>
MiroExporter interactive
MiroExporter install
MiroExporter version
```


## What it does

- extracts `.rtb` files
- stores the raw extracted files
- exports supported embedded resources such as images, SVGs, and videos
- generates structured metadata files
- generates an offline summary HTML page
- provides an interactive local web UI for uploading and browsing exports


## Current limitation

Miro board layout and canvas object reconstruction are limited because the main `canvas.json` payload inside `.rtb` exports appears to be opaque or encrypted, so this project focuses on the metadata and resource files that can be reliably accessed.

