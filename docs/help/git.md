
### SSH private key
    eval `ssh-agent`
    git remote set-url origin git@github.com:${Username}/${Project}.git
    git push

### Remove gitignored files from repo without deleting them from disk
    git rm --cached -r .
    git add .
    git commit -m "remove gitignored files"
    git push

### Set username and email
    git config --global user.name "UserName"
    git config --global user.email "[MY_NAME@example.com](mailto:MY_NAME@example.com)"

### Clone with Personal Token
> git clone https://PERSONALTOKEN@github.com/username/repo.git
  
### Tag the current commit
> git tag -a v1.0.0 -m "Releasing version v1.0.0"
  
### List tags
>git tag -l -n3

### Push tags
> git push origin --tags

### List all commits having tags

> git tag | xargs -n1 git rev-list -n 1


## Rebasing

Set reasonable editor
> git config --global core.editor 'nvim +start'

> git rebase -i target

Then delete useless lines and save
In case of error:
> git rebase --edit-todo

## Simple approach to Git

Put these in your ~/.gitconfig


## The three trees of Git
1. The HEAD = parent of current commit
> git cat-file -p HEAD

2. Index = the staging grounds for the next commit
> git ls-files -s

3. Work dir = current files in folder

## The three resets
1. Change HEAD, Index, work dir to another commit (full replace)
> reset --hard 123commit

2. Change HEAD and Index to another commit. The files will now be diffed against that commit
> reset 123commit

3. Change only HEAD to another commit
> reset --soft 123commit


[alias]

  # *********************

  # Rebase workflow

    mainbranch = "!git remote show origin | sed -n '/HEAD branch/s/.*: //p'"

    synced = "!git pull origin $(git mainbranch) --rebase"

    update = "!git pull origin $(git rev-parse --abbrev-ref HEAD) --rebase"

    squash = "!git rebase -v -i $(git mainbranch)"

    publish = push origin HEAD --force-with-lease

    pub = publish

  

## Publish your branch’s changes to the world

The publish (abbrev pub) command publishes your changes to your branch Github. If other changes have been posted by another user to Github, then changes will be rejected. You should update first to incoroporate their changes and resolve any conflicts.

git publish

git pub

  

Under the hood this is a [force push with lease](https://stackoverflow.com/a/52823955/8123) to your branch at origin.

## Sync your branch with main / master from Github

The synced command will get your local branch up to date with your main branch (main or master) at origin (ie Github).

git synced

  

Under the hood, this fetches main or master from origin and performs a [rebase](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase), replaying your commits on top of the tip of main or master.

## Update your branch with Github’s copy of your branch

If your local branch gets out of date with origin’s version of your branch, then do an update. This would happen if you’re collaborating on the branch with a colleague and need to get up to date.

git update
  
Under the hood, this fetches origin/your-branch and performs a [rebase](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase).

## Squash commits

Prior to merging, you likely want to shrink your branch’s many noisy commits to one or two meaningful ones. That’s what squash command does, giving you a chance to rewrite the branch’s history.

git squash

  

Under the hood, this is an [interactive rebase](https://thoughtbot.com/blog/git-interactive-rebase-squash-amend-rewriting-history).

# Other useful commands

-   git pr -> Open this PR at github.com
    
-   git hub -> Open this repo at github.com
    
-   git amend -> Alias for git commit --amend
    
-   git ammend -> How I always misspell ‘amend’, also alias for git commit --amend
    

 # ********************

  # My dumbass typos

    ammend = commit --amend 

    amend = commit --amend 

  

  # *********************

  # Github

  # From - https://salferrarello.com/git-alias-open-pull-request-github/

    pr = "!f() { \

       open \"$(git ls-remote --get-url $(git config --get branch.$(git rev-parse --abbrev-ref HEAD).remote) \

       | sed 's|git@github.com:\\(.*\\)$|https://github.com/\\1|' \

       | sed 's|\\.git$||'; \

       )/compare/$(\

       git config --get branch.$(git rev-parse --abbrev-ref HEAD).merge | cut -d '/' -f 3- \

       )?expand=1\"; \

  }; f"

    hub = "!f() { \

       open \"$(git ls-remote --get-url \

       | sed 's|git@github.com:\\(.*\\)$|https://github.com/\\1|' \

       | sed 's|\\.git$||'; \

       )\"; \

  }; f"
