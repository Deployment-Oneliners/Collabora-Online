#!/usr/bin/env bash

vdirsyncer_initial_sync() {
  vdirsyncer discover my_contacts
  vdirsyncer discover my_calendar
  vdirsyncer sync
}

vdirsyncer_initial_sync_over_tor() {
  torify vdirsyncer discover my_contacts
  torify vdirsyncer discover my_calendar
  torify vdirsyncer sync
}
