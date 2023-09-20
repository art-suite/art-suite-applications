# Simple ArtSuite Client Server

Key ArtSuite packages used:

- ArtEry
  - ArtPipelines
  - ArtModels
- ArtReact (ArtComponents)
- ArtEngine (ArtElements)

## Install

```bash
npm install
```

## Run in Development (100% in-browser)

This runs directly from the code in `/source` and hot-updates as changes are made.

```bash
npm run start-dev
```

- Open: http://localhost:8080/

#### About Development Mode

The entire client-side and server-side code is built into one bundle which runs in the web browser. This allows you to debug your full app in one runtime. You also get hot-reloading of both client and server code.

## Run in Production, Locally (Client + Server)

### Build

Build the code for deployment into `/build`

```bash
npm run build
```

### Start Server

```bash
npm run start-server
```

- Open: http://localhost:8085/

#### About the Server

The NodeJS server serves the API and static assets on http://localhost:8085. The API is inspectable on http://localhost:8085/api. Static assets are served out of `/public`. The app is served from the built version of the code from /build.
