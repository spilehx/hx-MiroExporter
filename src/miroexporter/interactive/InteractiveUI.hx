package miroexporter.interactive;

import miroexporter.http.HTTPServer;
import miroexporter.http.routes.DeleteExportRoute;
import miroexporter.http.routes.FileRoute;
import miroexporter.http.routes.IndexRoute;
import miroexporter.http.routes.UploadRoute;
import miroexporter.interactive.InteractiveExportRepository.InteractiveExportRecord;
import sys.thread.Thread;

class InteractiveUI {
    public function new() {
        // Initialization code for the interactive UI
    }

    public function startHttpServer() {
        var availableExports:Array<InteractiveExportRecord>;

        availableExports = InteractiveExportRepository.findAvailableExports();
        USER_MESSAGE_INFO("Discovered " + availableExports.length + " existing exported RTB summaries.");

        Thread.runWithEventLoop(function() {
            var httpServer:HTTPServer;

            httpServer = HTTPServer.instance;
            httpServer.addRoute(IndexRoute);
            httpServer.addRoute(UploadRoute);
            httpServer.addRoute(DeleteExportRoute);
            httpServer.addRoute(FileRoute);
            httpServer.startServer();
        });
    }
}
