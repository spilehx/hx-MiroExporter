package miroexporter.exporter;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

typedef ResourceManifest = {
    var resources:Array<ResourceManifestEntry>;
}

typedef ResourceManifestEntry = {
    var id:Float;
    var name:String;
    var extension:String;
}

class StructuredResourceExporter {
    private var directoryPreparer:DirectoryPreparer;

    public function new(directoryPreparer:DirectoryPreparer) {
        this.directoryPreparer = directoryPreparer;
    }

    public function exportResources(rawDataDirectoryPath:String, exportedDirectoryPath:String):Void {
        var resourcesDirectoryPath:String;
        var resourceManifest:ResourceManifest;

        resourcesDirectoryPath = ExportPaths.getExportedResourcesDirectoryPath(exportedDirectoryPath);
        directoryPreparer.ensureDirectoryExists(resourcesDirectoryPath);

        resourceManifest = readResourceManifest(rawDataDirectoryPath);

        for (resourceManifestEntry in resourceManifest.resources) {
            exportResourceIfSupported(resourceManifestEntry, rawDataDirectoryPath, resourcesDirectoryPath);
        }
    }

    private function readResourceManifest(rawDataDirectoryPath:String):ResourceManifest {
        var resourceManifestPath:String;
        var resourceManifestContent:String;

        resourceManifestPath = Path.join([rawDataDirectoryPath, "resources.json"]);
        resourceManifestContent = File.getContent(resourceManifestPath);

        return Json.parse(resourceManifestContent);
    }

    private function exportResourceIfSupported(resourceManifestEntry:ResourceManifestEntry, rawDataDirectoryPath:String, resourcesDirectoryPath:String):Void {
        var sourceFilePath:String;
        var targetFilePath:String;
        var sourceFileName:String;
        var targetFileName:String;

        if (!isSupportedResourceExtension(resourceManifestEntry.extension)) {
            return;
        }

        sourceFileName = buildRawDataResourceFileName(resourceManifestEntry);
        sourceFilePath = Path.join([rawDataDirectoryPath, sourceFileName]);

        if (!FileSystem.exists(sourceFilePath)) {
            return;
        }

        targetFileName = getUniqueFileName(resourceManifestEntry.name, resourcesDirectoryPath);
        targetFilePath = Path.join([resourcesDirectoryPath, targetFileName]);

        File.copy(sourceFilePath, targetFilePath);
    }

    private function buildRawDataResourceFileName(resourceManifestEntry:ResourceManifestEntry):String {
        return Std.string(Std.int(resourceManifestEntry.id)) + "." + resourceManifestEntry.extension;
    }

    private function isSupportedResourceExtension(extension:String):Bool {
        var normalizedExtension:String;

        normalizedExtension = extension.toLowerCase();

        return normalizedExtension == "png"
            || normalizedExtension == "svg"
            || normalizedExtension == "jpg"
            || normalizedExtension == "mp4";
    }

    private function getUniqueFileName(requestedFileName:String, directoryPath:String):String {
        var candidateFileName:String;
        var extension:String;
        var fileNameWithoutExtension:String;
        var filePath:String;
        var duplicateIndex:Int;

        candidateFileName = requestedFileName;
        extension = Path.extension(requestedFileName);
        fileNameWithoutExtension = Path.withoutExtension(requestedFileName);
        duplicateIndex = 1;

        filePath = Path.join([directoryPath, candidateFileName]);

        while (FileSystem.exists(filePath)) {
            if (extension == null || extension == "") {
                candidateFileName = fileNameWithoutExtension + "(" + duplicateIndex + ")";
            } else {
                candidateFileName = fileNameWithoutExtension + "(" + duplicateIndex + ")." + extension;
            }

            filePath = Path.join([directoryPath, candidateFileName]);
            duplicateIndex++;
        }

        return candidateFileName;
    }
}
