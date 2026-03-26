package miroexporter.http.routes;

import miroexporter.exporter.ExportPaths;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveExportRepository;
import sys.FileSystem;

class OpenResourcesFolderRoute extends Route {
    public function new() {
        super("/open-resources-folder", new RestDataObject(), "POST");
    }

    override public function handle(request:Request) {
        var exportDirectoryPath:String;
        var exportKey:String;
        var resourcesDirectoryPath:String;

        exportKey = StringTools.urlDecode(request.getUrlParam("export"));
        exportDirectoryPath = InteractiveExportRepository.resolveExportDirectoryPath(exportKey);

        if (exportDirectoryPath == "") {
            request.reply("The selected export could not be found.", 404);
            return;
        }

        resourcesDirectoryPath = ExportPaths.getExportedResourcesDirectoryPath(exportDirectoryPath);

        if (!FileSystem.exists(resourcesDirectoryPath) || !FileSystem.isDirectory(resourcesDirectoryPath)) {
            request.reply("The resources folder could not be found.", 404);
            return;
        }

        if (!openFolderInDefaultFileBrowser(resourcesDirectoryPath)) {
            request.reply("Could not open the resources folder on this platform.", 500);
            return;
        }

        request.replyWithJSON({
            success: true
        });
    }

    private function openFolderInDefaultFileBrowser(folderPath:String):Bool {
        var command:String;
        var systemName:String;

        systemName = Sys.systemName();
        command = buildOpenFolderCommand(systemName, folderPath);

        if (command == "") {
            return false;
        }

        Sys.command(command);

        return true;
    }

    private function buildOpenFolderCommand(systemName:String, folderPath:String):String {
        if (systemName == "Linux") {
            return 'xdg-open "' + folderPath + '"';
        }

        if (systemName == "Mac") {
            return 'open "' + folderPath + '"';
        }

        if (systemName == "Windows") {
            return 'explorer "' + folderPath + '"';
        }

        return "";
    }
}
