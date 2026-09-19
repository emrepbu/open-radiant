# Artwork generating and delivering

[![team project](https://jb.gg/badges/team-flat-square.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)

## In Action

Video

[![Radiant in Action](http://img.youtube.com/vi/FUOHMR5nPt0/0.jpg)](http://www.youtube.com/watch?v=FUOHMR5nPt0 "Radiant in Action")

Metarings

![Metarings](https://d3nmt5vlzunoa1.cloudfront.net/wp-content/uploads/2019/12/image8.jpg)

Myopia and biomorphs

![Myopia and biomorphs](https://d3nmt5vlzunoa1.cloudfront.net/wp-content/uploads/2019/12/image4.jpg)

Khokhloma

![Khokhloma](https://d3nmt5vlzunoa1.cloudfront.net/wp-content/uploads/2019/12/image3.jpg)

Chromatic Holes

![Chromatic Holes](https://d3nmt5vlzunoa1.cloudfront.net/wp-content/uploads/2019/12/image7.jpg)

ARRT!

![ARRRT](https://d3nmt5vlzunoa1.cloudfront.net/wp-content/uploads/2019/12/image5.jpg)

## Development

Install Elm and Webpack:

`npm install -g elm webpack`

Then install required packages:

`npm install`

Run with:

`npm start`

If you want to build / minify, use:

`npm run build:player`
`npm run build`

See `./package.json` and `Dockerfile` for


## Navigation

### Custom title and subtitle

Open the **Cover** panel and enter a **Title** and **Subtitle**. The preview
updates while typing or pasting, and long text wraps automatically. Adjust
**Title size** and **Subtitle size** separately; values are relative to a
1200 × 630 canvas and scale with the selected output size.

Custom text replaces the centered product SVG. Leave both fields empty to
use the existing `assets/*-text.svg` image, controlled by **Product title**.
The text overlay lets mouse interaction pass through to the animation.
Custom titles and subtitles stay fully opaque with normal blending, including
after **i feel lucky**. Random artwork opacity and blend modes do not fade the
text in the editor, HTML5 player, or PNG export.

The title uses **JetBrains Mono Bold** and the subtitle uses **JetBrains Mono
Regular**. The official v2.304 WOFF2 files are embedded unchanged in
`assets/fonts/jetbrains-mono.css` and bundled with both the editor and player.
No installed font, CDN, or font request is needed by the exported animation.
PNG export embeds the same font data and waits for the fonts before rendering.
Source: [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono/tree/v2.304).
The included SIL Open Font License is also added to the HTML5 ZIP.

Use **Logo visible** to show or hide the lower-right JetBrains logo independently
of the title and subtitle. This setting is saved in the scene and respected by
both HTML5 and PNG exports. When disabled, the logo is omitted from the
HTML5 player DOM and `assets/jetbrains.svg` is not added to the ZIP or requested.
Unused product-title SVGs are also omitted when using custom text or disabling
**Product title**. Older scenes keep the logo visible by default.

HTML5 exports store the text and sizes in the cover layer of `scene.js`.
Unicode text, including Turkish characters, is supported in HTML5 and PNG
exports. Older scenes without these fields still load with the original SVG.

After changing the player, rebuild both bundles before exporting HTML5 so
the ZIP includes the updated renderer. For the existing Webpack 4 setup on
Node 17 and newer, use:

```sh
NODE_OPTIONS=--openssl-legacy-provider NODE_ENV=production npm run build:player
NODE_OPTIONS=--openssl-legacy-provider NODE_ENV=production npm run build
```

### HTML5 export modes

- **HTML5** downloads a standalone ZIP with its player, styles, font license,
  scene and any visible logo/product SVGs.
- **HTML5 (Blog)** downloads `index.html`, `scene.js`, and only the SVGs
  needed by visible logos or product titles (if any). Extract the ZIP
  into the post's `cover/` folder in `emrepbu.github.io`. The blog supplies
  the shared player, embedded fonts and styles from `/blog-assets/open-radiant/v1/`.
  SVGs stay with the cover that uses them; custom text with a hidden logo
  needs no SVG files.
  This smaller ZIP needs those files on the same website; it is not a
  standalone offline export. Hidden logos and unused product SVGs are
  still never requested.

To update the shared files after rebuilding Open Radiant, run
`npm run covers:sync -- ../open-radiant` from the blog repository. Commit the
updated `public/blog-assets/open-radiant/v1/` files with the blog. Keep old runtime
versions if a future export format introduces a new versioned path.

### URL format:

```
http://<host>/
http://<host>/#<product>
http://<host>/#<mode>
http://<host>/#<preset>
http://<host>/#<width>x<height>
http://<host>/#<size_rule>:<width>x<height>
http://<host>/#<size_rule>:<preset>
http://<host>/#<size_rule>:<preset>x<factor>
http://<host>/#<size_rule>:<preset>:<width>x<height>
http://<host>/#<mode>/<size_rule>...
http://<host>/#<product>/<size_rule>...
http://<host>/#<size_rule>/<mode>...
http://<host>/#<mode>/<product>/<size_rule>...
http://<host>/#<mode>/<size_rule>.../<product>
http://<host>/#<product>/<size_rule>.../<mode>
etc.
```

#### Product:

Default: `jetbrains`

Any of: `jetbrains`, `intellij-idea`, `phpstorm`, `pycharm`, `rubymine`, `webstorm`, `clion`, `datagrip`, `appcode`, `goland`, `resharper`, `resharper-cpp`, `dotcover`, `dotmemory`, `dotpeek`, `dottrace`, `rider`, `teamcity`, `youtrack`, `upsource`, `hub`, `kotlin`, `mps`

#### Mode:

Default: `release`

Any of: `dev`, `prod`, `release`, `ads`, `tron-<mode>`, `player`

#### Size Rule

Default: `dimensionless`

When just the size given, it's: `<width>x<height>` -> `custom:<width>x<height>`

* `viewport:<width>x<height>`
* `custom:<width>x<height>`
* `preset:<preset-id>`
* `preset:<preset-id>x<factor>` (preset with factor, factor defaults to `2`, when not specified)
* `preset:<preset-id>:<width>x<height>` (preset with size)
* `dimensionless` (try to find the fitting one, usually falls back to the current `viewport` size)

##### Presets

* `PC`, `PCx1`, `PCx2` — Product Card
* `SP`, `SPx1`, `SPx2` — Product Splash
* `NL`, `NLx1`, `NLx2` — Newsletter
* `BH`, `BHx1`, `BHx2` — Blog header
* `BF`, `BFx1`, `BFx2` — Blog footer
* `LP` — Landing page
* `WB` — WebPage Preview
* `AD:<width>x<height>` — Ad
* `WP:<width>x<height>` — Wallpaper
* `TW` — Twitter
* `FB` — Facebook
* `IN` — Instagram
* `LN` — LinkedIn
* `BA:<width>x<height>` — Baidu

#### Examples:

```
http://localhost:8080
http://localhost:8080/#100x501
http://localhost:8080/#custom:100x501
http://localhost:8080/#preset:TW
http://localhost:8080/#preset:LP
http://localhost:8080/#preset:PCx2
http://localhost:8080/#preset:BA:200x300
http://localhost:8080/#viewport:1020x300
http://localhost:8080/#dimensionless
http://localhost:8080/#dev/custom:100x501
http://localhost:8080/#release/preset:TW
http://localhost:8080/#dev
http://localhost:8080/#player
http://localhost:8080/#tron-dev/preset:TW
http://localhost:8080/#jetbrains/100x501
http://localhost:8080/#jetbrains/dev/custom:100x501
http://localhost:8080/#100x501/teamcity/ads
```
