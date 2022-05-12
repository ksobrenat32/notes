# git notes

## Only clone latest commit

You can clone only the latest commit, this will reduce the storage
 needed.

```sh
git clone --depth=1 repo
```

## Pull repo with local changes

When you have cloned a repo and made local changes but you want to
 pull the newest commit, you can stash local changes, pull and
 stash pop

```sh
git stash
git pull
git stash pop
```

## Delete latest commit

Keeping the last commit changes local

```sh
git reset --soft HEAD^
# Make your fixes
git commit 
git push -f
```

Deleting last commit changes

```sh
git reset --hard HEAD^
git commit 
git push -f
```

If you want to remove multiple commits, you can use:

```sh
git reset --soft HEAD~2
```
