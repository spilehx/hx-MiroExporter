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
import miroexporter.interactive.InteractiveExportRepository;
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

        USER_MESSAGE_INFO("Upload request received for /upload");

        try {
            requestData = Json.parse(request.postdata);
        } catch (error:Dynamic) {
            USER_MESSAGE_ERROR("Failed to parse upload request body: " + Std.string(error));
            request.reply("Invalid upload request.", 400);
            return;
        }

        uploadedFileName = sanitizeUploadedFileName(Std.string(requestData.fileName));
        USER_MESSAGE_INFO("Upload request file name: " + uploadedFileName);

        if (!StringTools.endsWith(uploadedFileName.toLowerCase(), ".rtb")) {
            USER_MESSAGE_WARN("Rejected upload because file extension is not .rtb: " + uploadedFileName);
            request.reply("Only .rtb files are supported.", 400);
            return;
        }

        ensureUploadDirectoryExists();

        try {
            uploadedFileBytes = Base64.decode(Std.string(requestData.base64Data));
        } catch (error:Dynamic) {
            USER_MESSAGE_ERROR("Failed to decode uploaded RTB file: " + uploadedFileName + " | " + Std.string(error));
            request.reply("Failed to decode uploaded file.", 400);
            return;
        }

        USER_MESSAGE_INFO("Decoded uploaded RTB file bytes: " + uploadedFileBytes.length);

        uploadedFilePath = Path.join([getUploadDirectoryPath(), uploadedFileName]);
        File.saveBytes(uploadedFilePath, uploadedFileBytes);
        USER_MESSAGE_INFO("Saved uploaded RTB file to: " + uploadedFilePath);

        try {
            USER_MESSAGE_INFO("Starting export for uploaded RTB file: " + uploadedFilePath);
            new Exporter().export(uploadedFilePath);
        } catch (error:Dynamic) {
            USER_MESSAGE_ERROR("Failed to process uploaded RTB file: " + uploadedFilePath + " | " + Std.string(error));
            request.reply("Failed to process uploaded RTB file.", 500);
            return;
        }

        exportOutputDirectoryPath = ExportPaths.getOutputDirectoryPath(uploadedFilePath);
        exportedDirectoryPath = ExportPaths.getExportedDirectoryPath(exportOutputDirectoryPath);
        InteractiveExportState.setLatestExportedDirectoryPath(exportedDirectoryPath);
        USER_MESSAGE_INFO("Interactive export completed. Exported directory: " + exportedDirectoryPath);

        try {
            USER_MESSAGE_INFO("Rendering interactive summary page for: " + exportedDirectoryPath);
            request.replyWithHTML(buildSummaryPage(exportedDirectoryPath));
        } catch (error:Dynamic) {
            USER_MESSAGE_ERROR("Failed to build interactive summary page: " + exportedDirectoryPath + " | " + Std.string(error));
            request.reply("Export completed, but the summary page could not be generated.", 500);
        }
    }

    private function buildSummaryPage(exportedDirectoryPath:String):String {
        var boardInfo:Dynamic;
        var exportKey:String;
        var fileRoutePrefix:String;
        var resourceManifest:Dynamic;

        exportKey = InteractiveExportRepository.getExportKey(exportedDirectoryPath);
        fileRoutePrefix = "/file?export=" + StringTools.urlEncode(exportKey) + "&path=";
        boardInfo = Json.parse(File.getContent(Path.join([exportedDirectoryPath, "board-info.json"])));
        resourceManifest = Json.parse(File.getContent(Path.join([exportedDirectoryPath, "resource-manifest.json"])));

        return summaryPageRenderer.render(
            boardInfo,
            resourceManifest,
            fileRoutePrefix + StringTools.urlEncode("board-info.json"),
            fileRoutePrefix + StringTools.urlEncode("resource-manifest.json"),
            fileRoutePrefix,
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
            USER_MESSAGE_INFO("Created interactive upload directory: " + uploadDirectoryPath);
        }
    }
}
