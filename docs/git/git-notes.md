# Git notes

## Initial setup

### Creating ssh keys

To use git with ssh, you need to create ssh keys. Here is how you can do it:

```bash
# Generate a new ssh key
ssh-keygen -o -a 100 -t ed25519 -f /path/to/key -C "your@email.com"

# Change passphrase
ssh-keygen -p -f /path/to/key
```

### Configuring git

It is important to configure git before using it. Here are some basic configurations:

```bash
# Configure name
git config --global user.name "Your Name"

# Configure email
git config --global user.email "your@email.com"

# Configure editor
git config --global core.editor "vim"

# Configure color
git config --global color.ui auto
```

## Working with repositories

### Creating a repository

To create a repository, you can either turn a directory into a git repository or clone a repository.

```bash
# Turn a directory into a git repository
git init

# Clone a repository
git clone <url>

# Clone only the latest commit
git clone --depth=1 <url>
```

s## Staging files

Git has a staging area where you can add files before committing them.

```bash
# Add a file to the staging area
git add <file>

# Add all files to the staging area
git add .

# Remove a file from the staging area
git reset <file>

# Remove all files from the staging area
git reset
```

### Committing changes

After adding files to the staging area, you can commit them. This will create a snapshot of the repository at that point.

```bash
# Commit changes
git commit -m "Message"

# Commit changes with a message on the editor
git commit
```

### Checking the status

You can check the status of the repository at any time. Which files are staged, which files are not, etc.

```bash
# Check the status of the repository
git status
```

s## Syncing changes

You can sync changes with a remote repository. This is useful when working with others.

```bash
# Push changes to a remote repository
git push <remote> <branch>

# Force push changes to a remote repository
git push -f <remote> <branch>

# Pull changes from a remote repository
git pull <remote> <branch>

# Fetch changes from a remote repository
git fetch <remote>

# Merge changes from a remote repository
git merge <remote>/<branch>
```
### Logging

You can check the history of the repository at any time.

```bash
# Show the history of the repository
git log

# Show differences between the working directory and the staging area
git diff

# Show differences between commits
git diff <commit> <commit>

# Show differences between the working directory and the last commit
git diff HEAD
```

### Moving around

You can move around the history of the repository.

```bash
# Go to the last commit
git checkout HEAD

# Go to a specific commit
git checkout <commit>

# Go to the previous commit
git checkout HEAD^

# Go to the next commit
git checkout HEAD@{1}
```

### Reverting changes

You can revert changes in the repository from a specific commit.

```bash
# Reverse a commit
git revert <commit>

# Reset the repository to a previous commit
git reset <commit>

# Reset the repository to a previous commit and keep the changes
git reset --soft <commit>

# Reset the repository to a previous commit and discard the changes
git reset --hard <commit>
```

### Stashing changes

You can stash changes in the repository. This is useful when you want to work on something else.

```bash
# Stash changes
git stash

# Apply stashed changes
git stash apply

# List stashed changes
git stash list

# Drop stashed changes
git stash drop
```

### Branching

Branching is a powerful feature of git. You can create branches to work on new features, bug fixes, etc. without affecting the main branch.

```bash
# List branches
git branch -a

# Create a branch
git branch <branch>

# Switch to a branch
git checkout <branch>

# Create a branch and switch to it
git checkout -b <branch>

# Delete a branch
git branch -d <branch>

# Merge a branch
git merge <branch>
```
