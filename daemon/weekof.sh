#! /usr/bin/env bash

function weekof()
{
    local date=$1
    date -d "$date" +%W
}

weekof $1