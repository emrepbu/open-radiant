const assert = require('node:assert/strict');
const test = require('node:test');
const { readFile } = require('node:fs/promises');
const { resolve } = require('node:path');
const { createHtml5Zip } = require('../export-html5.js');

const scene = {
    product: 'kotlin', size: { v1: 1200, v2: 630 },
    layers: [{ def: 'cover', visible: 'visible', model: {
        productShown: true, logoShown: false, heading: 'Türkçe başlık', subheading: 'Alt başlık'
    } }]
};
const loadFile = async path => {
    const data = await readFile(resolve(__dirname, '..', path));
    return data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength);
};
const files = zip => Object.keys(zip.files).filter(name => !zip.files[name].dir).sort();
const exportedScene = async zip => JSON.parse((await zip.file('scene.js').async('string')).replace(/^window.jsGenScene = /, '').replace(/;$/, ''));

test('custom-text blog ZIP contains only its entry and scene, with shared runtime URLs', async () => {
    const zip = await createHtml5Zip(scene, { blog: true, loadFile });
    assert.deepEqual(files(zip), ['index.html', 'scene.js']);
    const html = await zip.file('index.html').async('string');
    assert.match(html, /src="\.\/scene\.js"/);
    assert.match(html, /href="\/blog-assets\/open-radiant\/v1\/index\.css"/);
    assert.match(html, /src="\/blog-assets\/open-radiant\/v1\/player\.bundle\.js"/);
    const exported = await exportedScene(zip);
    assert.deepEqual(exported, scene);
    assert.equal(exported.layers[0].model.heading, 'Türkçe başlık');
    assert.deepEqual(exported.size, { v1: 1200, v2: 630 });
    assert.equal(scene.layers[0].model.assetsPath, undefined);
});

test('standalone ZIP includes the player, styles and font license without hidden SVGs', async () => {
    const zip = await createHtml5Zip(scene, { loadFile });
    assert.deepEqual(files(zip), ['assets/fonts/OFL.txt', 'index.css', 'index.html', 'player.bundle.js', 'scene.js']);
    assert.match(await zip.file('index.html').async('string'), /src="\.\/player\.bundle\.js"/);
});

test('blog export includes only the SVGs used by visible cover content', async () => {
    const input = { ...scene, layers: [{ def: 'cover', visible: 'visible', model: {
        productShown: true, logoShown: true
    } }] };
    const zip = await createHtml5Zip(input, { blog: true, loadFile });
    assert.deepEqual(files(zip), ['assets/jetbrains.svg', 'assets/kotlin-text.svg', 'index.html', 'scene.js']);
    assert.deepEqual(await exportedScene(zip), input);
});

test('blog export never reads the shared player, styles or font license', async () => {
    const zip = await createHtml5Zip(scene, { blog: true, loadFile: path => {
        assert.equal(path, './index.player.html');
        return loadFile(path);
    } });
    assert.deepEqual(files(zip), ['index.html', 'scene.js']);
});

test('asset loading errors reject the export instead of producing an incomplete ZIP', async () => {
    await assert.rejects(createHtml5Zip(scene, { loadFile: async () => { throw new Error('Missing asset'); } }), /Missing asset/);
});
