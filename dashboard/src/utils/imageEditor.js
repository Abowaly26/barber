export async function createEditedImageFile({
  file,
  zoomLevel = 1,
  rotation = 0,
  offsetX = 0,
  offsetY = 0,
  outputName,
}) {
  const image = await loadImage(file);
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');

  canvas.width = image.naturalWidth || image.width;
  canvas.height = image.naturalHeight || image.height;

  context.fillStyle = '#ffffff';
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.translate(canvas.width / 2 + offsetX, canvas.height / 2 + offsetY);
  context.rotate((rotation * Math.PI) / 180);
  context.scale(zoomLevel, zoomLevel);
  context.drawImage(image, -canvas.width / 2, -canvas.height / 2, canvas.width, canvas.height);

  const blob = await new Promise((resolve, reject) => {
    canvas.toBlob(
      (nextBlob) => {
        if (nextBlob) resolve(nextBlob);
        else reject(new Error('Failed to prepare edited image.'));
      },
      file.type || 'image/jpeg',
      0.92
    );
  });

  return new File([blob], outputName || file.name, {
    type: blob.type || file.type || 'image/jpeg',
  });
}

function loadImage(file) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    const url = URL.createObjectURL(file);

    image.onload = () => {
      URL.revokeObjectURL(url);
      resolve(image);
    };
    image.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error('Failed to load selected image.'));
    };
    image.src = url;
  });
}
