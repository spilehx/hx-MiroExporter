package miroexporter.exporter;

import miroexporter.exporter.ExportModels.ExportedResourceInfo;

class Exporter {
    private var boardInfoExporter:BoardInfoExporter;
    private var directoryPreparer:DirectoryPreparer;
    private var offlineHtmlExporter:OfflineHtmlExporter;
    private var rawDataReader:RawDataReader;
    private var resourceManifestExporter:ResourceManifestExporter;
    private var rtbArchiveExtractor:RtbArchiveExtractor;
    private var structuredResourceExporter:StructuredResourceExporter;

    public function new() {
        rawDataReader = new RawDataReader();
        directoryPreparer = new DirectoryPreparer();
        rtbArchiveExtractor = new RtbArchiveExtractor(directoryPreparer);
        structuredResourceExporter = new StructuredResourceExporter(directoryPreparer, rawDataReader);
        boardInfoExporter = new BoardInfoExporter(rawDataReader);
        offlineHtmlExporter = new OfflineHtmlExporter();
        resourceManifestExporter = new ResourceManifestExporter();
    }

    public function export(path:String):Void {
        var exportedResources:Array<ExportedResourceInfo>;
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

        exportedResources = structuredResourceExporter.exportResources(rawDataDirectoryPath, exportedDirectoryPath);
        boardInfoExporter.exportBoardInfo(rawDataDirectoryPath, exportedDirectoryPath, exportedResources);
        resourceManifestExporter.exportResourceManifest(exportedDirectoryPath, exportedResources);
        offlineHtmlExporter.exportIndexHtml(exportedDirectoryPath);
        USER_MESSAGE_INFO("Exported supported resources to structured output.");
    }
}
