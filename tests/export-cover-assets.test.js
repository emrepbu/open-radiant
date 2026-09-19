const assert = require('node:assert/strict');
const test = require('node:test');
const coverAssets = require('../export-cover-assets.js');
const scene = (...layers) => ({ product: 'kotlin', layers });
const cover = (model = {}, visible = 'visible') => ({ def: 'cover', visible, model });

test('hidden logos and custom titles do not add SVG assets', () => {
    assert.deepEqual(coverAssets(scene(cover({ logoShown: false, productShown: true, heading: 'Kotlin' }))), []);
});
test('visible logos are included independently of custom text', () => {
    assert.deepEqual(coverAssets(scene(cover({ logoShown: true, heading: 'Kotlin' }))), ['jetbrains.svg']);
});
test('legacy scenes retain their logo and product SVG', () => {
    assert.deepEqual(coverAssets(scene(cover({ productShown: true }))), ['kotlin-text.svg', 'jetbrains.svg']);
});
test('subtitle alone replaces the product SVG, while whitespace does not', () => {
    assert.deepEqual(coverAssets(scene(cover({ logoShown: false, productShown: true, heading: ' ', subheading: 'Subtitle' }))), []);
    assert.deepEqual(coverAssets(scene(cover({ logoShown: false, productShown: true, heading: ' ', subheading: ' ' }))), ['kotlin-text.svg']);
});
test('disabled product titles, hidden covers and non-cover layers add no SVGs', () => {
    assert.deepEqual(coverAssets(scene(cover({ logoShown: false, productShown: false }))), []);
    assert.deepEqual(coverAssets(scene(cover({}, 'hidden'), { def: 'background', model: {} })), []);
    assert.deepEqual(coverAssets(scene()), []);
});
test('multiple visible and locked covers include each required asset once', () => {
    assert.deepEqual(coverAssets(scene(cover({ logoShown: false, heading: 'Title' }), cover({}, 'locked'), cover({}))), ['kotlin-text.svg', 'jetbrains.svg']);
});
