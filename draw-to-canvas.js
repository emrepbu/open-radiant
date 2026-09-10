const coverFonts = require('./cover-fonts.js');

const htmlToCanvas = async (selector, canvas, width, height, whenDone) => {
    const node = document.querySelector(selector);
    if (!node) {
        console.warn('no element with selector `' + selector + '` was found');
        if (whenDone) whenDone(canvas);
        return;
    }
    const hasCoverText = !!node.querySelector('.cover-custom-text');
    if (hasCoverText) await coverFonts.ready();
    const context = canvas.getContext('2d');
    const data =
        '<svg xmlns="http://www.w3.org/2000/svg" width="'+width+'px" height="'+height+'px">' +
              '<foreignObject width="100%" height="100%">' +
                  '<div xmlns="http://www.w3.org/1999/xhtml">' +
                      (hasCoverText ? '<style>' + coverFonts.css + '</style>' : '') +
                      node.innerHTML +
                  '</div>' +
              '</foreignObject>' +
          '</svg>';
    const image = new Image();
    // image.crossOrigin = 'Anonymous';
    image.addEventListener('error', (err) => {
        throw err;
    });
    image.setAttribute('crossOrigin', 'anonymous');
    //const svg = new Blob([data], {type: 'image/svg+xml;charset=utf-8'});
    // Preserve Turkish characters and other Unicode text in PNG exports.
    const url = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(data);
    //const url = URL.createObjectURL(svg);
    image.addEventListener('load', () => {
        URL.revokeObjectURL(url);
        context.save();
        context.globalAlpha = 1;
        context.globalCompositeOperation = 'source-over';
        context.drawImage(image, 0, 0);
        context.restore();
        if (whenDone) whenDone(canvas);
    }, false);
    image.src = url;
    // document.body.appendChild(image);
    // context.canvas.width = width;
    // context.canvas.height = height;
}

const svgToCanvas = (selector, canvas, width, height, whenDone) => {
    const svg = document.querySelector(selector);
    if (!svg) {
        console.warn('no element with selector `' + selector + '` was found');
        if (whenDone) whenDone(canvas);
        return;
    }
    const context = canvas.getContext('2d');
    // get svg data
    const xml = new XMLSerializer().serializeToString(svg);

    const image = new Image();
    image.setAttribute('crossOrigin', 'anonymous');

    // Keep Unicode text intact in the SVG data URL.
    const image64 = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(xml);

    // set it as the source of the img element
    image.addEventListener('load', () => {
        URL.revokeObjectURL(image64);
        // draw the image onto the canvas
        context.drawImage(image, 0, 0);
        if (whenDone) whenDone(canvas);
    }, false);

    image.src = image64;
}

const imageToCanvas = (src, transform, canvas, x, y, width, height, whenDone) => {
    const context = canvas.getContext('2d');
    const image = new Image();
    //image.style.cssText = document.defaultView.getComputedStyle(cloneFrom, '').cssText;
    image.setAttribute('crossOrigin', 'anonymous');
    image.addEventListener('error', (err) => {
        throw err;
    });
    image.addEventListener('load', () => {
        transform(image, context);
        context.drawImage(image, 0, 0, width, height);
        context.resetTransform();
        if (whenDone) whenDone(canvas);
    }, false);
    image.src = src;
    //document.body.appendChild(image);
}

const storedToCanvas = (selector, trgCanvas, whenDone) => {
    const selectedNode = document.querySelector(selector);
    if (!selectedNode) {
        console.warn('no element with selector `' + selector + '` was found');
        if (whenDone) whenDone(trgCanvas);
        return;
    }
    const state = JSON.parse(selectedNode.getAttribute('data-stored'));
    imageToCanvas(state.imagePath,
        function(image, context) {
            context.resetTransform();
            context.translate(state.posX, state.posY);
            context.scale(state.scale, state.scale);
            context.translate(-(state.width / 2), -(state.height / 2));
            context.globalCompositeOperation = state.blend;
            image.width = state.width;
            image.height = state.height;
        },
        trgCanvas, 0, 0, state.width, state.height,
        whenDone
    );
}

const canvasToCanvas = (selector, trgCanvas, whenDone) => {
    const selectedNode = document.querySelector(selector);
    if (!selectedNode) {
        console.error('no element with selector `' + selector + '` was found');
        return;
    }
    requestAnimationFrame(() => {
        const srcCanvas = selectedNode;
        trgCanvas.style.mixBlendMode = srcCanvas.style.mixBlendMode;
        trgCanvas.style.opacity = srcCanvas.style.opacity;
        const trgContext = trgCanvas.getContext('2d');
        //trgContext.globalCompositeOperation = 'copy';
        trgContext.resetTransform();
        trgContext.globalCompositeOperation = srcCanvas.style.mixBlendMode || 'copy';
        trgContext.globalAlpha = srcCanvas.style.opacity;
        trgContext.drawImage(srcCanvas, 0, 0);
        whenDone();
    });
}

module.exports = {
    html: htmlToCanvas,
    image: imageToCanvas,
    svg: svgToCanvas,
    stored: storedToCanvas,
    canvas: canvasToCanvas
};
