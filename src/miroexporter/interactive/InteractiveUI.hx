package miroexporter.interactive;

import sys.net.Host;
import sys.net.Socket;

class InteractiveUI {
    public function new() {
        // Initialization code for the interactive UI
    }

    public function startHttpServer() {
        var clientSocket:Socket;
        var requestLine:String;
        var serverSocket:Socket;

        serverSocket = new Socket();

        try {
            serverSocket.bind(new Host("127.0.0.1"), 1337);
            serverSocket.listen(16);
        } catch (error:Dynamic) {
            USER_MESSAGE_ERROR("Failed to start HTTP server: " + Std.string(error));
            return;
        }

        USER_MESSAGE("HTTP Server available at http://127.0.0.1:1337", true);
        USER_MESSAGE("Registered routes:", true);
        USER_MESSAGE("- GET: http://127.0.0.1:1337/ -> InteractiveUI root page", true);

        while (true) {
            clientSocket = serverSocket.accept();

            try {
                requestLine = clientSocket.input.readLine();
                handleClientRequest(clientSocket, requestLine);
            } catch (error:Dynamic) {
                replyWithStatus(clientSocket, 500, "Internal Server Error", "The server could not handle the request.");
            }

            clientSocket.close();
        }
    }

    private function handleClientRequest(clientSocket:Socket, requestLine:String):Void {
        var method:String;
        var path:String;
        var requestParts:Array<String>;

        requestParts = requestLine.split(" ");

        if (requestParts.length < 2) {
            replyWithStatus(clientSocket, 400, "Bad Request", "Malformed HTTP request.");
            return;
        }

        method = requestParts[0];
        path = getPathWithoutQueryString(requestParts[1]);

        if (method == "GET" && path == "/") {
            replyWithHtml(clientSocket, buildIndexHtml());
            return;
        }

        replyWithStatus(clientSocket, 404, "Not Found", "No route registered for this request.");
    }

    private function getPathWithoutQueryString(fullPath:String):String {
        var pathParts:Array<String>;

        pathParts = fullPath.split("?");

        return pathParts[0];
    }

    private function replyWithHtml(clientSocket:Socket, htmlContent:String):Void {
        reply(clientSocket, 200, "OK", "text/html; charset=utf-8", htmlContent);
    }

    private function replyWithStatus(clientSocket:Socket, statusCode:Int, statusText:String, message:String):Void {
        reply(clientSocket, statusCode, statusText, "text/plain; charset=utf-8", message);
    }

    private function reply(clientSocket:Socket, statusCode:Int, statusText:String, contentType:String, responseBody:String):Void {
        var responseBytesLength:Int;
        var responseHeaders:String;

        responseBytesLength = haxe.io.Bytes.ofString(responseBody).length;
        responseHeaders = "HTTP/1.1 " + statusCode + " " + statusText + "\r\n"
            + "Content-Type: " + contentType + "\r\n"
            + "Content-Length: " + responseBytesLength + "\r\n"
            + "Connection: close\r\n"
            + "\r\n";

        clientSocket.output.writeString(responseHeaders);
        clientSocket.output.writeString(responseBody);
        clientSocket.output.flush();
    }

    private function buildIndexHtml():String {
        return '<!DOCTYPE html>\n'
            + '<html lang="en">\n'
            + '<head>\n'
            + '  <meta charset="utf-8">\n'
            + '  <meta name="viewport" content="width=device-width, initial-scale=1">\n'
            + '  <title>Miro Exporter</title>\n'
            + '  <style>\n'
            + '    body {\n'
            + '      margin: 0;\n'
            + '      font-family: Georgia, "Times New Roman", serif;\n'
            + '      background: #f6f1e8;\n'
            + '      color: #241d16;\n'
            + '    }\n'
            + '    main {\n'
            + '      max-width: 720px;\n'
            + '      margin: 48px auto;\n'
            + '      padding: 0 20px;\n'
            + '    }\n'
            + '    .panel {\n'
            + '      background: #fffdfa;\n'
            + '      border: 1px solid #d9cfbf;\n'
            + '      border-radius: 20px;\n'
            + '      padding: 28px;\n'
            + '      box-shadow: 0 18px 40px rgba(44, 29, 16, 0.08);\n'
            + '    }\n'
            + '    h1 {\n'
            + '      margin: 0 0 12px;\n'
            + '      font-size: 2.6rem;\n'
            + '      line-height: 1.1;\n'
            + '    }\n'
            + '    p {\n'
            + '      margin: 0 0 14px;\n'
            + '      line-height: 1.6;\n'
            + '    }\n'
            + '    code {\n'
            + '      background: #f3e7d7;\n'
            + '      padding: 2px 6px;\n'
            + '      border-radius: 6px;\n'
            + '    }\n'
            + '  </style>\n'
            + '</head>\n'
            + '<body>\n'
            + '  <main>\n'
            + '    <section class="panel">\n'
            + '      <h1>Miro Exporter</h1>\n'
            + '      <p>The HTTP server is running.</p>\n'
            + '      <p>This is the root route at <code>/</code>.</p>\n'
            + '    </section>\n'
            + '  </main>\n'
            + '</body>\n'
            + '</html>\n';
    }
}
