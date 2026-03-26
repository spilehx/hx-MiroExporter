package miroexporter;

#if macro
import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
#end

class EmbeddedAssetsMacro {
    public static macro function embedInstallerIcon():ExprOf<String> {
        var iconFilePath:String;

        iconFilePath = "resources/icon.png";

        try {
            Context.addResource("installer_icon", File.getBytes(iconFilePath));
        } catch (error:Dynamic) {
            Context.error("Could not embed installer icon from " + iconFilePath + ": " + Std.string(error), Context.currentPos());
        }

        return macro "installer_icon";
    }
}
