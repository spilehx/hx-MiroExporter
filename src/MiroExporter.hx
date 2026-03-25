package;

import miroexporter.MiroExporterApp;

class MiroExporter {
    static function main() {
		var app:MiroExporterApp = new MiroExporterApp();
		app.init();
		app.parseArgs();
		
	}
}