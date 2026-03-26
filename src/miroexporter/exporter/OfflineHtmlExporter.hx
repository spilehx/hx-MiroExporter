package miroexporter.exporter;

import haxe.Json;
import haxe.io.Path;
import sys.io.File;

class OfflineHtmlExporter {
    private var summaryPageRenderer:OfflineSummaryPageRenderer;

    public function new() {
        summaryPageRenderer = new OfflineSummaryPageRenderer();
    }

    public function exportIndexHtml(exportedDirectoryPath:String):Void {
        var boardInfo:Dynamic;
        var indexHtmlPath:String;
        var indexHtmlContent:String;
        var resourceManifest:Dynamic;

        boardInfo = readJsonFile(Path.join([exportedDirectoryPath, "board-info.json"]));
        resourceManifest = readJsonFile(Path.join([exportedDirectoryPath, "resource-manifest.json"]));
        indexHtmlPath = Path.join([exportedDirectoryPath, "index.html"]);
        indexHtmlContent = summaryPageRenderer.render(
            boardInfo,
            resourceManifest,
            "board-info.json",
            "resource-manifest.json",
            "",
            false
        );

        File.saveContent(indexHtmlPath, indexHtmlContent);
    }

    private function readJsonFile(filePath:String):Dynamic {
        return Json.parse(File.getContent(filePath));
    }

}
