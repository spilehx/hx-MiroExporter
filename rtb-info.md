# RTB File Notes

## Summary

Based on the sample files in `./EXAMPLE_FILES`, an `.rtb` file is a ZIP archive containing:

- plain JSON metadata files
- opaque binary payload files named `canvas.json` and `tables.json`
- embedded media/resource files named by numeric resource IDs

The current evidence indicates that the outer `.rtb` container is straightforward to extract, but the main board-content payload is intentionally encrypted and not directly parseable as JSON.

## Sample Files Examined

- `EXAMPLE_FILES/Allwyn - devdesign workshops.rtb`
- `EXAMPLE_FILES/arg-storm.rtb`

## Outer Container Format

The `.rtb` files examined are standard ZIP archives.

Evidence from local inspection:

- `file` identifies them as `Zip archive data`
- `unzip -l` lists their entries normally
- `7z l -slt` reports archive type `zip`

The ZIP entries themselves are not marked as ZIP-encrypted. The encryption, where present, appears to be at the application payload level inside specific files.

## Top-Level Archive Layout

Both sample archives use a flat top-level layout with no subdirectories.

Observed top-level files:

- `meta.json`
- `board.json`
- `canvas.json`
- `resources.json`
- `plugin_settings.json`
- `showtime.json`
- `tables.json`
- one or more media files named with numeric IDs and the original file extension

Example media filenames:

- `3458764516497340181.png`
- `3458764516958650569.jpg`
- `3458764516958512026.svg`
- `3458764517494162173.mp4`

## Plain JSON Files

### `meta.json`

This is valid JSON and contains archive-level metadata.

Observed fields:

- `version`
- `encryptionVersion`
- `timestamp`

Observed values in both samples:

- `version: "1.20"`
- `encryptionVersion: "1.1"`

`timestamp` appears to be a Unix timestamp.

Example:

```json
{"version":"1.20","encryptionVersion":"1.1","timestamp":1774480193}
```

### `board.json`

This is valid JSON and contains board-level metadata.

Observed fields:

- `id`
- `name`
- `description`
- `iconResourceId`
- `startViewWidgetId`
- `isPublic`

Example:

```json
{"id":-5082077784431273910,"name":"Allwyn - dev/design workshops","description":"","iconResourceId":3458764516471720983,"startViewWidgetId":"","isPublic":true}
```

Notes:

- `iconResourceId` does not appear in `resources.json` in the sample files.
- `startViewWidgetId` is an empty string in the samples.

### `resources.json`

This is valid JSON and contains the exported resource catalog.

Observed top-level fields:

- `document`
- `image`
- `resources`

Observed resource item fields:

- `id`
- `name`
- `extension`
- `type`
- `infected`

Observed values:

- `document` is `null` in the samples
- `image` is `null` in the samples
- every listed resource has `type: "WIDGET"`
- every listed resource has `infected: false`

The `id` values map directly to filenames stored in the archive.

Example:

```json
{
  "document": null,
  "image": null,
  "resources": [
    {
      "id": 3458764516497340181,
      "name": "Screenshot 2025-02-07 at 14.39.29.png",
      "extension": "png",
      "type": "WIDGET",
      "infected": false
    }
  ]
}
```

### `plugin_settings.json`

This is valid JSON.

Observed content in both samples:

```json
{"representations":[]}
```

### `showtime.json`

This is valid JSON.

Observed content in both samples:

```json
{"sessions":[]}
```

## Opaque Binary Payload Files

### `canvas.json`

Despite the filename, this is not plain JSON in either sample file.

Observed properties:

- `jq` fails to parse it as JSON
- `file` reports only generic `data`
- it does not match common gzip headers
- it does not look like plain zlib-compressed JSON
- it has very high entropy
- it uses all 256 possible byte values in the sample files

Measured sample properties:

- `Allwyn - devdesign workshops.rtb`
  - size: `11281` bytes
  - size mod 16: `1`
  - entropy: about `7.9819`
- `arg-storm.rtb`
  - size: `35672` bytes
  - size mod 16: `8`
  - entropy: about `7.9950`

Interpretation:

- this strongly resembles ciphertext or another intentionally opaque binary encoding
- it does not behave like regular textual JSON payload data

### `tables.json`

Despite the filename, this is also not plain JSON in either sample file.

Observed properties:

- `jq` cannot parse it
- `file` reports generic `data`
- contents are binary
- sample size is exactly `63` bytes in both archives

Measured sample properties:

- `Allwyn - devdesign workshops.rtb`
  - size: `63` bytes
  - size mod 16: `15`
  - entropy: about `5.7868`
- `arg-storm.rtb`
  - size: `63` bytes
  - size mod 16: `15`
  - entropy: about `5.8066`

Interpretation:

- this appears to be another application-level opaque payload
- it may represent table-related state or a compact encrypted sidecar
- the exact structure is not currently known

## Embedded Resource Files

The archives contain raw media/resource files whose filenames are the numeric resource IDs from `resources.json`.

Observed resource types across the samples:

- PNG
- JPG
- SVG
- MP4

Verified examples:

- PNG image data
- JPEG image data
- SVG image data
- ISO Media / MP4

This part of the format is directly extractable without needing any custom decoding beyond ZIP extraction.

## Observed Sample Inventory

### `Allwyn - devdesign workshops.rtb`

Observed entries:

- 9 total archive entries
- 2 PNG assets
- `resources.json` lists 2 widget resources matching those PNG files

### `arg-storm.rtb`

Observed entries:

- 12 total archive entries
- 5 assets total
- asset types observed: PNG, JPG, SVG, MP4, PNG
- `resources.json` lists 5 widget resources matching those files

## Current Best Understanding

The most reliable current model is:

1. `.rtb` outer format is ZIP
2. several top-level files are plain JSON metadata
3. attached resources are stored as ordinary binary files keyed by numeric resource IDs
4. the main board/canvas payload is stored in opaque binary files, especially `canvas.json`
5. `tables.json` also appears opaque and non-JSON

## Limits And Constraints

The sample files do not provide a way to decode the real board-content payload.

The strongest evidence is:

- `meta.json` explicitly includes `encryptionVersion: "1.1"`
- `canvas.json` behaves like encrypted or otherwise sealed binary data
- public Miro community guidance states that backup data such as `canvas.json` is encrypted and intended for Miro compatibility, not for third-party decoding

This means:

- extracting `.rtb` contents is feasible
- reading plain metadata and embedded assets is feasible
- reconstructing the actual board object graph from `canvas.json` is not currently feasible from these samples alone

## External References

Miro community thread indicating that backups, including `canvas.json`, were encrypted and are intended for Miro-only compatibility:

- <https://community.miro.com/ask-the-community-45/editing-canvas-json-in-backup-rtb-6868>

Miro help page describing `.RTB` as a proprietary format in import/export flow:

- <https://help.miro.com/hc/en-us/articles/18580556555538-Importing-Freehand-boards-to-Miro>

## Practical Extraction Implications

What can be implemented reliably:

- detect whether a file is an `.rtb`
- open it as a ZIP archive
- enumerate entries
- extract and parse:
  - `meta.json`
  - `board.json`
  - `resources.json`
  - `plugin_settings.json`
  - `showtime.json`
- extract raw embedded asset files
- report that `canvas.json` and `tables.json` are opaque/encrypted payloads

What cannot currently be implemented from the available evidence:

- decoding the actual board canvas structure from `canvas.json`
- reconstructing widgets, positions, links, frames, notes, or other board objects from the encrypted payload
- interpreting the true schema of `tables.json`
