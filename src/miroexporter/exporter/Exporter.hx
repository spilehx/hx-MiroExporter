package miroexporter.exporter;

class Exporter {
    public function new() {
    }

    public function export(path:String):Void {
        USER_MESSAGE_INFO("Exporting RTB file: " + path);
    }
}