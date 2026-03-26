package miroexporter.exporter;

typedef RawMetaData = {
    var version:String;
    var encryptionVersion:String;
    var timestamp:Int;
}

typedef RawBoardData = {
    var id:String;
    var name:String;
    var description:String;
    var iconResourceId:String;
    var startViewWidgetId:String;
    var isPublic:Bool;
}

typedef RawResourcesData = {
    var document:Dynamic;
    var image:Dynamic;
    var resources:Array<RawResourceEntry>;
}

typedef RawResourceEntry = {
    var id:String;
    var name:String;
    var extension:String;
    var type:String;
    var infected:Bool;
}

typedef ExportedResourceInfo = {
    var id:String;
    var originalFileName:String;
    var exportedFileName:String;
    var rawFileName:String;
    var extension:String;
    var resourceType:String;
    var infected:Bool;
    var category:String;
    var mimeType:String;
    var rawPath:String;
    var exportedPath:String;
    var fileSizeBytes:Int;
}
