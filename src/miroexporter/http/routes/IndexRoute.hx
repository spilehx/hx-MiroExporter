package miroexporter.http.routes;

import miroexporter.http.Request;
import miroexporter.http.RestDataObject;
import miroexporter.http.Route;

class IndexRoute extends Route {
    public function new() {
        super("/", new RestDataObject(), "GET");
    }

    override public function handle(request:Request) {
        request.replyWithHTML(buildHtmlPage());
    }

    private function buildHtmlPage():String {
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
