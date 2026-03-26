package miroexporter.interactive;

import haxe.Json;
import haxe.io.Path;
import miroexporter.AppPaths;
import sys.FileSystem;
import sys.io.File;

typedef InteractiveExportRecord = {
    var boardName:String;
    var exportDirectoryPath:String;
    var exportKey:String;
}

class InteractiveExportRepository {
    public static function findAvailableExports():Array<InteractiveExportRecord> {
        var exportDirectoryPaths:Array<String>;
        var exportRecords:Array<InteractiveExportRecord>;

        exportDirectoryPaths = [];
        exportRecords = [];

        AppPaths.ensureApplicationDataDirectoryExists();
        collectExportDirectoryPaths(AppPaths.getApplicationDataDirectoryPath(), exportDirectoryPaths);

        for (exportDirectoryPath in exportDirectoryPaths) {
            exportRecords.push(buildExportRecord(exportDirectoryPath));
        }

        exportRecords.sort(sortExportRecords);

        return exportRecords;
    }

    public static function resolveExportDirectoryPath(exportKey:String):String {
        var normalizedExportDirectoryPath:String;
        var normalizedWorkspacePath:String;

        if (exportKey == null || exportKey == "") {
            return "";
        }

        normalizedWorkspacePath = AppPaths.getApplicationDataDirectoryPath();
        normalizedExportDirectoryPath = Path.normalize(Path.join([normalizedWorkspacePath, exportKey]));

        if (!isPathWithinRoot(normalizedExportDirectoryPath, normalizedWorkspacePath)) {
            return "";
        }

        if (!isValidExportDirectory(normalizedExportDirectoryPath)) {
            return "";
        }

        return normalizedExportDirectoryPath;
    }

    public static function getExportKey(exportDirectoryPath:String):String {
        var normalizedExportDirectoryPath:String;
        var normalizedWorkspacePath:String;

        normalizedWorkspacePath = Path.addTrailingSlash(AppPaths.getApplicationDataDirectoryPath());
        normalizedExportDirectoryPath = Path.normalize(exportDirectoryPath);

        if (StringTools.startsWith(normalizedExportDirectoryPath, normalizedWorkspacePath)) {
            return normalizedExportDirectoryPath.substr(normalizedWorkspacePath.length);
        }

        return normalizedExportDirectoryPath;
    }

    public static function getExportOutputDirectoryPath(exportDirectoryPath:String):String {
        return Path.normalize(Path.directory(exportDirectoryPath));
    }

    private static function collectExportDirectoryPaths(directoryPath:String, exportDirectoryPaths:Array<String>):Void {
        var childPath:String;
        var entryName:String;
        var entryNames:Array<String>;

        if (!FileSystem.exists(directoryPath) || !FileSystem.isDirectory(directoryPath)) {
            return;
        }

        if (isValidExportDirectory(directoryPath)) {
            exportDirectoryPaths.push(directoryPath);
            return;
        }

        entryNames = FileSystem.readDirectory(directoryPath);

        for (entryName in entryNames) {
            childPath = Path.join([directoryPath, entryName]);

            if (FileSystem.isDirectory(childPath)) {
                collectExportDirectoryPaths(childPath, exportDirectoryPaths);
            }
        }
    }

    private static function isValidExportDirectory(directoryPath:String):Bool {
        if (!FileSystem.exists(directoryPath) || !FileSystem.isDirectory(directoryPath)) {
            return false;
        }

        return FileSystem.exists(Path.join([directoryPath, "board-info.json"]))
            && FileSystem.exists(Path.join([directoryPath, "resource-manifest.json"]));
    }

    private static function buildExportRecord(exportDirectoryPath:String):InteractiveExportRecord {
        var boardInfo:Dynamic;
        var boardName:String;

        boardName = Path.withoutDirectory(Path.directory(exportDirectoryPath));

        try {
            boardInfo = Json.parse(File.getContent(Path.join([exportDirectoryPath, "board-info.json"])));
            if (boardInfo != null && boardInfo.board != null && boardInfo.board.name != null) {
                boardName = Std.string(boardInfo.board.name);
            }
        } catch (error:Dynamic) {
        }

        return {
            boardName: boardName,
            exportDirectoryPath: exportDirectoryPath,
            exportKey: getExportKey(exportDirectoryPath)
        };
    }

    private static function sortExportRecords(left:InteractiveExportRecord, right:InteractiveExportRecord):Int {
        var leftName:String;
        var rightName:String;

        leftName = left.boardName.toLowerCase();
        rightName = right.boardName.toLowerCase();

        if (leftName < rightName) {
            return -1;
        }

        if (leftName > rightName) {
            return 1;
        }

        if (left.exportKey < right.exportKey) {
            return -1;
        }

        if (left.exportKey > right.exportKey) {
            return 1;
        }

        return 0;
    }

    private static function isPathWithinRoot(candidatePath:String, rootPath:String):Bool {
        var normalizedCandidatePath:String;
        var normalizedRootPath:String;

        normalizedCandidatePath = Path.normalize(candidatePath);
        normalizedRootPath = Path.addTrailingSlash(Path.normalize(rootPath));

        return StringTools.startsWith(normalizedCandidatePath, normalizedRootPath)
            || normalizedCandidatePath == Path.normalize(rootPath);
    }
}
