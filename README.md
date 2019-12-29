# Migrate mercurial to git

Bitbucket stops supporting mercurial repositories in 2020.

My first version control was Mercurial, so I had a bunch of repositories, and bitbucket was my main repository holder while I learned to code.
I decided to save the files stored in those repositories, but I did not want to do all that by hand, and until this day there is no one/click solution to migrate those repositories.

I Used `OSX` 10.15.2, `bash`, `jq`, and `fast-export` for this task.

## Prepare

I did not script these steps:

* `brew install mercurial, jq`
* Add my public ssh key to bitbucket
* Get a json of my mercurial repositories. Into `repos/repos.json`. (bitbucket api or [network inspector](https://bitbucket.org/!api/internal/dashboard/repositories?pagelen=25&page=1&q=scm%20%3D%20%22hg%22)).
* create new repositories with some name prefix e.g: `g_` (bitbucket api or by hand)

## How the script works

It is based on the [git documentation](https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git#_mercurial) about migration.

1. Clone fast-export
1. Parse the provided `repos/repo.json` file
1. Clone the hg repositories into `repos`
1. Prepare the **PYTHON2** environment that is necessary for fast-export
1. Create a `newrepos` folder, and init git repositories over there.
1. Migrate repos to the new location
1. Add new git origin, push

## Run

```bash
./script.sh BITBUCKET_USERNAME
```

This script does not delete anything, and works only in this folder hierarchy, but I advise you to review it without starting it.
I might have missed something that is necessary for different repositories, I am happy with my result.

### Troubleshooting

#### Illegal byte sequence error

One of my repositories contained a binary file with accented characters in its name from windows.
HG would not clone these for me with this error: `abort: Illegal byte sequence`.

I checked that repo out in windows, renamed the file and committed a change with the new name.
It fixed my problem.

## IMPROVEMENT IDEAS

* script bitbucket api for getting and creating repositories
* keep the projects instead of adding everything to the user, would need to parse url, or get that info with jq
