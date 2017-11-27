#!/bin/sh

if [ ! -d CoreDataStack ]; then
	echo "Must be run from root of the repository."

	exit 1
fi

jazzy --skip-undocumented --source-directory CoreDataStack --readme ./README.md
