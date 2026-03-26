package hx_webserver;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import sys.FileSystem;
import sys.io.File;
import sys.net.Socket;

using StringTools;

class HTTPRequest {
    public var data:String = null;
    public var headers:Array<Array<String>> = [];
    public var error:String = null;
    public var client:Socket;
    public var postData:String = "";

    private var server:HTTPServer;

    public var methods:Array<String>;

    public function new(socket:Socket, server:HTTPServer, head:String):Void {
        var bodyLength:Int;
        var requestBodyBytes:Bytes;

        if (socket == null) {
            return;
        }

        client = socket;
        this.server = server;

        try {
            methods = head.split(" ");
            readHeaders();
            bodyLength = getContentLength();
            requestBodyBytes = readBodyBytes(bodyLength);
            postData = requestBodyBytes.toString();
            data = buildRawRequestData(requestBodyBytes);
        } catch (caughtError:Dynamic) {
            error = Std.string(caughtError);
        }
    }

    public function getHeaderValue(header:String):String {
        var normalizedHeader:String;

        normalizedHeader = header.toLowerCase();

        for (headerPair in headers) {
            if (headerPair.length >= 2 && headerPair[0].toLowerCase() == normalizedHeader) {
                return headerPair[1];
            }
        }

        return null;
    }

    public function close():Void {
        client.close();
    }

    public function replyData(text:String, mime:String, ?code:Int = 200):Void {
        var response:Bytes;

        @:privateAccess
        response = server.prepareHttpResponse(code, mime, haxe.io.Bytes.ofString(text));
        finishResponse(response);
    }

    public function reply(text:String, ?code:Int = 200):Void {
        var response:Bytes;

        @:privateAccess
        response = server.prepareHttpResponse(code, "text/plain", haxe.io.Bytes.ofString(text));
        finishResponse(response);
    }

    public function replyWithFile(file:String, ?code:Int = 200):Void {
        var bytes:Bytes;
        var mime:String;
        var response:Bytes;

        if (!FileSystem.exists(file)) {
            return;
        }

        bytes = File.getBytes(file);
        mime = HTTPUtils.getMimeType(file);

        @:privateAccess
        response = server.prepareHttpResponse(code, mime, bytes);
        finishResponse(response);
    }

    public function replyRaw(bytes:Bytes):Void {
        finishResponse(bytes);
    }

    private function finishResponse(response:Bytes):Void {
        client.output.writeFullBytes(response, 0, response.length);
        client.output.flush();
        client.close();
    }

    private function readHeaders():Void {
        var headerLine:String;
        var separatorIndex:Int;

        while (true) {
            headerLine = client.input.readLine();

            if (headerLine == null || headerLine == "") {
                break;
            }

            separatorIndex = headerLine.indexOf(":");

            if (separatorIndex == -1) {
                continue;
            }

            headers.push([
                headerLine.substr(0, separatorIndex),
                StringTools.trim(headerLine.substr(separatorIndex + 1))
            ]);
        }
    }

    private function getContentLength():Int {
        var contentLengthHeader:String;

        contentLengthHeader = getHeaderValue("Content-Length");

        if (contentLengthHeader == null || contentLengthHeader == "") {
            return 0;
        }

        return Std.parseInt(contentLengthHeader);
    }

    private function readBodyBytes(bodyLength:Int):Bytes {
        var bodyBytes:Bytes;
        var bytesRead:Int;
        var totalBytesRead:Int;

        if (bodyLength <= 0) {
            return Bytes.alloc(0);
        }

        bodyBytes = Bytes.alloc(bodyLength);
        totalBytesRead = 0;

        while (totalBytesRead < bodyLength) {
            bytesRead = client.input.readBytes(bodyBytes, totalBytesRead, bodyLength - totalBytesRead);

            if (bytesRead <= 0) {
                throw "Unexpected end of request body.";
            }

            totalBytesRead += bytesRead;
        }

        return bodyBytes;
    }

    private function buildRawRequestData(requestBodyBytes:Bytes):String {
        var buffer:BytesBuffer;

        buffer = new BytesBuffer();

        for (headerPair in headers) {
            if (headerPair.length >= 2) {
                buffer.addString(headerPair[0] + ": " + headerPair[1] + "\r\n");
            }
        }

        buffer.addString("\r\n");
        buffer.addBytes(requestBodyBytes, 0, requestBodyBytes.length);

        return buffer.getBytes().toString();
    }
}
