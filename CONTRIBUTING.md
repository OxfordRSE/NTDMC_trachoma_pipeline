
# Table of Contents

1.  [Contributing to this repository](#org6486178)
    1.  [Working on the files locally (i.e. on you computer)](#orge0c6360)
    2.  [Sharing your changes](#org741b5b7)
    3.  [Handling merge conflicts](#org39f4f25)
    4.  [Summary of useful git commands](#org74725de)



<a id="org6486178"></a>

# Contributing to this repository

A minimal workflow to get you started with git and github.

This document describes how to contribute to this repository. It is
aimed at contributors with no previous experience git Git. This
document will be updated regularly as the core contributors get more
and more familiar with using git and GitHub. 

If you're familiar with branches, forks and pull requests, please
consider contributing using a Pull Request instead of pushing directly
to `main`. Pull Requests can be from a branch (if you have push rights
to this repo) or your own fork of this repo. If you're not familiar
with any of this, please read on.


<a id="orge0c6360"></a>

## Working on the files locally (i.e. on you computer)

1.  First of all download the files using `git clone`. You only have to this once.
    
        git clone https://github.com/OxfordRSE/NTDMC_trachoma_pipeline.git
2.  Make the changes you want, for instance edit `README.md`.
3.  [optional] List the modified files.
    
        git status
4.  [optional] View the changes compared to the last recorded snapshot (the last "commit").
    
        git diff
5.  Register your changes to include them in the next commit.
    
        git add README.md # Or any other file you modified
    
    If you modified several files, you can call `git add` multiple times, or pass them all to `git add`. e.g.
    
        git add file1 file2 file3 ...
6.  Commit (record) your changes in the history of the project.
    
        git commit -m "A short description of the changes"
7.  Back to step (2)

It's best practices to commit changes that are related to each other
together. For example, say you're working on a data analysis script
that manipulate some data then produces a plot. Say you modified part
of the analysis code, but also made some cosmetic changes to the way
the plot is presented. Ideally, you would make the first changes,
add/commit, then make the other changes then add/commit. It makes it
easier to understand the history of a project if individual commits
are specific to a particular change, as opposed to a mix of changes
that have little to do with one another. Try to keep this in mind, but
don't worry too much about it for now. We'll have opportunities to
revisit this as you're getting more familiar with git.


<a id="org741b5b7"></a>

## Sharing your changes

![img](https://github.com/MalikaIhle/Collaborative-RStudio-GitHub/blob/master/assets/new-overview.png)

The above drawing illustrates the current situation. We have a GitHub
repository (the blue REMOTE) and a local (understand "on your computer")
copy of the files (LOCAL). Let's ignore the pink stuff on the left for
now.

You've done some work on your local version, perhaps added a few
commits. Now you'd like to update the GitHub repository, so that your
changes are available to others.

To do so, "push" your changes:

    git push

That's it!
Well..
Most of the time.

If somebody else updated the GitHub repository while you were
working locally, git will refuse to push your changes before you
first update your local version.  It's a safety measure that
prevent several people to modify the same lines at the same time.

To update your local files, you can use 

    git pull

Git downloads the new commits that you don't yet have in your local
version of the project and merges them with yours. This operation
produces a new commit, called a "merge commit". At this point Git
will open a text editor for you to write a description for the
merge commit. It comes with a message by default, something like
"merge branch X into branch Y" which you can leave as it is. Simply save 
and close the editor.

One caveat. If the new commits that you "pull" from GitHub modify
lines that your new, local commits also modify, git will report a
"merge conflict". Nothing bad here, it's just that git cannot know
which is the "good" version&#x2026; yours? theirs? a combination of both?
If this happens, see below for [1.3](#org39f4f25). 

With your local copy up to date, you can now push your changes to GitHub:

    git push

Anyways, it's good practice to update your local copy of the files
before you start working on any of them. For this, use `git pull`.


<a id="org39f4f25"></a>

## TODO Handling merge conflicts


<a id="org74725de"></a>

## Summary of useful git commands

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">action</th>
<th scope="col" class="org-left">command</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Register all changes in a file</td>
<td class="org-left">`git status`</td>
</tr>


<tr>
<td class="org-left">Commit the registered changes (take a snapshot)</td>
<td class="org-left">`git diff`</td>
</tr>


<tr>
<td class="org-left">View the commit history</td>
<td class="org-left">`git log`</td>
</tr>


<tr>
<td class="org-left">List all modified files</td>
<td class="org-left">`git add <file>`</td>
</tr>


<tr>
<td class="org-left">View current changes compared to last commit</td>
<td class="org-left">`git commit -m 'Short description'`</td>
</tr>


<tr>
<td class="org-left">Update your local copy of the repo</td>
<td class="org-left">`git pull`</td>
</tr>


<tr>
<td class="org-left">Push your changes to the GitHub repo</td>
<td class="org-left">`git push`</td>
</tr>
</tbody>
</table>

