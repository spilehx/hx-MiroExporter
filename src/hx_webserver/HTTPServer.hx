package hx_webserver;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import hx_webserver.HTTPRequest;
import hx_webserver.HTTPUtils;
import sys.net.Host;
import sys.net.Socket;

using StringTools;

class HTTPServer {
    private var ip:String = null;
    private var port:Int = 0;
    private var log:Bool = false;
    public var server:sys.net.Socket;
    private var on:Bool = true;

    public function new(ip:String, port:Int, ?log:Bool) {
        this.ip = ip;
        this.port = port;

        if (log == null) {
            this.log = false;
        } else {
            this.log = log;
        }

        on = true;
        haxe.EntryPoint.addThread(start);
    }

    dynamic public function onClientConnect(d:HTTPRequest) {
    }

    private function start() {
        server = new Socket();

        try {
            server.bind(new Host(ip), port);
        } catch (err:String) {
            throw "Cannot bind to " + ip + ":" + port + ", perhaps the port is already being used?\n" + err;
        }

        server.listen(1024);

        if (log) {
            trace("HTTP server successfully initialized at " + ip + ":" + port);
        }

        while (on) {
            try {
                var client:Socket;
                var head:String;

                client = server.accept();
                head = client.input.readLine();

                if (head.contains("HTTP/1.1") || head.contains("HTTP/1.0")) {
                    sys.thread.Thread.create(() -> {
                        var request:HTTPRequest;

                        request = new HTTPRequest(client, this, head);
                        onClientConnect(request);

                        if (log) {
                            trace("A new connection has been detected");
                        }
                    });
                } else {
                    client.close();
                }
            } catch (err:Dynamic) {
                if (this.log) {
                    trace("An error has occurred: " + err);
                }
            }
        }
    }

    private function prepareHttpResponse(code:Int, mime:String, value:Bytes):Bytes {
        var bytesOutput:BytesOutput;
        var statusLine:String;

        bytesOutput = new BytesOutput();
        statusLine = "HTTP/1.1 " + code + " " + HTTPUtils.codeToMessage(code);

        bytesOutput.writeString(statusLine);
        bytesOutput.writeString("\r\n");
        bytesOutput.writeString("Content-Length: " + value.length);
        bytesOutput.writeString("\r\n");
        bytesOutput.writeString("Content-Type: " + mime);
        bytesOutput.writeString("\r\n");
        bytesOutput.writeString("Access-Control-Allow-Origin: *");
        bytesOutput.writeString("\r\n");
        bytesOutput.writeString("\r\n");
        bytesOutput.writeBytes(value, 0, value.length);

        return bytesOutput.getBytes();
    }
}
