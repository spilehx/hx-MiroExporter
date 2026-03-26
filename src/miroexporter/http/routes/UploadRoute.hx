package miroexporter.http.routes;

import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.Path;
import miroexporter.exporter.ExportPaths;
import miroexporter.exporter.Exporter;
import miroexporter.exporter.OfflineSummaryPageRenderer;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveExportState;
import sys.FileSystem;
import sys.io.File;

class UploadRoute extends Route {
    private var summaryPageRenderer:OfflineSummaryPageRenderer;

    public function new() {
        super("/upload", new RestDataObject(), "POST");
        summaryPageRenderer = new OfflineSummaryPageRenderer();
    }

    override public function handle(request:Request) {
        var exportedDirectoryPath:String;
        var exportOutputDirectoryPath:String;
        var requestData:Dynamic;
        var uploadedFileBytes:haxe.io.Bytes;
        var uploadedFileName:String;
        var uploadedFilePath:String;

        try {
            requestData = Json.parse(request.postdata);
        } catch (error:Dynamic) {
            request.reply("Invalid upload request.", 400);
            return;
        }

        uploadedFileName = sanitizeUploadedFileName(Std.string(requestData.fileName));

        if (!StringTools.endsWith(uploadedFileName.toLowerCase(), ".rtb")) {
            request.reply("Only .rtb files are supported.", 400);
            return;
        }

        ensureUploadDirectoryExists();

        try {
            uploadedFileBytes = Base64.decode(Std.string(requestData.base64Data));
        } catch (error:Dynamic) {
            request.reply("Failed to decode uploaded file.", 400);
            return;
        }

        uploadedFilePath = Path.join([getUploadDirectoryPath(), uploadedFileName]);
        File.saveBytes(uploadedFilePath, uploadedFileBytes);

        try {
            new Exporter().export(uploadedFilePath);
        } catch (error:Dynamic) {
            request.reply("Failed to process uploaded RTB file.", 500);
            return;
        }

        exportOutputDirectoryPath = ExportPaths.getOutputDirectoryPath(uploadedFilePath);
        exportedDirectoryPath = ExportPaths.getExportedDirectoryPath(exportOutputDirectoryPath);
        InteractiveExportState.setLatestExportedDirectoryPath(exportedDirectoryPath);
        request.replyWithHTML(buildSummaryPage(exportedDirectoryPath));
    }

    private function buildSummaryPage(exportedDirectoryPath:String):String {
        var boardInfo:Dynamic;
        var resourceManifest:Dynamic;

        boardInfo = Json.parse(File.getContent(Path.join([exportedDirectoryPath, "board-info.json"])));
        resourceManifest = Json.parse(File.getContent(Path.join([exportedDirectoryPath, "resource-manifest.json"])));

        return summaryPageRenderer.render(
            boardInfo,
            resourceManifest,
            "/file?path=" + StringTools.urlEncode("board-info.json"),
            "/file?path=" + StringTools.urlEncode("resource-manifest.json"),
            "/file?path=",
            true
        );
    }

    private function sanitizeUploadedFileName(uploadedFileName:String):String {
        var fileName:String;

        fileName = Path.withoutDirectory(uploadedFileName);
        fileName = fileName.split("\\").pop();

        if (fileName == null || fileName == "") {
            return "uploaded.rtb";
        }

        return fileName;
    }

    private function getUploadDirectoryPath():String {
        return Path.join([Sys.getCwd(), "interactive_uploads"]);
    }

    private function ensureUploadDirectoryExists():Void {
        var uploadDirectoryPath:String;

        uploadDirectoryPath = getUploadDirectoryPath();

        if (!FileSystem.exists(uploadDirectoryPath)) {
            FileSystem.createDirectory(uploadDirectoryPath);
        }
    }
}
