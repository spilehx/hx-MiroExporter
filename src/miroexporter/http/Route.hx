package miroexporter.http;

import haxe.Json;

class Route {
	static var GET_METHOD:String = "GET";
	static var POST_METHOD:String = "POST";

	// static var PUT_METHOD:String = "PUT"; //not implemented yet
	// static var HEAD_METHOD:String = "HEAD"; //not implemented yet
	public static final VALID_METHODS:Array<String> = [GET_METHOD, POST_METHOD /*, PUT_METHOD, HEAD_METHOD*/];

	@:isVar public var path(default, null):String;
	@:isVar public var method(default, null):String;
	public var dataObjectClassName:String;
	public var dataObjectClass:Class<RestDataObject>;

	public function new(path:String, dataObject:RestDataObject, methodType:String) {
		this.path = path;
		this.dataObjectClass = Type.getClass(dataObject);
		this.method = methodType;
	}

	public function handle(request:miroexporter.http.Request) {
		USER_MESSAGE("Request: " + request.method + ":" + request.path);
		onRequest(request);
	}

	private function onRequest(request:miroexporter.http.Request) {
		var genericRequestDataObject:RestDataObject = new RestDataObject();
		var requestDataObjectInstance = Type.createInstance(dataObjectClass, []);
	}

	private function parseData(data:String, targetClass:Class<RestDataObject>):RestDataObject {
		var inputDataObject:Dynamic = Json.parse(data);

		var targetObject = Type.createInstance(targetClass, []);
		var targetObjectFields:Array<String> = Reflect.fields(targetObject);

		for (targetObjectField in targetObjectFields) {
			// TODO: As this could be unsafe, shall we put a try catch here?

			if (Reflect.hasField(inputDataObject, targetObjectField)) {
				Reflect.setField(targetObject, targetObjectField, Reflect.getProperty(inputDataObject, targetObjectField));
			}
		}
		return targetObject;
	}
}
