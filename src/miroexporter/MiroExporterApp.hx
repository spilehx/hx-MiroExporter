package miroexporter;

import miroexporter.interactive.InteractiveUI;
import miroexporter.exporter.Exporter;
import haxe.Resource;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class MiroExporterApp {
	private static final INSTALLED_BINARY_PATH:String = "/usr/local/bin/MiroExporter";
	private static final INSTALLED_ICON_PATH:String = "/usr/local/share/icons/hicolor/256x256/apps/miroexporter.png";
	private static final INSTALLED_DESKTOP_ENTRY_PATH:String = "/usr/share/applications/miroexporter.desktop";

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
			case "install":
				runInstall();
			case "uninstall":
				runUninstall();
			case "version":
				USER_MESSAGE("MiroExporter " + VersionInfo.APPLICATION_VERSION, true);
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

	private function runInstall():Void {
		var currentExecutablePath:String;
		var installExitCode:Int;

		if (Sys.systemName() != "Linux") {
			USER_MESSAGE_ERROR("The install command is currently only supported on Ubuntu/Linux.");
			Sys.exit(1);
		}

		currentExecutablePath = getCurrentExecutablePath();

		if (currentExecutablePath == "") {
			USER_MESSAGE_ERROR("Could not determine the current executable path.");
			Sys.exit(1);
		}

		if (!FileSystem.exists(currentExecutablePath)) {
			USER_MESSAGE_ERROR("Current executable not found: " + currentExecutablePath);
			Sys.exit(1);
		}

		if (Path.normalize(currentExecutablePath) == Path.normalize(INSTALLED_BINARY_PATH)) {
			USER_MESSAGE_INFO("MiroExporter is already installed at " + INSTALLED_BINARY_PATH);
			return;
		}

		USER_MESSAGE_INFO("Installing MiroExporter to " + INSTALLED_BINARY_PATH);
		USER_MESSAGE_INFO("You may be prompted by sudo for your password.");

		installExitCode = Sys.command("sudo", [
			"install",
			"-m",
			"755",
			currentExecutablePath,
			INSTALLED_BINARY_PATH
		]);

		if (installExitCode != 0) {
			USER_MESSAGE_ERROR("Installation failed with exit code " + installExitCode);
			Sys.exit(installExitCode);
		}

		installExitCode = installIconFile();

		if (installExitCode != 0) {
			USER_MESSAGE_ERROR("Icon installation failed with exit code " + installExitCode);
			Sys.exit(installExitCode);
		}

		installExitCode = installDesktopEntry();

		if (installExitCode != 0) {
			USER_MESSAGE_ERROR("Desktop launcher installation failed with exit code " + installExitCode);
			Sys.exit(installExitCode);
		}

		USER_MESSAGE_INFO("Installation complete. You can now run: MiroExporter");
	}

	private function runUninstall():Void {
		var uninstallExitCode:Int;

		if (Sys.systemName() != "Linux") {
			USER_MESSAGE_ERROR("The uninstall command is currently only supported on Ubuntu/Linux.");
			Sys.exit(1);
		}

		if (!isInstalled()) {
			USER_MESSAGE_INFO("MiroExporter is not currently installed.");
			return;
		}

		USER_MESSAGE_INFO("Uninstalling MiroExporter from the system.");
		USER_MESSAGE_INFO("You may be prompted by sudo for your password.");

		uninstallExitCode = uninstallInstalledFiles();

		if (uninstallExitCode != 0) {
			USER_MESSAGE_ERROR("Uninstall failed with exit code " + uninstallExitCode);
			Sys.exit(uninstallExitCode);
		}

		USER_MESSAGE_INFO("Uninstall complete.");
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

	private function getCurrentExecutablePath():String {
		return Path.normalize(Sys.programPath());
	}

	private function installIconFile():Int {
		var createDirectoryExitCode:Int;
		var embeddedIconBytes:haxe.io.Bytes;
		var installIconExitCode:Int;
		var temporaryDirectoryPath:String;
		var temporaryIconPath:String;

		USER_MESSAGE_INFO("Installing application icon to " + INSTALLED_ICON_PATH);

		embeddedIconBytes = Resource.getBytes(EmbeddedAssets.INSTALLER_ICON_RESOURCE_NAME);

		if (embeddedIconBytes == null || embeddedIconBytes.length == 0) {
			USER_MESSAGE_ERROR("Embedded installer icon could not be loaded from the binary.");
			return 1;
		}

		createDirectoryExitCode = Sys.command("sudo", [
			"mkdir",
			"-p",
			Path.directory(INSTALLED_ICON_PATH)
		]);

		if (createDirectoryExitCode != 0) {
			return createDirectoryExitCode;
		}

		temporaryDirectoryPath = Sys.getEnv("TMPDIR") != null && Sys.getEnv("TMPDIR") != "" ? Sys.getEnv("TMPDIR") : "/tmp";
		temporaryIconPath = Path.normalize(Path.join([temporaryDirectoryPath, "miroexporter-icon.png"]));
		File.saveBytes(temporaryIconPath, embeddedIconBytes);

		installIconExitCode = Sys.command("sudo", [
			"install",
			"-m",
			"644",
			temporaryIconPath,
			INSTALLED_ICON_PATH
		]);

		if (FileSystem.exists(temporaryIconPath)) {
			FileSystem.deleteFile(temporaryIconPath);
		}

		return installIconExitCode;
	}

	private function installDesktopEntry():Int {
		var desktopEntryContent:String;
		var installDesktopEntryExitCode:Int;
		var temporaryDesktopEntryPath:String;
		var temporaryDirectoryPath:String;

		desktopEntryContent = buildDesktopEntryContent();
		temporaryDirectoryPath = Sys.getEnv("TMPDIR") != null && Sys.getEnv("TMPDIR") != "" ? Sys.getEnv("TMPDIR") : "/tmp";
		temporaryDesktopEntryPath = Path.normalize(Path.join([temporaryDirectoryPath, "miroexporter.desktop"]));
		File.saveContent(temporaryDesktopEntryPath, desktopEntryContent);

		USER_MESSAGE_INFO("Installing GNOME launcher to " + INSTALLED_DESKTOP_ENTRY_PATH);
		installDesktopEntryExitCode = Sys.command("sudo", [
			"install",
			"-m",
			"644",
			temporaryDesktopEntryPath,
			INSTALLED_DESKTOP_ENTRY_PATH
		]);

		if (FileSystem.exists(temporaryDesktopEntryPath)) {
			FileSystem.deleteFile(temporaryDesktopEntryPath);
		}

		return installDesktopEntryExitCode;
	}

	private function buildDesktopEntryContent():String {
		return "[Desktop Entry]\n"
			+ "Version=1.0\n"
			+ "Type=Application\n"
			+ "Name=MiroExporter\n"
			+ "Comment=Open the MiroExporter interactive viewer\n"
			+ "Exec=" + INSTALLED_BINARY_PATH + " interactive\n"
			+ "Icon=" + INSTALLED_ICON_PATH + "\n"
			+ "Terminal=false\n"
			+ "Categories=Utility;\n";
	}

	private function uninstallInstalledFiles():Int {
		return Sys.command("sudo", [
			"rm",
			"-f",
			INSTALLED_BINARY_PATH,
			INSTALLED_DESKTOP_ENTRY_PATH,
			INSTALLED_ICON_PATH
		]);
	}

	private function isInstalled():Bool {
		return FileSystem.exists(INSTALLED_BINARY_PATH)
			|| FileSystem.exists(INSTALLED_DESKTOP_ENTRY_PATH)
			|| FileSystem.exists(INSTALLED_ICON_PATH);
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
		USER_MESSAGE("  install                      Install the app globally on Ubuntu/Linux");
		USER_MESSAGE("  uninstall                    Remove the installed app and menu entry");
		USER_MESSAGE("  version                      Print the application version");
		USER_MESSAGE("  help                         Show this message");
		USER_MESSAGE("");
		USER_MESSAGE_INFO("Examples:");
		USER_MESSAGE("  MiroExporter extract ./board.rtb");
		USER_MESSAGE("  MiroExporter install");
		USER_MESSAGE("  MiroExporter uninstall");
		USER_MESSAGE("  MiroExporter version");
	}
}
