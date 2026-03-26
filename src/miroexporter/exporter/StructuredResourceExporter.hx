package miroexporter.exporter;

import haxe.io.Path;
import miroexporter.exporter.ExportModels.ExportedResourceInfo;
import miroexporter.exporter.ExportModels.RawResourceEntry;
import miroexporter.exporter.ExportModels.RawResourcesData;
import sys.FileSystem;
import sys.io.File;

class StructuredResourceExporter {
    private var directoryPreparer:DirectoryPreparer;
    private var rawDataReader:RawDataReader;

    public function new(directoryPreparer:DirectoryPreparer, rawDataReader:RawDataReader) {
        this.directoryPreparer = directoryPreparer;
        this.rawDataReader = rawDataReader;
    }

    public function exportResources(rawDataDirectoryPath:String, exportedDirectoryPath:String):Array<ExportedResourceInfo> {
        var exportedResources:Array<ExportedResourceInfo>;
        var resourcesDirectoryPath:String;
        var resourcesData:RawResourcesData;

        resourcesDirectoryPath = ExportPaths.getExportedResourcesDirectoryPath(exportedDirectoryPath);
        directoryPreparer.ensureDirectoryExists(resourcesDirectoryPath);
        resourcesData = rawDataReader.readResourcesData(rawDataDirectoryPath);
        exportedResources = [];

        for (resourceEntry in resourcesData.resources) {
            exportResourceIfSupported(resourceEntry, rawDataDirectoryPath, resourcesDirectoryPath, exportedResources);
        }

        return exportedResources;
    }

    private function exportResourceIfSupported(resourceEntry:RawResourceEntry, rawDataDirectoryPath:String, resourcesDirectoryPath:String, exportedResources:Array<ExportedResourceInfo>):Void {
        var exportedResource:ExportedResourceInfo;
        var sourceFileBytes:haxe.io.Bytes;
        var sourceFilePath:String;
        var targetFilePath:String;
        var sourceFileName:String;
        var targetFileName:String;

        if (!isSupportedResourceExtension(resourceEntry.extension)) {
            return;
        }

        sourceFileName = buildRawDataResourceFileName(resourceEntry);
        sourceFilePath = Path.join([rawDataDirectoryPath, sourceFileName]);

        if (!FileSystem.exists(sourceFilePath)) {
            return;
        }

        targetFileName = getUniqueFileName(resourceEntry.name, resourcesDirectoryPath);
        targetFilePath = Path.join([resourcesDirectoryPath, targetFileName]);
        sourceFileBytes = File.getBytes(sourceFilePath);
        File.saveBytes(targetFilePath, sourceFileBytes);

        exportedResource = {
            id: resourceEntry.id,
            originalFileName: resourceEntry.name,
            exportedFileName: targetFileName,
            rawFileName: sourceFileName,
            extension: resourceEntry.extension,
            resourceType: resourceEntry.type,
            infected: resourceEntry.infected,
            category: getResourceCategory(resourceEntry.extension),
            mimeType: getMimeType(resourceEntry.extension),
            rawPath: Path.join(["rawdata", sourceFileName]),
            exportedPath: Path.join(["exported", "resources", targetFileName]),
            fileSizeBytes: sourceFileBytes.length
        };

        exportedResources.push(exportedResource);
    }

    private function buildRawDataResourceFileName(resourceEntry:RawResourceEntry):String {
        return resourceEntry.id + "." + resourceEntry.extension;
    }

    private function isSupportedResourceExtension(extension:String):Bool {
        var normalizedExtension:String;

        normalizedExtension = extension.toLowerCase();

        return normalizedExtension == "png"
            || normalizedExtension == "svg"
            || normalizedExtension == "jpg"
            || normalizedExtension == "mp4";
    }

    private function getResourceCategory(extension:String):String {
        var normalizedExtension:String;

        normalizedExtension = extension.toLowerCase();

        if (normalizedExtension == "png" || normalizedExtension == "jpg") {
            return "image";
        }

        if (normalizedExtension == "svg") {
            return "vector";
        }

        if (normalizedExtension == "mp4") {
            return "video";
        }

        return "unknown";
    }

    private function getMimeType(extension:String):String {
        var normalizedExtension:String;

        normalizedExtension = extension.toLowerCase();

        if (normalizedExtension == "png") {
            return "image/png";
        }

        if (normalizedExtension == "jpg") {
            return "image/jpeg";
        }

        if (normalizedExtension == "svg") {
            return "image/svg+xml";
        }

        if (normalizedExtension == "mp4") {
            return "video/mp4";
        }

        return "application/octet-stream";
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
