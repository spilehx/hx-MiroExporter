package miroexporter;

import haxe.io.Path;
import sys.FileSystem;

class AppPaths {
    private static final APPLICATION_DIRECTORY_NAME:String = "MiroExporter";
    private static final INTERACTIVE_UPLOADS_DIRECTORY_NAME:String = "interactive_uploads";

    public static function getApplicationDataDirectoryPath():String {
        var homeDirectoryPath:String;

        homeDirectoryPath = Sys.getEnv("HOME");

        if (homeDirectoryPath == null || homeDirectoryPath == "") {
            homeDirectoryPath = Sys.getCwd();
        }

        return Path.normalize(Path.join([homeDirectoryPath, APPLICATION_DIRECTORY_NAME]));
    }

    public static function getInteractiveUploadsDirectoryPath():String {
        return Path.join([getApplicationDataDirectoryPath(), INTERACTIVE_UPLOADS_DIRECTORY_NAME]);
    }

    public static function ensureApplicationDataDirectoryExists():Void {
        var applicationDataDirectoryPath:String;

        applicationDataDirectoryPath = getApplicationDataDirectoryPath();

        if (!FileSystem.exists(applicationDataDirectoryPath)) {
            FileSystem.createDirectory(applicationDataDirectoryPath);
        }
    }

    public static function ensureInteractiveUploadsDirectoryExists():Void {
        var interactiveUploadsDirectoryPath:String;

        ensureApplicationDataDirectoryExists();
        interactiveUploadsDirectoryPath = getInteractiveUploadsDirectoryPath();

        if (!FileSystem.exists(interactiveUploadsDirectoryPath)) {
            FileSystem.createDirectory(interactiveUploadsDirectoryPath);
        }
    }
}
