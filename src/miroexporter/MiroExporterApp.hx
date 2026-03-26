package miroexporter;

import miroexporter.interactive.InteractiveUI;
import miroexporter.exporter.Exporter;
import sys.FileSystem;

class MiroExporterApp {
	public function new() {
		spilehx.logger.GlobalLoggingSettings.settings.verbose = true;
	}

	public function init() {
		USER_MESSAGE("Starting Miro Exporter", true);
	}

	public function parseArgs() {
		var args = Sys.args();

		if (args.length == 0 || wantsHelp(args[0])) {
			printHelp();
			return;
		}

		switch (args[0]) {
			case "extract":
				runExtract(args);
			case "interactive":
				runInteractive();
			case "version":
				USER_MESSAGE("MiroExporter 0.1.0", true);
			default:
				USER_MESSAGE_ERROR("Unknown command: " + args[0]);
				USER_MESSAGE("");
				printHelp();
				Sys.exit(1);
		}
	}

	private function runInteractive(){
		USER_MESSAGE("Running interactive");
		new InteractiveUI().startHttpServer();
	}

	private function runExtract(args:Array<String>):Void {
		if (args.length < 2) {
			USER_MESSAGE_ERROR("No .rtb file path provided for extraction.");
			USER_MESSAGE("");
			USER_MESSAGE("Usage: MiroExporter extract <path-to-file.rtb>", true);
			Sys.exit(1);
		}

		var path = args[1];

		if (!StringTools.endsWith(path.toLowerCase(), ".rtb")) {
			USER_MESSAGE_ERROR("Expected a file with .rtb extension: " + path);
			Sys.exit(1);
		}

		if (!FileSystem.exists(path)) {
			USER_MESSAGE_ERROR("File not found: " + path);
			Sys.exit(1);
		}

		// USER_MESSAGE_INFO("Extracting RTB file: " + path);
		var exporter = new Exporter();
		exporter.export(path);
	}

	private function wantsHelp(arg:String):Bool {
		return arg == "help" || arg == "--help" || arg == "-h";
	}

	private function printHelp():Void {
	
		USER_MESSAGE_INFO("Usage:");
		USER_MESSAGE("  MiroExporter <command> [arguments]");
		USER_MESSAGE("");
		USER_MESSAGE_INFO("Commands:");
		USER_MESSAGE("  extract <path-to-file.rtb>   Extract and parse an RTB file");
		USER_MESSAGE("  interactive                  Start the interactive mode");
		USER_MESSAGE("  version                      Print the application version");
		USER_MESSAGE("  help                         Show this message");
		USER_MESSAGE("");
		USER_MESSAGE_INFO("Examples:");
		USER_MESSAGE("  MiroExporter extract ./board.rtb");
		USER_MESSAGE("  MiroExporter version");
	}
}
