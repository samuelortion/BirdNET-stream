#! /usr/bin/env bash

# Take a week with format "YYYY-MM-DD" and return the week number.
function weekof()
{
    local date=$1
    date -d "$date" +%W
}

weekof $1