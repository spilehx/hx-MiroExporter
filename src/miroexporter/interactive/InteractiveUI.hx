package miroexporter.interactive;

import miroexporter.http.HTTPServer;
import miroexporter.http.routes.FileRoute;
import miroexporter.http.routes.IndexRoute;
import miroexporter.http.routes.UploadRoute;
import sys.thread.Thread;

class InteractiveUI {
    public function new() {
        // Initialization code for the interactive UI
    }

    public function startHttpServer() {
        Thread.runWithEventLoop(function() {
            var httpServer:HTTPServer;

            httpServer = HTTPServer.instance;
            httpServer.addRoute(IndexRoute);
            httpServer.addRoute(UploadRoute);
            httpServer.addRoute(FileRoute);
            httpServer.startServer();
        });
    }
}
