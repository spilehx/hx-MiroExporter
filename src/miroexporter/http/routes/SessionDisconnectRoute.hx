package miroexporter.http.routes;

import haxe.Json;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveSessionTracker;

class SessionDisconnectRoute extends Route {
    public function new() {
        super("/session-disconnect", new RestDataObject(), "POST");
    }

    override public function handle(request:Request) {
        var requestData:Dynamic;
        var sessionId:String;

        try {
            requestData = Json.parse(request.postdata);
        } catch (error:Dynamic) {
            request.reply("Invalid disconnect request.", 400);
            return;
        }

        sessionId = Std.string(requestData.sessionId);

        if (sessionId == null || sessionId == "" || sessionId == "null") {
            request.reply("Missing sessionId.", 400);
            return;
        }

        InteractiveSessionTracker.disconnectSession(sessionId);
        request.replyWithJSON({
            success: true
        });
    }
}
