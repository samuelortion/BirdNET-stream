# Contributing

This project welcomes contributions and suggestions. 

You can contribute to this project by contributing to:

* [Issues](https://github.com/UncleSamulus/BirdNET-stream/issues)
* [Discussions](https://github.com/UncleSamulus/BirdNET-stream/discussions)
* [Localization](#Localization)

If you intend to contribute code changes, learn how to [set up your development environment](#Set-up-your-development-environment).
<!-- 
When contributing template changes, [validate](#Validating-changes) your changes by generating projects with updated templates and running appropriate tests, then file a PR to trigger CI validation. -->

## Set up your development environment

You should follow [./INSTALL.md](./INSTALL.md) to install a working BirdNET-stream system on your system.

## Localization

BirdNET-stream webapp is written in PHP Symfony. The i18n files are stored in the `[./www/translations](./www/translations)` directory.

Any help is welcome to translate the webapp into your language.

Add your language code into [./www/bin/translate.sh](./www/bin/translate.sh) and run it to update the translation files.

Then, edit generated files in [./www/translations](./www/translations).

## Filing a pull request

All contributions are expected to be reviewed and merged via pull requests into the main branch.