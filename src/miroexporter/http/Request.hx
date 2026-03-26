package miroexporter.http;

import haxe.Json;
import haxe.io.Bytes;

class Request {
	#if !js
	@:isVar public var method(get, null):String;
	@:isVar public var path(get, null):String;
	@:isVar public var fullPath(get, null):String;
	@:isVar public var postdata(get, null):String;

	
	private var httpRequest:hx_webserver.HTTPRequest;

	public function new(httpRequest:hx_webserver.HTTPRequest) {
		this.httpRequest = httpRequest;
	}

	public function reply(text:String, ?code:Int = 200):Void {
		this.httpRequest.reply(text, code);
	}

	public function replyWithFile(file:String, ?code:Int = 200):Void {
		this.httpRequest.replyWithFile(file, code);
	}

	public function replyWithHTML(content:String, ?code:Int = 200):Void {
		this.httpRequest.replyData(content, "text/html", code);
	}

	public function reply404():Void {
		this.httpRequest.reply("404", 404);
	}

	public function replyWithJSON(content:Dynamic):Void {
		this.httpRequest.replyData(Json.stringify(content), "application/json", 200);
	}

	public function replyData(text:String, mime:String, ?code:Int = 200):Void {
		this.httpRequest.replyData(text, mime, code);
	}

	public function replyRaw(bytes:haxe.io.Bytes) {
		this.httpRequest.replyRaw(bytes);
	}

	public function getUrlParam(key:String):String {
		var pathComponents:Array<String> = this.fullPath.split("?");

		if (pathComponents.length == 2) {
			var params:Array<String> = pathComponents[1].split("&");

			for (param in params) {
				var parmaComponents:Array<String> = param.split("=");
				if (parmaComponents.length == 2) {
					var paramKey:String = parmaComponents[0];
					var value:String = parmaComponents[1];
					if (paramKey == key) {
						return value;
					}
				}
			}
		}

		return "";
	}

	public function close():Void {
		this.httpRequest.close();
	}

	public function getHeaderValue(header:String):String {
		return this.httpRequest.getHeaderValue(header);
	}

	

	function get_method():String {
		return this.httpRequest.methods[0];
	}

	function get_postdata():String {
		return this.httpRequest.postData;
	}

	function get_fullPath():String {
		return this.httpRequest.methods[1];
	}

	function get_path():String {
		var pathComponents:Array<String> = this.fullPath.split("?");
		return pathComponents[0];
	}
	#end
}
