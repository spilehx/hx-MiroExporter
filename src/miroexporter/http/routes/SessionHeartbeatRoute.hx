package miroexporter.http.routes;

import haxe.Json;
import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;
import miroexporter.interactive.InteractiveSessionTracker;

class SessionHeartbeatRoute extends Route {
    public function new() {
        super("/session-heartbeat", new RestDataObject(), "POST");
    }

    override public function handle(request:Request) {
        var requestData:Dynamic;
        var sessionId:String;

        try {
            requestData = Json.parse(request.postdata);
        } catch (error:Dynamic) {
            request.reply("Invalid heartbeat request.", 400);
            return;
        }

        sessionId = Std.string(requestData.sessionId);

        if (sessionId == null || sessionId == "" || sessionId == "null") {
            request.reply("Missing sessionId.", 400);
            return;
        }

        InteractiveSessionTracker.recordHeartbeat(sessionId);
        request.replyWithJSON({
            success: true
        });
    }
}
