package miroexporter.exporter;

import haxe.Json;
import haxe.io.Path;
import miroexporter.exporter.ExportModels.RawBoardData;
import miroexporter.exporter.ExportModels.RawMetaData;
import miroexporter.exporter.ExportModels.RawResourcesData;
import sys.io.File;

class RawDataReader {
    public function new() {
    }

    public function readMetaData(rawDataDirectoryPath:String):RawMetaData {
        return Json.parse(readRawDataFileContent(rawDataDirectoryPath, "meta.json"));
    }

    public function readBoardData(rawDataDirectoryPath:String):RawBoardData {
        var boardContent:String;
        var parsedBoardData:Dynamic;

        boardContent = readRawDataFileContent(rawDataDirectoryPath, "board.json");
        parsedBoardData = Json.parse(boardContent);

        return {
            id: readRequiredNumericFieldAsString(boardContent, "id"),
            name: parsedBoardData.name,
            description: parsedBoardData.description,
            iconResourceId: readRequiredNumericFieldAsString(boardContent, "iconResourceId"),
            startViewWidgetId: parsedBoardData.startViewWidgetId,
            isPublic: parsedBoardData.isPublic
        };
    }

    public function readResourcesData(rawDataDirectoryPath:String):RawResourcesData {
        return Json.parse(normalizeResourceIdentifiers(readRawDataFileContent(rawDataDirectoryPath, "resources.json")));
    }

    private function readRawDataFileContent(rawDataDirectoryPath:String, fileName:String):String {
        return File.getContent(Path.join([rawDataDirectoryPath, fileName]));
    }

    private function normalizeResourceIdentifiers(resourceManifestContent:String):String {
        var resourceIdPattern:EReg;

        resourceIdPattern = ~/"id":([0-9]+)/g;

        return resourceIdPattern.map(resourceManifestContent, function(matchedResourceIdPattern:EReg):String {
            return "\"id\":\"" + matchedResourceIdPattern.matched(1) + "\"";
        });
    }

    private function readRequiredNumericFieldAsString(content:String, fieldName:String):String {
        var fieldPattern:EReg;
        var matchedFieldValue:String;

        fieldPattern = new EReg("\"" + fieldName + "\":(-?[0-9]+)", "g");

        if (!fieldPattern.match(content)) {
            throw "Required numeric field not found: " + fieldName;
        }

        matchedFieldValue = fieldPattern.matched(1);

        return matchedFieldValue;
    }
}
