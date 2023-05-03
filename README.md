# Unit tested Shell/Bash code template

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

Automatically installs your own, private, self-hosted calendar, accessible from
anywhere, on your laptop and phone, with a single command, for free, over tor.
No need to buy a domain name, no port-forwarding, no dns settings.

## Usage

The main code can be ran with:

```sh
src/main.sh
```

## Example Setup

This is when the installation was already done and you would like to retry it.

```sh
src/main.sh -un # uninstall Nextcloud
src/main.sh -i # install Tor and Nextcloud
src/main.sh -cn # Configure Nextcloud

src/main.sh --configure-nextcloud \
  --nextcloud-password \
  --verbose

# Configure https tor for Nextcloud.
src/main.sh --configure-tor \
  --local-nextcloud-port 7990 \
  --external-nextcloud-port 7995 \
  --ssl-password somepassword \
  --verbose

src/main.sh -cs # Enable the Nextcloud Calendar application.
src/main.sh -h # Setup https/ssl and make firefox trust it.
src/main.sh -ar Orbot,DAVx5
src/main.sh -ac Orbot,DAVx5 -nu root -np
```

## Testing

Put your unit test files (with extension .bats) in folder: `/test/`

### Prerequisites

(Re)-install the required submodules with:

```sh
chmod +x install-bats-libs.sh
./install-bats-libs.sh
```

Install:

```sh
sudo gem install bats
sudo gem install bashcov
sudo apt install shfmt -y
pre-commit install
pre-commit autoupdate
```

### Pre-commit

Run pre-commit with:

```sh
pre-commit run --all
```

### Tests

Run the tests with:

```sh
bats test
```

If you want to run particular tests, you could use the `test.sh` file:

```sh
chmod +x test.sh
./test.sh
```

### Code coverage

```sh
bashcov bats test
```

## Objectives

- [ ] Include arg parser to allow user to select between:
  - [ ] Server
  - [ ] Client
  - [ ] Phone
    installation.
- [ ] Automatically set up Nextcloud calendar accessible over tor.
- [ ] Add a local calendar viewing app like thunderbird to prevent having to wait
  on the onion domain loading every   time you wanna access your calendar. add
  torsocks to that local viewing app, such that it syncs automatically. Ensure
  it does not sync locally, but over tor.
- [ ] Automatically set up calendar sync over tor for android app.
- [ ] Get API to add taskwarrior tasks.
- [ ] Allow users to share an obfuscated calendar to enable people to make an
  appointment with the user at an allowed slot, without seeing user activity.
- [ ] Include travel times in calendar planner.

## How to help

- Include bash code coverage in GitLab CI.
- Add [additional](https://pre-commit.com/hooks.html) (relevant) pre-commit hooks.
- Develop Bash documentation checks
  [here](https://github.com/TruCol/checkstyle-for-bash), and add them to this
  pre-commit.
