#!/usr/bin/env node

require('./loadEnv');

const ghpages = require('gh-pages');


const options = {
    directory: 'dist',
    token: process.env.GITHUB_TOKEN,
    repo: 'git@github.com:link-note/link-note.github.io.git',
    branch: 'main',
}

ghpages.publish('dist', options, () => {
    console.log("推送到GithubPage成功");
})