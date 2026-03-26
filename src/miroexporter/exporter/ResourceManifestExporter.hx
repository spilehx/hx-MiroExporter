package miroexporter.exporter;

import haxe.Json;
import haxe.io.Path;
import miroexporter.exporter.ExportModels.ExportedResourceInfo;
import sys.io.File;

class ResourceManifestExporter {
    public function new() {
    }

    public function exportResourceManifest(exportedDirectoryPath:String, exportedResources:Array<ExportedResourceInfo>):Void {
        var resourceManifestPath:String;
        var resourceManifest:Dynamic;

        resourceManifestPath = Path.join([exportedDirectoryPath, "resource-manifest.json"]);
        resourceManifest = {
            resources: exportedResources
        };

        File.saveContent(resourceManifestPath, Json.stringify(resourceManifest, null, "  "));
    }
}
