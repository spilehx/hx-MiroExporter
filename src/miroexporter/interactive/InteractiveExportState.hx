package miroexporter.interactive;

class InteractiveExportState {
    public static var latestExportedDirectoryPath:String;

    public static function setLatestExportedDirectoryPath(exportedDirectoryPath:String):Void {
        latestExportedDirectoryPath = exportedDirectoryPath;
    }

    public static function hasLatestExport():Bool {
        return latestExportedDirectoryPath != null && latestExportedDirectoryPath != "";
    }
}
