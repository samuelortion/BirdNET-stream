#! /usr/bin/env bash

LANGUAGES="fr es"
# Extract and update translation files
for LANGUAGE in $LANGUAGES; do
    php bin/console translation:extract --dump-messages $LANGUAGE
    php bin/console translation:extract --force $LANGUAGE
done