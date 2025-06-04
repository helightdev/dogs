import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Dart Object Graphs",
  description: "Universal Dart serialization on steroids",
  base: '/',
  cleanUrls: true,
  lang: 'en-US',
  appearance: 'dark',
  lastUpdated: true,
  ignoreDeadLinks: 'localhostLinks',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Serializable', link: '/guide/serializable' }
    ],

    search: {
      provider: "local",
      options: {
        detailedView: true,
      }
    },

    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Serializable', link: '/guide/serializable' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/helightdev/dogs' }
    ],
    footer: {
      copyright: "Released under the Apache License 2.0",
    },
  }
})
