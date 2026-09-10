// Embed the same font data in the editor, standalone player and PNG renderer.
const css = require('!!raw-loader!./assets/fonts/jetbrains-mono.css').default;

const install = () => {
    if (document.getElementById('cover-fonts')) return;
    const style = document.createElement('style');
    style.id = 'cover-fonts';
    style.textContent = css;
    document.head.appendChild(style);
};

const ready = () => Promise.all([
    document.fonts.load('400 16px "JetBrains Mono"'),
    document.fonts.load('700 16px "JetBrains Mono"')
]);

module.exports = { css, install, ready };
