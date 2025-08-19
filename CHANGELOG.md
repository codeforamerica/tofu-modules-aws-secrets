# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][changelog] and this project adheres to
[Semantic Versioning][semver].

## 2.0.0 (2025-08-19)

> [!CAUTION]
> This release fixes a bug that would case a double slash (`//`) in the secret
> name when the [`service`][inputs] input was not provided. If you are using the
> `service` input, you can ignore this warning.
>
> If you are not using the `service` input, this version will result in your
> secret names changing, which will force a replacement of the resource and
> resetting its value. If you wish to avoid this, you can explicitly set the
> [`name`][secrets] for your secrets to match the previous format of
> `<project>/<environment>//<name>`.

### Fix

- Exclude service from the secret path if it isn't set. (#4)

## 1.1.0 (2025-08-18)

### Feat

- Make the name suffix optional. (#5)

## 1.0.0 (2024-11-15)

### Feat

- Initial release. (#1)

[changelog]: https://keepachangelog.com/en/1.1.0/
[inputs]: README.md#inputs
[secrets]: README.md#secrets
[semver]: https://semver.org/spec/v2.0.0.html
