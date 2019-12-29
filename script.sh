#!/bin/bash

git clone https://github.com/frej/fast-export.git

NEW_REPO_NAME_PREFIX="g_"
BITBUCKET_USERNAME="${1:-mbudavari}" #used for git remote

echo "== Get repository URL-s =="
cat "repos/repo.json" | jq --raw-output '.values[].links.clone[] | select(.name == "ssh") | .href' >repos/repo.txt
echo

echo "== Clone HG repositories"
pushd "repos" || exit 1
while read -r url; do
    echo " cloning repo from: $url"
    hg clone "$url" || exit 2
done <repo.txt
popd || exit 1
echo

echo "== Prepare python2 for fast-export =="
virtualenv -p /usr/local/bin/python2.7 venv
. ./venv/bin/activate
pip2 install mercurial
export PYTHON="$(pwd)/venv/bin/python" #fast-export loads python interpreter location from this env variable
echo

echo "== Export and push repositories =="
mkdir -p newrepos
for d in repos/*/; do
    SOURCE_FOLDER="${d%%/}"
    echo " processing $SOURCE_FOLDER..."
    NEW_FOLDER="new$SOURCE_FOLDER"
    echo " init new repository"
    git init "$NEW_FOLDER"
    pushd "$NEW_FOLDER" || exit 1
        REPO_NAME="$(basename "$NEW_FOLDER")"
        git config core.ignoreCase false #necessary to avoid empty commits that were only uppercase/lowercase changing renames
        echo " migrate into new repository"
        ../../fast-export/hg-fast-export.sh -r "../../$SOURCE_FOLDER"
        echo " push into new repository"
        git remote add origin "git@bitbucket.org:${BITBUCKET_USERNAME}/${NEW_REPO_NAME_PREFIX}$REPO_NAME.git"
        git push origin --all
    popd || exit 1
    echo
done

echo "DONE."
