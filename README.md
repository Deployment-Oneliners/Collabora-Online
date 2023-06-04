# Self-hosted Nextcloud over Tor

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

One command to set up your self-hosted:

- Nextcloud over tor, with https.
- Calendar sync with your android phone, over tor, with https.
- Command-line calendar interface.
- Exponential backups.

No need to buy a domain name, no port-forwarding, no dns settings, no nothing.
Tested (manually) on Ubuntu 22.10.

## Usage - Khal

- The Nextcloud calendar can be visited at [https://localhost:`<your port>`](https://localhost:7995).
- The Android calendar is used like you always use it, this just sets up the
  sync with your own laptop/server in the background (over tor).
- To use the CLI calendar type:

```bash
khal interactive -a personal # Specify you want to edit calendar: "personal".
```

and after you are done adding/changing/deleting your calendar appointments, run:

```bash
vdirsyncer sync
```

## Example Setup

This is when the installation was already done and you would like to retry it.

```sh
src/main.sh -un # uninstall Nextcloud

src/main.sh \
  --configure-nextcloud \
  --configure-tor \
  --local-http-nextcloud-port 80 \
  --local-https-nextcloud-port 7995 \
  --external-nextcloud-port 7995 \
  --ssl-password somepassword \
  --verbose

src/main.sh --calendar-server # Enable the Nextcloud Calendar application.

# Install Calendar CLI and sync.
src/main.sh --calendar-client \
 --nextcloud-username root \
 --external-nextcloud-port 7995 \
 --nextcloud-password

# Install Taskwarrior sync
src/main.sh --taskwarrior-sync \
--local-https-nextcloud-port 7995 \
--nextcloud-username root \
--nextcloud-password


# Setup Android phone sync.
src/main.sh --android-reinstall Orbot,DAVx5
src/main.sh --android-configure Orbot,DAVx5 \
  --nextcloud-username root \
  --external-nextcloud-port 7995 \
  --nextcloud-password
```

## Uninstallation

```bash
src/main.sh --uninstall-calendar-client # Remove vdirsyncer and khal from client.
```

## Automatic Exponential Backups

Ps. this works, but it still needs sudo, which is quite inelegant for the cronjob.

The exponential part means in this context: the further back in time, the
fewer backups you keep. To set up a cronjob that automatically backs up your
entire Nextcloud, run:

```sh
chmod +x src/backup/*.sh
sudo src/backup/./create_cronjob.sh
```

That's it. See below on how to restore any of those backups.

## Manual Backups

To manually create a backup file in:
`/home/$USERNAME/Nextcloud/backups/<YYYYMMDD>-HHMMSS.tar.gz`, run:

```sh
src/backup/./manage_daily_backup.sh
```

You can restore that backup file with:

```sh
sudo src/backup/./import_data -a -b -c -d /home/oem/Nextcloud/backups/20230525-032501
```

Note the file extension is dropped for the import.

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

- [x] Include arg parser to allow user to select between:
  - [x] Server
  - [x] Client
  - [x] Phone
    installation.
- [x] Automatically set up Nextcloud calendar accessible over tor.
- [x] Add a local calendar viewing app like thunderbird to prevent having to wait
  on the onion domain loading every   time you wanna access your calendar. add
  torsocks to that local viewing app, such that it syncs automatically. Ensure
  it does not sync locally, but over tor.
- [x] Automatically set up calendar sync over tor for android app.
- [ ] Get API to add taskwarrior tasks.
- [ ] Allow users to share an obfuscated calendar to enable people to make an
  appointment with the user at an allowed slot, without seeing user activity.
- [ ] Include travel times in calendar planner.

## How to help

- Remove the need for sudo for the backups.
- Fix importing the Nextcloud config backup.
- Improve code quality.
- Include bash code coverage in GitLab CI.
- Add [additional](https://pre-commit.com/hooks.html) (relevant) pre-commit hooks.
- Develop Bash documentation checks
  [here](https://github.com/TruCol/checkstyle-for-bash), and add them to this
  pre-commit.
