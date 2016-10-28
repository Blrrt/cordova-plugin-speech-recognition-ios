/* eslint-disable import/no-extraneous-dependencies */

const babel = require('rollup-plugin-babel');

export default {
  format: 'cjs',
  plugins: [babel()],
};
