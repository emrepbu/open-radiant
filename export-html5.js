const JSZip = require('jszip');
const coverAssets = require('./export-cover-assets.js');

// Keep this format version in sync with the blog's public/blog-assets/open-radiant/v1/.
const sharedRuntimePath = '/blog-assets/open-radiant/v1/';

const createHtml5Zip = async (source, { blog = false, loadFile }) => {
    const zip = new JSZip();
    zip.file('scene.js', 'window.jsGenScene = ' + JSON.stringify(source, null, 2) + ';');
    zip.file('index.html', await loadFile('./index.player.html'), { binary: true });
    if (blog) {
        const html = (await zip.file('index.html').async('string')).replace('./index.css', sharedRuntimePath + 'index.css')
                   .replace('./player.bundle.js', sharedRuntimePath + 'player.bundle.js');
        zip.file('index.html', html);
    }

    const files = coverAssets(source).map(name => 'assets/' + name);
    if (!blog) files.push('player.bundle.js', 'index.css', 'assets/fonts/OFL.txt');
    await Promise.all(files.map(async name => {
        zip.file(name, await loadFile('./' + name), { binary: true });
    }));
    return zip;
};

module.exports = { createHtml5Zip, sharedRuntimePath };
