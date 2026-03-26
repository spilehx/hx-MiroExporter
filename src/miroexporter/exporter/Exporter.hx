package miroexporter.exporter;

import haxe.io.Path;
import haxe.ds.List;
import haxe.zip.Entry;
import haxe.zip.Reader;
import sys.FileSystem;
import sys.io.File;

class Exporter {
    public function new() {
    }

    public function export(path:String):Void {
        var outputDirectoryPath:String;
        var rawDataDirectoryPath:String;

        USER_MESSAGE_INFO("Exporting RTB file: " + path);

        outputDirectoryPath = getOutputDirectoryPath(path);
        recreateEmptyDirectory(outputDirectoryPath);
        USER_MESSAGE_INFO("Prepared output directory: " + outputDirectoryPath);

        rawDataDirectoryPath = createRawDataDirectory(outputDirectoryPath);
        extractArchiveEntriesToDirectory(path, rawDataDirectoryPath);
        USER_MESSAGE_INFO("Extracted raw archive data to: " + rawDataDirectoryPath);
    }

    private function getOutputDirectoryPath(rtbFilePath:String):String {
        var directoryPath:String;
        var fileNameWithoutExtension:String;

        directoryPath = Path.directory(rtbFilePath);
        fileNameWithoutExtension = Path.withoutExtension(Path.withoutDirectory(rtbFilePath));

        if (directoryPath == null || directoryPath == "") {
            return fileNameWithoutExtension;
        }

        return Path.join([directoryPath, fileNameWithoutExtension]);
    }

    private function recreateEmptyDirectory(directoryPath:String):Void {
        if (FileSystem.exists(directoryPath)) {
            deleteDirectoryRecursively(directoryPath);
        }

        FileSystem.createDirectory(directoryPath);
    }

    private function createRawDataDirectory(outputDirectoryPath:String):String {
        var rawDataDirectoryPath:String;

        rawDataDirectoryPath = Path.join([outputDirectoryPath, "rawdata"]);
        FileSystem.createDirectory(rawDataDirectoryPath);

        return rawDataDirectoryPath;
    }

    private function extractArchiveEntriesToDirectory(rtbFilePath:String, targetDirectoryPath:String):Void {
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
            ensureDirectoryExists(archiveEntryOutputPath);
            return;
        }

        Reader.unzip(archiveEntry);
        ensureParentDirectoryExists(archiveEntryOutputPath);
        File.saveBytes(archiveEntryOutputPath, archiveEntry.data);
    }

    private function isDirectoryEntry(archiveEntryFileName:String):Bool {
        return StringTools.endsWith(archiveEntryFileName, "/") || StringTools.endsWith(archiveEntryFileName, "\\");
    }

    private function ensureParentDirectoryExists(filePath:String):Void {
        var parentDirectoryPath:String;

        parentDirectoryPath = Path.directory(filePath);

        if (parentDirectoryPath == null || parentDirectoryPath == "") {
            return;
        }

        ensureDirectoryExists(parentDirectoryPath);
    }

    private function ensureDirectoryExists(directoryPath:String):Void {
        if (directoryPath == null || directoryPath == "") {
            return;
        }

        if (FileSystem.exists(directoryPath)) {
            return;
        }

        ensureDirectoryExists(Path.directory(directoryPath));
        FileSystem.createDirectory(directoryPath);
    }

    private function deleteDirectoryRecursively(directoryPath:String):Void {
        var childPath:String;

        if (!FileSystem.isDirectory(directoryPath)) {
            FileSystem.deleteFile(directoryPath);
            return;
        }

        for (childName in FileSystem.readDirectory(directoryPath)) {
            childPath = Path.join([directoryPath, childName]);

            if (FileSystem.isDirectory(childPath)) {
                deleteDirectoryRecursively(childPath);
            } else {
                FileSystem.deleteFile(childPath);
            }
        }

        FileSystem.deleteDirectory(directoryPath);
    }
}
