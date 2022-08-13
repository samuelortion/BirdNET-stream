#! /usr/bin/env bash

# Extract and update translation files
php bin/console translation:extract --dump-messages fr

php bin/console translation:extract --force fr