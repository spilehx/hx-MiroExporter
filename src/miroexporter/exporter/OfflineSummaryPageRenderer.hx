package miroexporter.exporter;

class OfflineSummaryPageRenderer {
    public function new() {
    }

    public function render(boardInfo:Dynamic, resourceManifest:Dynamic, boardInfoUrl:String, resourceManifestUrl:String, resourceUrlPrefix:String, encodeResourcePaths:Bool, ?openResourcesFolderUrl:String, ?extraScriptMarkup:String):String {
        var boardDescription:String;
        var boardTitle:String;
        var resourcesHeaderActionsMarkup:String;
        var resourceCardsMarkup:String;

        boardTitle = htmlEscape(Std.string(boardInfo.board.name));
        boardDescription = htmlEscape(Std.string(boardInfo.board.description));
        resourcesHeaderActionsMarkup = buildResourcesHeaderActionsMarkup(openResourcesFolderUrl);
        resourceCardsMarkup = buildResourceCardsMarkup(resourceManifest.resources, resourceUrlPrefix, encodeResourcePaths);

        return '<!DOCTYPE html>\n'
            + '<html lang="en">\n'
            + '<head>\n'
            + '  <meta charset="utf-8">\n'
            + '  <meta name="viewport" content="width=device-width, initial-scale=1">\n'
            + '  <title>' + boardTitle + ' - Offline Export</title>\n'
            + '  <style>\n'
            + buildStyles()
            + '  </style>\n'
            + '</head>\n'
            + '<body>\n'
            + '  <main class="page">\n'
            + '    <header class="hero">\n'
            + '      <div>\n'
            + '        <p class="eyebrow">Miro RTB Offline Export</p>\n'
            + '        <h1>' + boardTitle + '</h1>\n'
            + '        <p class="subtitle">' + buildBoardSubtitle(boardInfo) + '</p>\n'
            + '      </div>\n'
            + '      <div class="actions">\n'
            + '        <a href="' + htmlEscape(boardInfoUrl) + '">board-info.json</a>\n'
            + '        <a href="' + htmlEscape(resourceManifestUrl) + '">resource-manifest.json</a>\n'
            + '      </div>\n'
            + '    </header>\n'
            + '    <section class="section">\n'
            + '      <h2>Overview</h2>\n'
            + '      <div class="stats">\n'
            + buildStatCard("Supported resources", Std.string(boardInfo.resourcesSummary.supportedOfflineResources))
            + buildStatCard("Images", Std.string(boardInfo.resourcesSummary.images))
            + buildStatCard("Vectors", Std.string(boardInfo.resourcesSummary.vectors))
            + buildStatCard("Videos", Std.string(boardInfo.resourcesSummary.videos))
            + '      </div>\n'
            + '      <div class="meta-grid">\n'
            + buildMetaItem("Board ID", Std.string(boardInfo.board.id))
            + buildMetaItem("Icon Resource ID", Std.string(boardInfo.board.iconResourceId))
            + buildMetaItem("Archive Version", Std.string(boardInfo.archive.version))
            + buildMetaItem("Encryption Version", Std.string(boardInfo.archive.encryptionVersion))
            + buildMetaItem("Timestamp (Unix)", Std.string(boardInfo.archive.timestampUnix))
            + buildMetaItem("Public", Std.string(boardInfo.board.isPublic))
            + '      </div>\n'
            + '      <div class="note">\n'
            + '        <strong>Description:</strong> ' + (boardDescription == "" ? "No description provided." : boardDescription) + '\n'
            + '      </div>\n'
            + '      <div class="note warn">\n'
            + '        <strong>Limitations:</strong> Board layout and canvas objects are not reconstructed because the main canvas payload is not readable from the exported RTB data.\n'
            + '      </div>\n'
            + '    </section>\n'
            + '    <section class="section">\n'
            + '      <div class="section-header">\n'
            + '        <h2>Resources</h2>\n'
            + resourcesHeaderActionsMarkup
            + '      </div>\n'
            + '      <div class="resource-grid">\n'
            + resourceCardsMarkup
            + '      </div>\n'
            + '    </section>\n'
            + '  </main>\n'
            + buildClientScript(openResourcesFolderUrl)
            + (extraScriptMarkup == null ? "" : extraScriptMarkup)
            + '</body>\n'
            + '</html>\n';
    }

    private function buildBoardSubtitle(boardInfo:Dynamic):String {
        var archiveVersion:String;
        var boardVisibility:String;

        archiveVersion = htmlEscape(Std.string(boardInfo.archive.version));
        boardVisibility = Std.string(boardInfo.board.isPublic) == "true" ? "Public board" : "Private board";

        return boardVisibility + " | RTB archive version " + archiveVersion;
    }

    private function buildStatCard(label:String, value:String):String {
        return '        <article class="stat-card">\n'
            + '          <p class="stat-label">' + htmlEscape(label) + '</p>\n'
            + '          <p class="stat-value">' + htmlEscape(value) + '</p>\n'
            + '        </article>\n';
    }

    private function buildMetaItem(label:String, value:String):String {
        return '        <div class="meta-item">\n'
            + '          <span class="meta-label">' + htmlEscape(label) + '</span>\n'
            + '          <span class="meta-value">' + htmlEscape(value) + '</span>\n'
            + '        </div>\n';
    }

    private function buildResourceCardsMarkup(resources:Dynamic, resourceUrlPrefix:String, encodeResourcePaths:Bool):String {
        var markup:String;

        markup = "";

        for (resource in cast(resources, Array<Dynamic>)) {
            markup += buildResourceCardMarkup(resource, resourceUrlPrefix, encodeResourcePaths);
        }

        if (markup == "") {
            return '        <p>No supported resources were exported.</p>\n';
        }

        return markup;
    }

    private function buildResourcesHeaderActionsMarkup(openResourcesFolderUrl:String):String {
        if (openResourcesFolderUrl == null || openResourcesFolderUrl == "") {
            return "";
        }

        return '        <div class="section-actions">\n'
            + '          <button id="showAllResourcesButton" type="button" class="action-button" data-open-folder-url="' + htmlEscape(openResourcesFolderUrl) + '">Show all</button>\n'
            + '        </div>\n';
    }

    private function buildResourceCardMarkup(resource:Dynamic, resourceUrlPrefix:String, encodeResourcePaths:Bool):String {
        var previewMarkup:String;
        var resourceUrl:String;
        var resourceRelativePath:String;

        resourceRelativePath = "resources/" + Std.string(resource.exportedFileName);
        resourceUrl = buildResourceUrl(resourceUrlPrefix, resourceRelativePath, encodeResourcePaths);
        previewMarkup = buildPreviewMarkup(resourceUrl, Std.string(resource.category), Std.string(resource.originalFileName));

        return '        <article class="resource-card">\n'
            + '          <div class="preview">\n'
            + previewMarkup
            + '          </div>\n'
            + '          <div class="resource-body">\n'
            + '            <h3>' + htmlEscape(Std.string(resource.originalFileName)) + '</h3>\n'
            + '            <p class="resource-type">' + htmlEscape(Std.string(resource.category)) + ' | ' + htmlEscape(Std.string(resource.mimeType)) + '</p>\n'
            + '            <dl class="details">\n'
            + buildDetailRow("Resource ID", Std.string(resource.id))
            + buildDetailRow("Exported file", Std.string(resource.exportedFileName))
            + buildDetailRow("File size", formatFileSize(Std.int(resource.fileSizeBytes)))
            + buildDetailRow("Raw path", Std.string(resource.rawPath))
            + '            </dl>\n'
            + '            <div class="resource-links">\n'
            + '              <a href="' + htmlEscape(resourceUrl) + '">Open file</a>\n'
            + '            </div>\n'
            + '          </div>\n'
            + '        </article>\n';
    }

    private function buildResourceUrl(resourceUrlPrefix:String, resourceRelativePath:String, encodeResourcePaths:Bool):String {
        if (encodeResourcePaths) {
            return resourceUrlPrefix + StringTools.urlEncode(resourceRelativePath);
        }

        return resourceUrlPrefix + resourceRelativePath;
    }

    private function buildPreviewMarkup(resourceUrl:String, category:String, originalFileName:String):String {
        var escapedPath:String;
        var escapedTitle:String;

        escapedPath = htmlEscape(resourceUrl);
        escapedTitle = htmlEscape(originalFileName);

        if (category == "image" || category == "vector") {
            return '            <img src="' + escapedPath + '" alt="' + escapedTitle + '">\n';
        }

        if (category == "video") {
            return '            <video controls preload="metadata" src="' + escapedPath + '"></video>\n';
        }

        return '            <div class="placeholder">Preview unavailable</div>\n';
    }

    private function buildDetailRow(label:String, value:String):String {
        return '              <div>\n'
            + '                <dt>' + htmlEscape(label) + '</dt>\n'
            + '                <dd>' + htmlEscape(value) + '</dd>\n'
            + '              </div>\n';
    }

    private function formatFileSize(fileSizeBytes:Int):String {
        var kilobytes:Float;
        var megabytes:Float;

        if (fileSizeBytes < 1024) {
            return Std.string(fileSizeBytes) + " B";
        }

        kilobytes = fileSizeBytes / 1024;

        if (kilobytes < 1024) {
            return formatDecimal(kilobytes) + " KB";
        }

        megabytes = kilobytes / 1024;

        return formatDecimal(megabytes) + " MB";
    }

    private function formatDecimal(value:Float):String {
        return Std.string(Math.round(value * 10) / 10);
    }

    private function htmlEscape(value:String):String {
        return StringTools.htmlEscape(value, true);
    }

    private function buildClientScript(openResourcesFolderUrl:String):String {
        if (openResourcesFolderUrl == null || openResourcesFolderUrl == "") {
            return "";
        }

        return '  <script>\n'
            + '    const showAllResourcesButton = document.getElementById("showAllResourcesButton");\n'
            + '    if (showAllResourcesButton) {\n'
            + '      showAllResourcesButton.addEventListener("click", async () => {\n'
            + '        const openFolderUrl = showAllResourcesButton.dataset.openFolderUrl || "";\n'
            + '        if (!openFolderUrl) {\n'
            + '          return;\n'
            + '        }\n'
            + '        showAllResourcesButton.disabled = true;\n'
            + '        try {\n'
            + '          const response = await fetch(openFolderUrl, { method: "POST" });\n'
            + '          if (!response.ok) {\n'
            + '            const errorText = await response.text();\n'
            + '            throw new Error(errorText || "Failed to open the resources folder.");\n'
            + '          }\n'
            + '        } catch (error) {\n'
            + '          window.alert(error.message || "Failed to open the resources folder.");\n'
            + '        } finally {\n'
            + '          showAllResourcesButton.disabled = false;\n'
            + '        }\n'
            + '      });\n'
            + '    }\n'
            + '  </script>\n';
    }

    private function buildStyles():String {
        return '    :root {\n'
            + '      color-scheme: light;\n'
            + '      --bg: #f4f0e8;\n'
            + '      --panel: #fffdfa;\n'
            + '      --ink: #1f1b16;\n'
            + '      --muted: #6a5f52;\n'
            + '      --line: #ddd1c1;\n'
            + '      --accent: #b85c38;\n'
            + '      --accent-soft: #f2d5c8;\n'
            + '      --shadow: 0 18px 40px rgba(44, 29, 16, 0.08);\n'
            + '    }\n'
            + '    * {\n'
            + '      box-sizing: border-box;\n'
            + '    }\n'
            + '    body {\n'
            + '      margin: 0;\n'
            + '      font-family: Georgia, "Times New Roman", serif;\n'
            + '      background: radial-gradient(circle at top left, #fff7ed 0, var(--bg) 45%, #ebe3d5 100%);\n'
            + '      color: var(--ink);\n'
            + '    }\n'
            + '    a {\n'
            + '      color: var(--accent);\n'
            + '    }\n'
            + '    .page {\n'
            + '      max-width: 1180px;\n'
            + '      margin: 0 auto;\n'
            + '      padding: 32px 20px 48px;\n'
            + '    }\n'
            + '    .hero,\n'
            + '    .section {\n'
            + '      background: var(--panel);\n'
            + '      border: 1px solid var(--line);\n'
            + '      border-radius: 24px;\n'
            + '      box-shadow: var(--shadow);\n'
            + '    }\n'
            + '    .hero {\n'
            + '      display: flex;\n'
            + '      justify-content: space-between;\n'
            + '      gap: 24px;\n'
            + '      padding: 28px;\n'
            + '      margin-bottom: 24px;\n'
            + '    }\n'
            + '    .eyebrow {\n'
            + '      margin: 0 0 10px;\n'
            + '      text-transform: uppercase;\n'
            + '      letter-spacing: 0.12em;\n'
            + '      font-size: 12px;\n'
            + '      color: var(--muted);\n'
            + '    }\n'
            + '    h1,\n'
            + '    h2,\n'
            + '    h3 {\n'
            + '      margin: 0;\n'
            + '      line-height: 1.1;\n'
            + '    }\n'
            + '    h1 {\n'
            + '      font-size: clamp(2.2rem, 5vw, 4rem);\n'
            + '    }\n'
            + '    h2 {\n'
            + '      margin-bottom: 18px;\n'
            + '      font-size: 1.6rem;\n'
            + '    }\n'
            + '    .subtitle {\n'
            + '      margin: 14px 0 0;\n'
            + '      color: var(--muted);\n'
            + '      max-width: 56ch;\n'
            + '    }\n'
            + '    .actions {\n'
            + '      display: flex;\n'
            + '      flex-direction: column;\n'
            + '      align-items: flex-start;\n'
            + '      gap: 10px;\n'
            + '    }\n'
            + '    .actions a,\n'
            + '    .resource-links a {\n'
            + '      text-decoration: none;\n'
            + '      font-weight: 700;\n'
            + '      padding: 10px 14px;\n'
            + '      border: 1px solid var(--line);\n'
            + '      border-radius: 999px;\n'
            + '      background: #fff6f1;\n'
            + '    }\n'
            + '    .section {\n'
            + '      padding: 24px;\n'
            + '      margin-bottom: 24px;\n'
            + '    }\n'
            + '    .section-header {\n'
            + '      display: flex;\n'
            + '      align-items: center;\n'
            + '      justify-content: space-between;\n'
            + '      gap: 16px;\n'
            + '      margin-bottom: 18px;\n'
            + '    }\n'
            + '    .section-actions {\n'
            + '      display: flex;\n'
            + '      gap: 12px;\n'
            + '    }\n'
            + '    .action-button {\n'
            + '      appearance: none;\n'
            + '      border: 1px solid var(--line);\n'
            + '      border-radius: 999px;\n'
            + '      background: #fff6f1;\n'
            + '      color: var(--accent);\n'
            + '      padding: 10px 14px;\n'
            + '      font-family: inherit;\n'
            + '      font-size: 0.95rem;\n'
            + '      font-weight: 700;\n'
            + '      cursor: pointer;\n'
            + '    }\n'
            + '    .stats {\n'
            + '      display: grid;\n'
            + '      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));\n'
            + '      gap: 14px;\n'
            + '      margin-bottom: 18px;\n'
            + '    }\n'
            + '    .stat-card,\n'
            + '    .meta-item,\n'
            + '    .note,\n'
            + '    .resource-card {\n'
            + '      border: 1px solid var(--line);\n'
            + '      border-radius: 18px;\n'
            + '      background: #fffefb;\n'
            + '    }\n'
            + '    .stat-card {\n'
            + '      padding: 16px;\n'
            + '    }\n'
            + '    .stat-label {\n'
            + '      margin: 0 0 8px;\n'
            + '      color: var(--muted);\n'
            + '      font-size: 0.92rem;\n'
            + '    }\n'
            + '    .stat-value {\n'
            + '      margin: 0;\n'
            + '      font-size: 2rem;\n'
            + '      font-weight: 700;\n'
            + '    }\n'
            + '    .meta-grid {\n'
            + '      display: grid;\n'
            + '      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));\n'
            + '      gap: 12px;\n'
            + '      margin-bottom: 16px;\n'
            + '    }\n'
            + '    .meta-item {\n'
            + '      padding: 14px 16px;\n'
            + '    }\n'
            + '    .meta-label,\n'
            + '    dt {\n'
            + '      display: block;\n'
            + '      color: var(--muted);\n'
            + '      font-size: 0.85rem;\n'
            + '      margin-bottom: 6px;\n'
            + '    }\n'
            + '    .meta-value,\n'
            + '    dd {\n'
            + '      margin: 0;\n'
            + '      word-break: break-word;\n'
            + '    }\n'
            + '    .note {\n'
            + '      padding: 14px 16px;\n'
            + '      margin-bottom: 12px;\n'
            + '    }\n'
            + '    .warn {\n'
            + '      background: var(--accent-soft);\n'
            + '    }\n'
            + '    .resource-grid {\n'
            + '      display: grid;\n'
            + '      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));\n'
            + '      gap: 16px;\n'
            + '    }\n'
            + '    .resource-card {\n'
            + '      overflow: hidden;\n'
            + '    }\n'
            + '    .preview {\n'
            + '      aspect-ratio: 16 / 10;\n'
            + '      background: linear-gradient(135deg, #f6ede4, #efe1cf);\n'
            + '      display: flex;\n'
            + '      align-items: center;\n'
            + '      justify-content: center;\n'
            + '    }\n'
            + '    .preview img,\n'
            + '    .preview video {\n'
            + '      width: 100%;\n'
            + '      height: 100%;\n'
            + '      object-fit: contain;\n'
            + '      display: block;\n'
            + '    }\n'
            + '    .placeholder {\n'
            + '      color: var(--muted);\n'
            + '      font-style: italic;\n'
            + '    }\n'
            + '    .resource-body {\n'
            + '      padding: 16px;\n'
            + '    }\n'
            + '    .resource-type {\n'
            + '      margin: 8px 0 14px;\n'
            + '      color: var(--muted);\n'
            + '      text-transform: capitalize;\n'
            + '    }\n'
            + '    .details {\n'
            + '      margin: 0 0 16px;\n'
            + '      display: grid;\n'
            + '      gap: 12px;\n'
            + '    }\n'
            + '    @media (max-width: 800px) {\n'
            + '      .hero {\n'
            + '        flex-direction: column;\n'
            + '      }\n'
            + '      .actions {\n'
            + '        flex-direction: row;\n'
            + '        flex-wrap: wrap;\n'
            + '      }\n'
            + '      .section-header {\n'
            + '        flex-direction: column;\n'
            + '        align-items: flex-start;\n'
            + '      }\n'
            + '    }\n';
    }
}
