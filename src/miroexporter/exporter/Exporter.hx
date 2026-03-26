package miroexporter.exporter;

class Exporter {
    private var directoryPreparer:DirectoryPreparer;
    private var rtbArchiveExtractor:RtbArchiveExtractor;
    private var structuredResourceExporter:StructuredResourceExporter;

    public function new() {
        directoryPreparer = new DirectoryPreparer();
        rtbArchiveExtractor = new RtbArchiveExtractor(directoryPreparer);
        structuredResourceExporter = new StructuredResourceExporter(directoryPreparer);
    }

    public function export(path:String):Void {
        var outputDirectoryPath:String;
        var rawDataDirectoryPath:String;
        var exportedDirectoryPath:String;

        USER_MESSAGE_INFO("Exporting RTB file: " + path);

        outputDirectoryPath = ExportPaths.getOutputDirectoryPath(path);
        directoryPreparer.recreateEmptyDirectory(outputDirectoryPath);
        USER_MESSAGE_INFO("Prepared output directory: " + outputDirectoryPath);

        rawDataDirectoryPath = ExportPaths.getRawDataDirectoryPath(outputDirectoryPath);
        directoryPreparer.ensureDirectoryExists(rawDataDirectoryPath);
        rtbArchiveExtractor.extractArchiveEntriesToDirectory(path, rawDataDirectoryPath);
        USER_MESSAGE_INFO("Extracted raw archive data to: " + rawDataDirectoryPath);

        exportedDirectoryPath = ExportPaths.getExportedDirectoryPath(outputDirectoryPath);
        directoryPreparer.ensureDirectoryExists(exportedDirectoryPath);
        USER_MESSAGE_INFO("Prepared structured export directory: " + exportedDirectoryPath);

        structuredResourceExporter.exportResources(rawDataDirectoryPath, exportedDirectoryPath);
        USER_MESSAGE_INFO("Exported supported resources to structured output.");
    }
}
