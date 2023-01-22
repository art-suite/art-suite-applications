# Simple Client Server

## Install

```bash
npm install
```

## Dev

This runs directly from the code in `/source` and hot-updates as changes are made.

```bash
npm run start-dev
```

## Build

Build the code for deployment into `/build`

```bash
npm run build
```

## Server

Serves the API and static assets on http://localhost:8085. The API is inspectable on http://localhost:8085/api. Static assets are served out of `/public`. The app is served from the built version of the code from /build.

```bash
npm run start-server
```
