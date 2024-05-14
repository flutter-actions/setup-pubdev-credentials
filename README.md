# About
GitHub Action to configuring credentials for automated publishing of packages to pub.dev

When configuring automated publishing you don't need to create a long-lived secret that is copied into your automated deployment environment. Instead, authentication relies on temporary **OpenID-Connect** tokens signed by **GitHub Actions**.

See [Automated publishing of packages to pub.dev](https://dart.dev/tools/pub/automated-publishing) and [OpenID Connect allows your workflows to exchange short-lived tokens directly from your cloud provider](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) for more information.

## Usage

```yml
# .github/workflows/publish.yml
name: Publish to pub.dev

on:
  push:
    tags:
    - 'v[0-9]+.[0-9]+.[0-9]+*' # tag pattern on pub.dev: 'v{{version}'

# Publish using custom workflow
jobs:
  publish:
    permissions:
      id-token: write # Required for authentication using OIDC
      content: read
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Setup Flutter SDK and automated pub.dev credentials
      - uses: flutter-actions/setup-flutter@v3
      - uses: flutter-actions/setup-pubdev-credentials@v1

      # Here you can insert custom steps you need
      - name: Install dependencies
        run: flutter pub get
      - name: Publish
        run: flutter pub publish --force
```

## License

Licensed under the [MIT License](LICENSE).
