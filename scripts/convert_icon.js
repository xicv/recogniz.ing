const sharp = require('sharp');
const path = require('path');

const inputPath = path.join(__dirname, '../assets/icons/app_icon.svg');
const outputPath = path.join(__dirname, '../assets/icons/app_icon.png');

sharp(inputPath)
  .resize(1024, 1024)
  .png()
  .toFile(outputPath)
  .then(() => console.log('PNG generated successfully!'))
  .catch(err => console.error('Error:', err));
