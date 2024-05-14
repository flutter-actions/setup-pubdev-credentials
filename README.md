# About
GitHub Action to configuring credentials for automated publishing of packages to pub.dev

When configuring automated publishing you don't need to create a long-lived secret that is copied into your automated deployment environment. Instead, authentication relies on temporary OpenID-Connect tokens signed by GitHub Actions.

See https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect for more information.

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
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Setup Flutter SDK and automated pub.dev credentials
      - uses: flutter-actions/setup-flutter@v3
      - uses: flutter-actions/setup-pubdev-credentials@v1

      # Here you can insert custom steps you need
      - name: Install dependencies
        run: dart pub get
      - name: Publish
        run: dart pub publish --force
```

## License

Licensed under the [MIT License](LICENSE).
