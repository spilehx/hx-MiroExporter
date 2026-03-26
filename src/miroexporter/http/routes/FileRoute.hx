package miroexporter.http.routes;

import haxe.io.Path;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveExportState;
import sys.FileSystem;

class FileRoute extends Route {
    public function new() {
        super("/file", new RestDataObject(), "GET");
    }

    override public function handle(request:Request) {
        var requestedRelativePath:String;
        var resolvedFilePath:String;
        var rootDirectoryPath:String;

        if (!InteractiveExportState.hasLatestExport()) {
            request.reply("No export is currently available.", 404);
            return;
        }

        requestedRelativePath = StringTools.urlDecode(request.getUrlParam("path"));

        if (requestedRelativePath == "") {
            request.reply("Missing path parameter.", 400);
            return;
        }

        rootDirectoryPath = Path.normalize(InteractiveExportState.latestExportedDirectoryPath);
        resolvedFilePath = Path.normalize(Path.join([rootDirectoryPath, requestedRelativePath]));

        if (!StringTools.startsWith(resolvedFilePath, rootDirectoryPath)) {
            request.reply("Invalid file path.", 400);
            return;
        }

        if (!FileSystem.exists(resolvedFilePath) || FileSystem.isDirectory(resolvedFilePath)) {
            request.reply404();
            return;
        }

        request.replyWithFile(resolvedFilePath);
    }
}
