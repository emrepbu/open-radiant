// Keep the HTML5 package in sync with the visible cover content.
module.exports = ({ product, layers }) => {
    const covers = layers.filter(layer => layer.def === 'cover' && layer.visible !== 'hidden');
    const assets = [];
    if (covers.some(({ model }) =>
        model.productShown !== false &&
        !(model.heading || '').trim() &&
        !(model.subheading || '').trim()
    )) {
        assets.push(product + '-text.svg');
    }
    // Old scenes omit logoShown and keep the logo visible by default.
    if (covers.some(({ model }) => model.logoShown !== false)) {
        assets.push('jetbrains.svg');
    }
    return assets;
};
