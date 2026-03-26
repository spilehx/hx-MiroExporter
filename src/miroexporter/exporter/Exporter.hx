package miroexporter.exporter;

class Exporter {
    private var directoryPreparer:DirectoryPreparer;
    private var rtbArchiveExtractor:RtbArchiveExtractor;

    public function new() {
        directoryPreparer = new DirectoryPreparer();
        rtbArchiveExtractor = new RtbArchiveExtractor(directoryPreparer);
    }

    public function export(path:String):Void {
        var outputDirectoryPath:String;
        var rawDataDirectoryPath:String;

        USER_MESSAGE_INFO("Exporting RTB file: " + path);

        outputDirectoryPath = ExportPaths.getOutputDirectoryPath(path);
        directoryPreparer.recreateEmptyDirectory(outputDirectoryPath);
        USER_MESSAGE_INFO("Prepared output directory: " + outputDirectoryPath);

        rawDataDirectoryPath = ExportPaths.getRawDataDirectoryPath(outputDirectoryPath);
        directoryPreparer.ensureDirectoryExists(rawDataDirectoryPath);
        rtbArchiveExtractor.extractArchiveEntriesToDirectory(path, rawDataDirectoryPath);
        USER_MESSAGE_INFO("Extracted raw archive data to: " + rawDataDirectoryPath);
    }
}
