package miroexporter.interactive;

import miroexporter.http.HTTPServer;
import miroexporter.http.routes.DeleteExportRoute;
import miroexporter.http.routes.FileRoute;
import miroexporter.http.routes.IndexRoute;
import miroexporter.http.routes.OpenResourcesFolderRoute;
import miroexporter.http.routes.SessionDisconnectRoute;
import miroexporter.http.routes.SessionHeartbeatRoute;
import miroexporter.http.routes.UploadRoute;
import miroexporter.interactive.InteractiveExportRepository.InteractiveExportRecord;
import sys.net.Host;
import sys.net.Socket;
import sys.thread.Thread;

class InteractiveUI {
    private static final DEFAULT_HTTP_PORT:Int = 1337;

    public function new() {
        // Initialization code for the interactive UI
    }

    public function startHttpServer() {
        var availableExports:Array<InteractiveExportRecord>;
        var serverUrl:String;

        availableExports = InteractiveExportRepository.findAvailableExports();
        USER_MESSAGE_INFO("Discovered " + availableExports.length + " existing exported RTB summaries.");
        serverUrl = buildServerUrl(DEFAULT_HTTP_PORT);

        if (isInteractiveServerAlreadyRunning(DEFAULT_HTTP_PORT)) {
            USER_MESSAGE_INFO("Interactive server is already running. Opening browser only.");
            openUrlInDefaultBrowser(serverUrl);
            return;
        }

        Thread.runWithEventLoop(function() {
            var httpServer:HTTPServer;

            InteractiveSessionTracker.startWatchdog();
            httpServer = HTTPServer.instance;
            httpServer.addRoute(IndexRoute);
            httpServer.addRoute(UploadRoute);
            httpServer.addRoute(DeleteExportRoute);
            httpServer.addRoute(OpenResourcesFolderRoute);
            httpServer.addRoute(SessionHeartbeatRoute);
            httpServer.addRoute(SessionDisconnectRoute);
            httpServer.addRoute(FileRoute);
            httpServer.startServer(DEFAULT_HTTP_PORT);
            openBrowserWhenServerIsReady(serverUrl);
        });
    }

    private function buildServerUrl(port:Int):String {
        return "http://localhost:" + port + "/";
    }

    private function isInteractiveServerAlreadyRunning(port:Int):Bool {
        var socket:Socket;

        socket = new Socket();

        try {
            socket.connect(new Host("127.0.0.1"), port);
            socket.close();
            return true;
        } catch (error:Dynamic) {
            try {
                socket.close();
            } catch (closeError:Dynamic) {
            }

            return false;
        }
    }

    private function openBrowserWhenServerIsReady(serverUrl:String):Void {
        Thread.create(function() {
            Sys.sleep(0.5);
            openUrlInDefaultBrowser(serverUrl);
        });
    }

    private function openUrlInDefaultBrowser(serverUrl:String):Void {
        var command:String;
        var systemName:String;

        systemName = Sys.systemName();
        command = buildOpenBrowserCommand(systemName, serverUrl);

        if (command == "") {
            USER_MESSAGE_WARN("Could not determine how to open the browser automatically on this platform: " + systemName);
            return;
        }

        USER_MESSAGE_INFO("Opening interactive UI in browser: " + serverUrl);
        Sys.command(command);
    }

    private function buildOpenBrowserCommand(systemName:String, serverUrl:String):String {
        if (systemName == "Linux") {
            return 'xdg-open "' + serverUrl + '"';
        }

        if (systemName == "Mac") {
            return 'open "' + serverUrl + '"';
        }

        if (systemName == "Windows") {
            return 'cmd /c start "" "' + serverUrl + '"';
        }

        return "";
    }
}
