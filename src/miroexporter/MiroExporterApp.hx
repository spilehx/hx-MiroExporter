package miroexporter;

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
			case "hello":
				var name = args.length > 1 ? args[1] : "world";
				Sys.println("Hello, " + name + "!");
			case "version":
				Sys.println("MiroExporter 0.1.0");
			default:
				Sys.println("Unknown command: " + args[0]);
				Sys.println("");
				printHelp();
				Sys.exit(1);
		}
	}

	private function wantsHelp(arg:String):Bool {
		return arg == "help" || arg == "--help" || arg == "-h";
	}

	private function printHelp():Void {
		Sys.println("Haxe C++ CLI Boilerplate");
		Sys.println("");
		Sys.println("Usage:");
		Sys.println("  MiroExporter <command> [arguments]");
		Sys.println("");
		Sys.println("Commands:");
		Sys.println("  hello [name]   Print a greeting");
		Sys.println("  version        Print the application version");
		Sys.println("  help           Show this message");
		Sys.println("");
		Sys.println("Examples:");
		Sys.println("  MiroExporter hello");
		Sys.println("  MiroExporter hello Jonny");
		Sys.println("  MiroExporter version");
	}
}
