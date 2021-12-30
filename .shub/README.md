# <p align="center">ShubCoGen Template™ 💀</p>

## 💬 About

Skeleton GitHub Course Generator.

This project aims to be a template with some scripts for course projects deployed on GitHub.

## 📜 Requirements
- [Git](https://git-scm.com/)
- [Curl](https://curl.haxx.se/)
- [Bash](https://www.gnu.org/software/bash/)

## 🕹 Usage

## ☝️ First things first (once)
Use `./init.sh` to initialize your project.
This script will fill the `README.md` file with your project's information. And will create the `.shub-config` file.

### ❓ What will happen?

After running this script, you'll be prompted to enter your project's information and some configs. Don't worry, you can always change this later at `shub-config.json`.

> ⚠️ Important: You'll be prompt to enter a couse type (class, episode, etc), and after that to initialize a new branch base on the course type. If you choose so, you'll be able to use the deploy script, and automate tag creation, commit to notes.md files and deploy on GitHub (see the section below).

> 💡 You only need to do this **once**.  
> 💡 You can edit the `.shub-config` file to change the project's information.  
> 💡 You can user the `.shub-config` file in other projects to share your project's information.

## 🚀 Let's deploy

Use `./deploy.sh` to deploy your project on GitHub.

This script auto-increments the version number of the branch and creates a new tag from branch name.

So you must be in a branch with a number at the end, like `class-1` or `class-1.1`.

For example, if your actual branch is `class-1`, after running this script, the steps below will be performed:

1. A new tag `class-1-some-description` will be created
2. The actual branch will be automatically merged into `main`
3. The `main` branch will be sent to GitHub with the new tag (with `git push && git push --tags`)
4. A new branch `class-2` will be created
5. `notes.md` will be update with the new "project version number" like `## CLASS-2`

> 💡 This script is optional.

### ❓ What will happen?


### Optional arguments

```sh
./deploy.sh [-a] [-m message] [-h]
  -a: Accept all
  -m: Tag message
  -h: Help
```

#### -a Accept all suggestions, and deploy project.
#### -m Set tag message.
#### -h Show help.


## Features
- [x] `Readme.md` template
- [x] `notes.md` template
- [x] Deploy script (`deploy.sh`)
- [x] Deploy script arguments (`[-a] [-m message] [-h]`)
- [x] Self-update
- [x] Auto tagging


## 📌 Roadmap
- [ ] Improve `README.md`
- [ ] Add video tutorial to `deploy.sh` && `init.sh`
- [ ] Add technologies selection
- [ ] Add requirements selection
- [ ] Update version with GitHub API instead of version file
