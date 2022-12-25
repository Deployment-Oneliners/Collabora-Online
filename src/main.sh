#!/usr/bin/env bash
source src/install/prereq_nextcloud.sh
say_hello() {
  echo "Hello world"
}
say_hello

# 0.a Install prerequisites for Nextcloud.
satisfy_nextcloud_prereq
# 0.b Verify prerequisites for Nextcloud are installed.

# 1.a Install nextcloud
# 1.b Verify Nextcloud is installed.

# 2.a Install tor
# 2.b Verify tor is installed.

# 3.a Detect tor configuration.
# 3.b Modify tor configuration based on detected config.
# 3.c Verify tor config is modified correctly.

# 4.a Restart tor.
# 4.b Verify tor is restarted successfully.

# 5.a Get onion domain.
# 5.b. Restart tor.
# 5.c Verify tor is restarted successfully.
# 5.d Verify onion domain is accessible.

# 6.a Proxify calendar app to go over tor to Nextcloud on client.
# 6.b Verify calendar app goes over tor to Nextcloudon client.

# 7.a Install calendar app on android.
# 7.b Verify calendar app is installed on android.
# 7.c Proxify calendar app to go over tor to Nextcloud on Android.
# 7.b Verify calendar app goes over tor to Nextcloud on Android.
