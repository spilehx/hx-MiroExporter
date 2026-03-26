package miroexporter.http.routes;

import haxe.io.Path;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveExportRepository;
import sys.FileSystem;

class FileRoute extends Route {
    public function new() {
        super("/file", new RestDataObject(), "GET");
    }

    override public function handle(request:Request) {
        var exportDirectoryPath:String;
        var exportKey:String;
        var requestedRelativePath:String;
        var resolvedFilePath:String;

        exportKey = StringTools.urlDecode(request.getUrlParam("export"));
        exportDirectoryPath = InteractiveExportRepository.resolveExportDirectoryPath(exportKey);

        requestedRelativePath = StringTools.urlDecode(request.getUrlParam("path"));

        if (exportDirectoryPath == "") {
            request.reply("Missing or invalid export parameter.", 400);
            return;
        }

        if (requestedRelativePath == "") {
            request.reply("Missing path parameter.", 400);
            return;
        }

        resolvedFilePath = Path.normalize(Path.join([exportDirectoryPath, requestedRelativePath]));

        if (!isPathWithinExportDirectory(resolvedFilePath, exportDirectoryPath)) {
            request.reply("Invalid file path.", 400);
            return;
        }

        if (!FileSystem.exists(resolvedFilePath) || FileSystem.isDirectory(resolvedFilePath)) {
            request.reply404();
            return;
        }

        request.replyWithFile(resolvedFilePath);
    }

    private function isPathWithinExportDirectory(candidatePath:String, exportDirectoryPath:String):Bool {
        var normalizedCandidatePath:String;
        var normalizedExportDirectoryPath:String;

        normalizedCandidatePath = Path.normalize(candidatePath);
        normalizedExportDirectoryPath = Path.addTrailingSlash(Path.normalize(exportDirectoryPath));

        return StringTools.startsWith(normalizedCandidatePath, normalizedExportDirectoryPath)
            || normalizedCandidatePath == Path.normalize(exportDirectoryPath);
    }
}
