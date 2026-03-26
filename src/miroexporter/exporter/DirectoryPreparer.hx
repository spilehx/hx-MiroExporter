package miroexporter.exporter;

import haxe.io.Path;
import sys.FileSystem;

class DirectoryPreparer {
    public function new() {
    }

    public function recreateEmptyDirectory(directoryPath:String):Void {
        if (FileSystem.exists(directoryPath)) {
            deleteDirectoryRecursively(directoryPath);
        }

        FileSystem.createDirectory(directoryPath);
    }

    public function ensureDirectoryExists(directoryPath:String):Void {
        if (directoryPath == null || directoryPath == "") {
            return;
        }

        if (FileSystem.exists(directoryPath)) {
            return;
        }

        ensureDirectoryExists(Path.directory(directoryPath));
        FileSystem.createDirectory(directoryPath);
    }

    public function deleteDirectoryRecursively(directoryPath:String):Void {
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
