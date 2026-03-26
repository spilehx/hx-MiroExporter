package miroexporter.exporter;

import haxe.ds.List;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Reader;
import sys.io.File;

class RtbArchiveExtractor {
    private var directoryPreparer:DirectoryPreparer;

    public function new(directoryPreparer:DirectoryPreparer) {
        this.directoryPreparer = directoryPreparer;
    }

    public function extractArchiveEntriesToDirectory(rtbFilePath:String, targetDirectoryPath:String):Void {
        var archiveInput:sys.io.FileInput;
        var archiveEntries:List<Entry>;

        archiveInput = File.read(rtbFilePath, true);
        archiveEntries = Reader.readZip(archiveInput);
        archiveInput.close();

        for (archiveEntry in archiveEntries) {
            extractArchiveEntryToDirectory(archiveEntry, targetDirectoryPath);
        }
    }

    private function extractArchiveEntryToDirectory(archiveEntry:Entry, targetDirectoryPath:String):Void {
        var archiveEntryOutputPath:String;

        archiveEntryOutputPath = Path.join([targetDirectoryPath, archiveEntry.fileName]);

        if (isDirectoryEntry(archiveEntry.fileName)) {
            directoryPreparer.ensureDirectoryExists(archiveEntryOutputPath);
            return;
        }

        Reader.unzip(archiveEntry);
        ensureParentDirectoryExists(archiveEntryOutputPath);
        File.saveBytes(archiveEntryOutputPath, archiveEntry.data);
    }

    private function ensureParentDirectoryExists(filePath:String):Void {
        var parentDirectoryPath:String;

        parentDirectoryPath = Path.directory(filePath);

        if (parentDirectoryPath == null || parentDirectoryPath == "") {
            return;
        }

        directoryPreparer.ensureDirectoryExists(parentDirectoryPath);
    }

    private function isDirectoryEntry(archiveEntryFileName:String):Bool {
        return StringTools.endsWith(archiveEntryFileName, "/") || StringTools.endsWith(archiveEntryFileName, "\\");
    }
}
