package miroexporter.exporter;

import haxe.Json;
import haxe.io.Path;
import miroexporter.exporter.ExportModels.ExportedResourceInfo;
import miroexporter.exporter.ExportModels.RawBoardData;
import miroexporter.exporter.ExportModels.RawMetaData;
import miroexporter.exporter.ExportModels.RawResourcesData;
import sys.io.File;

class BoardInfoExporter {
    private var rawDataReader:RawDataReader;

    public function new(rawDataReader:RawDataReader) {
        this.rawDataReader = rawDataReader;
    }

    public function exportBoardInfo(rawDataDirectoryPath:String, exportedDirectoryPath:String, exportedResources:Array<ExportedResourceInfo>):Void {
        var boardInfoPath:String;
        var boardData:RawBoardData;
        var metaData:RawMetaData;
        var resourcesData:RawResourcesData;
        var boardInfo:Dynamic;

        boardInfoPath = Path.join([exportedDirectoryPath, "board-info.json"]);
        boardData = rawDataReader.readBoardData(rawDataDirectoryPath);
        metaData = rawDataReader.readMetaData(rawDataDirectoryPath);
        resourcesData = rawDataReader.readResourcesData(rawDataDirectoryPath);
        boardInfo = buildBoardInfo(boardData, metaData, resourcesData, exportedResources);

        File.saveContent(boardInfoPath, Json.stringify(boardInfo, null, "  "));
    }

    private function buildBoardInfo(boardData:RawBoardData, metaData:RawMetaData, resourcesData:RawResourcesData, exportedResources:Array<ExportedResourceInfo>):Dynamic {
        return {
            board: {
                id: boardData.id,
                name: boardData.name,
                description: boardData.description,
                isPublic: boardData.isPublic,
                startViewWidgetId: boardData.startViewWidgetId,
                iconResourceId: boardData.iconResourceId
            },
            archive: {
                format: "rtb",
                version: metaData.version,
                encryptionVersion: metaData.encryptionVersion,
                timestampUnix: metaData.timestamp
            },
            resourcesSummary: {
                totalResources: resourcesData.resources.length,
                supportedOfflineResources: exportedResources.length,
                images: countResourcesByCategory(exportedResources, "image"),
                vectors: countResourcesByCategory(exportedResources, "vector"),
                videos: countResourcesByCategory(exportedResources, "video"),
                documents: countResourcesByCategory(exportedResources, "document"),
                infected: countInfectedResources(resourcesData)
            },
            limitations: {
                canvasDataReadable: false,
                tablesDataReadable: false,
                layoutRecovered: false
            }
        };
    }

    private function countResourcesByCategory(exportedResources:Array<ExportedResourceInfo>, category:String):Int {
        var count:Int;

        count = 0;

        for (exportedResource in exportedResources) {
            if (exportedResource.category == category) {
                count++;
            }
        }

        return count;
    }

    private function countInfectedResources(resourcesData:RawResourcesData):Int {
        var count:Int;

        count = 0;

        for (resourceEntry in resourcesData.resources) {
            if (resourceEntry.infected) {
                count++;
            }
        }

        return count;
    }
}
