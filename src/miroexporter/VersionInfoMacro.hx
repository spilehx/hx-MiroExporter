package miroexporter;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class VersionInfoMacro {
    public static macro function getBuildVersion():ExprOf<String> {
        var applicationVersion:String;

        applicationVersion = Context.definedValue("app_version");

        if (applicationVersion == null || applicationVersion == "") {
            applicationVersion = "dev";
        }

        return macro $v{applicationVersion};
    }
}
