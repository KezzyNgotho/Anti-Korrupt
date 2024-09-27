// @ts-nocheck
// svelte.config.js
// @ts-ignore
import adapter from '@sveltejs/adapter-auto';
import sveltePreprocess from 'svelte-preprocess';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: sveltePreprocess({
    postcss: true,
  }),

  kit: {
    adapter: adapter(),
    // Other SvelteKit configurations
  }
};

export default config;
