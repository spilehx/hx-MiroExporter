package miroexporter.exporter;

import haxe.io.Path;

class ExportPaths {
    public static function getOutputDirectoryPath(rtbFilePath:String):String {
        var directoryPath:String;
        var fileNameWithoutExtension:String;

        directoryPath = Path.directory(rtbFilePath);
        fileNameWithoutExtension = Path.withoutExtension(Path.withoutDirectory(rtbFilePath));

        if (directoryPath == null || directoryPath == "") {
            return fileNameWithoutExtension;
        }

        return Path.join([directoryPath, fileNameWithoutExtension]);
    }

    public static function getRawDataDirectoryPath(outputDirectoryPath:String):String {
        return Path.join([outputDirectoryPath, "rawdata"]);
    }
}
