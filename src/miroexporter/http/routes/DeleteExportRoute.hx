package miroexporter.http.routes;

import haxe.Json;
import miroexporter.exporter.DirectoryPreparer;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveExportRepository;
import miroexporter.interactive.InteractiveExportState;
import sys.FileSystem;
import haxe.io.Path;

class DeleteExportRoute extends Route {
    private var directoryPreparer:DirectoryPreparer;

    public function new() {
        super("/delete-export", new RestDataObject(), "POST");
        directoryPreparer = new DirectoryPreparer();
    }

    override public function handle(request:Request) {
        var exportDirectoryPath:String;
        var exportKey:String;
        var exportOutputDirectoryPath:String;
        var uploadedRtbFilePath:String;
        var requestData:Dynamic;

        try {
            requestData = Json.parse(request.postdata);
        } catch (error:Dynamic) {
            request.reply("Invalid delete request.", 400);
            return;
        }

        exportKey = Std.string(requestData.exportKey);
        exportDirectoryPath = InteractiveExportRepository.resolveExportDirectoryPath(exportKey);

        if (exportDirectoryPath == "") {
            request.reply("The selected export could not be found.", 404);
            return;
        }

        exportOutputDirectoryPath = InteractiveExportRepository.getExportOutputDirectoryPath(exportDirectoryPath);
        uploadedRtbFilePath = exportOutputDirectoryPath + ".rtb";

        if (!FileSystem.exists(exportOutputDirectoryPath)) {
            request.reply("The selected export could not be found.", 404);
            return;
        }

        directoryPreparer.deleteDirectoryRecursively(exportOutputDirectoryPath);

        if (InteractiveExportState.hasLatestExport() && InteractiveExportState.latestExportedDirectoryPath == exportDirectoryPath) {
            InteractiveExportState.clearLatestExportedDirectoryPath();
        }

        if (FileSystem.exists(uploadedRtbFilePath) && !FileSystem.isDirectory(uploadedRtbFilePath)) {
            FileSystem.deleteFile(uploadedRtbFilePath);
        }

        request.replyWithJSON({
            success: true
        });
    }
}
