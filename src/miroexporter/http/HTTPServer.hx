package miroexporter.http;

class HTTPServer {
	private var server:hx_webserver.HTTPServer;
	private var routeClasses:Array<Class<Route>>;

	public var routes:Array<Route>;

	private var port:Int;

	public static final instance:HTTPServer = new HTTPServer();

	// private for singleton use only
	private function new() {
		routeClasses = new Array<Class<Route>>();
		routes = new Array<Route>();
	}

	public function startServer(?port:Int = 1337) {
		this.port = port;
		instantiateRoutes();
		server = new hx_webserver.HTTPServer("0.0.0.0", port, false /*, false*/);
		server.onClientConnect = function(r:hx_webserver.HTTPRequest) {
			onClientConnect(new Request(r));
		};
	}

	private function onClientConnect(request:Request) {
		var route:Route = getRoute(request);
		if (route != null) {
			route.handle(request);
		} else {
			USER_MESSAGE_WARN("404: " + request.method + ":" + request.path);
			request.reply404();
		}
	}

	private function getRoute(request:Request):Route {
		for (route in routes) {
			if (request.method == route.method) {
				if (request.path == route.path) {
					return route;
				}
			}
		}

		return null;
	}

	public function stopServer() {
		LOG_ERROR("NOT IMPLEMENTED");
	}

	public function addRoute(routeClass:Class<Route>) {
		routeClasses.push(routeClass);
	}

	private function instantiateRoutes() {
		for (routeClass in routeClasses) {
			var route:Route = Type.createInstance(routeClass, []);
			if (validNewRoute(route)) {
				routes.push(route);
			} else {
				USER_MESSAGE_ERROR("Won't instantiate route: " + Type.getClassName(routeClass));
				Sys.exit(1);
			}
		}

		USER_MESSAGE("Finished instantiating " + routes.length + " routes", true);
		USER_MESSAGE("HTTP Server available at http//localhost:" + port, true);
		USER_MESSAGE("Registered routes:", true);
		for (route in routes) {
			USER_MESSAGE("- " + route.method + ": http//localhost:" + port + route.path + " -> " + Type.getClassName(Type.getClass(route)), true);
		}	
	}

	private function validNewRoute(route:Route):Bool {

		// Check if the route with same path has already been registered, if so log an error and return false.
		if (hasRouteWithFieldValueAlreadyBeenAdded(route, "path")) {
			USER_MESSAGE_ERROR("Route with path '" + route.path + "' has already been registered, cannot register route: " + Type.getClassName(Type.getClass(route)));
			return false;
		}

		// check if route with same class name has already been registered, if so log an error and return false.
		for(registeredRoute in routes) {
			if (Type.getClassName(Type.getClass(registeredRoute)) == Type.getClassName(Type.getClass(route))) {
				USER_MESSAGE_ERROR("Route with class name '" + Type.getClassName(Type.getClass(route)) + "' has already been registered, cannot register route: " + Type.getClassName(Type.getClass(route)));
				return false;
			}
		}

		// check if method is valid, if not log an error and return false.
		if (Route.VALID_METHODS.indexOf(route.method) == -1) {
			USER_MESSAGE_ERROR("Route method '" + route.method + "' is not valid for route: " + Type.getClassName(Type.getClass(route)));
			return false;
		}

		return true;
	}

	private function hasRouteWithFieldValueAlreadyBeenAdded(route:Route, fieldName:String):Bool {

		for(registeredRoute in routes) {
			var routeFieldValue = Reflect.field(registeredRoute, fieldName);
			var fieldValue = Reflect.field(route, fieldName);
			if (routeFieldValue != null && routeFieldValue == fieldValue) {
				return true;
			}
		}

		return false;
	}
}
