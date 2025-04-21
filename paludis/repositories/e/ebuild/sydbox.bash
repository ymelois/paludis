#!/usr/bin/env bash
# vim: set sw=4 sts=4 et :

# Copyright (c) 2009, 2010, 2011, 2012, 2021, 2023, 2024, 2025 Ali Polatel <alip@chesswob.org>
#
# Based in part upon ebuild.sh from Portage, which is Copyright 1995-2005
# Gentoo Foundation and distributed under the terms of the GNU General
# Public License v2.
#
# This file is part of the Paludis package manager. Paludis is free software;
# you can redistribute it and/or modify it under the terms of the GNU General
# Public License, version 2, as published by the Free Software Foundation.
#
# Paludis is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA

sydbox_internal_api()
{
    if [[ -e /dev/sydbox/1 ]]; then
        echo -n 1
    else
        # FIXME: This is not ideal but otherwise some builds
        # fail. Since "esandbox check" is always called before
        # "sydbox_internal_api", this is safe until API 4
        # happens and there is a good chance API 4 will never
        # happen.
        echo -n 3
    fi
}

sydbox_internal_path_1()
{
    local cmd="${1}"
    local op="${2}"

    case "${op}" in
    '+'|'-')
        ;;
    *)
        die "${FUNCNAME}: invalid operation character '${op}'"
        ;;
    esac

    shift 2

    local path
    for path in "${@}"; do
        [[ "${path:0:1}" == '/' ]] || die "${FUNCNAME} expects absolute path, got: ${path}"
        [[ -e /dev/sydbox/"${cmd}${op}${path}" ]]
    done
}

sydbox_internal_path_3()
{
    local cmd="${1}"
    local op="${2}"

    case "${op}" in
    '+'|'-')
        ;;
    *)
        die "${FUNCNAME}: invalid operation character '${op}'"
        ;;
    esac

    shift 2

    local path
    for path in "${@}"; do
        [[ "${path:0:1}" == '/' ]] || die "${FUNCNAME} expects absolute path, got: ${path}"
        [[ -e /dev/syd/"${cmd}${op}${path}" ]]
    done
}

sydbox_internal_net_1()
{
    local cmd="${1}"
    local op="${2}"

    case "${op}" in
    '+'|'-')
        ;;
    *)
        die "${FUNCNAME}: invalid operation character '${op}'"
        ;;
    esac

    shift 2

    local addr
    for addr in "${@}"; do
        [[ -e /dev/sydbox/"${cmd}${op}${addr}" ]]
    done
}

sydbox_internal_net_3()
{
    local cmd="${1}"
    local op="${2}"

    case "${op}" in
    '+'|'-')
        ;;
    *)
        die "${FUNCNAME}: invalid operation character '${op}'"
        ;;
    esac

    shift 2
    while [[ ${#} > 0 ]] ; do
        case "${1}" in
        inet6:*)
            [[ -e "/dev/syd/${cmd}${op}${1##inet6:}" ]]
            ;;
        inet:*)
            [[ -e "/dev/syd/${cmd}${op}${1##inet:}" ]]
            ;;
        unix-abstract:*)
            # Sydbox prefixes UNIX abstract sockets with `@'.
            [[ -e "/dev/syd/${cmd}${op}@${1##unix-abstract:}" ]]
            ;;
        unix:*)
            [[ -e "/dev/syd/${cmd}${op}${1##unix:}" ]]
            ;;
        *)
            # Expect network alias.
            # Sydbox does input validation so we don't do any here.
            [[ -e "/dev/syd/${cmd}${op}${1}" ]]
            ;;
        esac
        shift
    done
}

esandbox_3()
{
    local cmd="${1}"

    shift
    case "${cmd}" in
    api)
        echo -n 3
        ;;
    check)
        [[ -e /dev/syd ]]
        ;;
    lock)
        [[ -e "/dev/syd/lock:on" ]]
        ;;
    exec_lock)
        [[ -e "/dev/syd/lock:exec" ]]
        ;;
    wait_all)
        ebuild_notice 'warning' "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
        false;;
    wait_eldest)
        ebuild_notice 'warning' "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
        false;;
    enabled|enabled_path)
        # Compatibility with syd-1:
        test -c '/dev/syd/sandbox/all?'
        ;;
    enable|enable_path)
        # Compatibility with syd-1:
        test -c '/dev/syd/sandbox/all:on'
        ;;
    disable|disable_path)
        # Compatibility with syd-1:
        test -c '/dev/syd/sandbox/all:off'
        ;;
    enabled_stat)
        [[ -e '/dev/syd/sandbox/stat?' ]]
        ;;
    enable_stat)
        [[ -e '/dev/syd/sandbox/stat:on' ]]
        ;;
    disable_stat)
        [[ -e '/dev/syd/sandbox/stat:off' ]]
        ;;
    enabled_read)
        [[ -e '/dev/syd/sandbox/read?' ]]
        ;;
    enable_read)
        [[ -e '/dev/syd/sandbox/read:on' ]]
        ;;
    disable_read)
        [[ -e '/dev/syd/sandbox/read:off' ]]
        ;;
    enabled_write)
        [[ -e '/dev/syd/sandbox/write?' ]]
        ;;
    enable_write)
        [[ -e '/dev/syd/sandbox/write:on' ]]
        ;;
    disable_write)
        [[ -e '/dev/syd/sandbox/write:off' ]]
        ;;
    enabled_exec)
        [[ -e '/dev/syd/sandbox/exec?' ]]
        ;;
    enable_exec)
        [[ -e '/dev/syd/sandbox/exec:on' ]]
        ;;
    disable_exec)
        [[ -e '/dev/syd/sandbox/exec:off' ]]
        ;;
    enabled_ioctl)
        [[ -e '/dev/syd/sandbox/ioctl?' ]]
        ;;
    enable_ioctl)
        [[ -e '/dev/syd/sandbox/ioctl:on' ]]
        ;;
    disable_ioctl)
        [[ -e '/dev/syd/sandbox/ioctl:off' ]]
        ;;
    enabled_create)
        [[ -e '/dev/syd/sandbox/create?' ]]
        ;;
    enable_create)
        [[ -e '/dev/syd/sandbox/create:on' ]]
        ;;
    disable_create)
        [[ -e '/dev/syd/sandbox/create:off' ]]
        ;;
    enabled_delete)
        [[ -e '/dev/syd/sandbox/delete?' ]]
        ;;
    enable_delete)
        [[ -e '/dev/syd/sandbox/delete:on' ]]
        ;;
    disable_delete)
        [[ -e '/dev/syd/sandbox/delete:off' ]]
        ;;
    enabled_rename)
        [[ -e '/dev/syd/sandbox/rename?' ]]
        ;;
    enable_rename)
        [[ -e '/dev/syd/sandbox/rename:on' ]]
        ;;
    disable_rename)
        [[ -e '/dev/syd/sandbox/rename:off' ]]
        ;;
    enabled_symlink)
        [[ -e '/dev/syd/sandbox/symlink?' ]]
        ;;
    enable_symlink)
        [[ -e '/dev/syd/sandbox/symlink:on' ]]
        ;;
    disable_symlink)
        [[ -e '/dev/syd/sandbox/symlink:off' ]]
        ;;
    enabled_truncate)
        [[ -e '/dev/syd/sandbox/truncate?' ]]
        ;;
    enable_truncate)
        [[ -e '/dev/syd/sandbox/truncate:on' ]]
        ;;
    disable_truncate)
        [[ -e '/dev/syd/sandbox/truncate:off' ]]
        ;;
    enabled_chdir)
        [[ -e '/dev/syd/sandbox/chdir?' ]]
        ;;
    enable_chdir)
        [[ -e '/dev/syd/sandbox/chdir:on' ]]
        ;;
    disable_chdir)
        [[ -e '/dev/syd/sandbox/chdir:off' ]]
        ;;
    enabled_readdir)
        [[ -e '/dev/syd/sandbox/readdir?' ]]
        ;;
    enable_readdir)
        [[ -e '/dev/syd/sandbox/readdir:on' ]]
        ;;
    disable_readdir)
        [[ -e '/dev/syd/sandbox/readdir:off' ]]
        ;;
    enabled_mkdir)
        [[ -e '/dev/syd/sandbox/mkdir?' ]]
        ;;
    enable_mkdir)
        [[ -e '/dev/syd/sandbox/mkdir:on' ]]
        ;;
    disable_mkdir)
        [[ -e '/dev/syd/sandbox/mkdir:off' ]]
        ;;
    enabled_rmdir)
        [[ -e '/dev/syd/sandbox/rmdir?' ]]
        ;;
    enable_rmdir)
        [[ -e '/dev/syd/sandbox/rmdir:on' ]]
        ;;
    disable_rmdir)
        [[ -e '/dev/syd/sandbox/rmdir:off' ]]
        ;;
    enabled_chown)
        [[ -e '/dev/syd/sandbox/chown?' ]]
        ;;
    enable_chown)
        [[ -e '/dev/syd/sandbox/chown:on' ]]
        ;;
    disable_chown)
        [[ -e '/dev/syd/sandbox/chown:off' ]]
        ;;
    enabled_chgrp)
        [[ -e '/dev/syd/sandbox/chgrp?' ]]
        ;;
    enable_chgrp)
        [[ -e '/dev/syd/sandbox/chgrp:on' ]]
        ;;
    disable_chgrp)
        [[ -e '/dev/syd/sandbox/chgrp:off' ]]
        ;;
    enabled_chmod)
        [[ -e '/dev/syd/sandbox/chmod?' ]]
        ;;
    enable_chmod)
        [[ -e '/dev/syd/sandbox/chmod:on' ]]
        ;;
    disable_chmod)
        [[ -e '/dev/syd/sandbox/chmod:off' ]]
        ;;
    enabled_chattr)
        [[ -e '/dev/syd/sandbox/chattr?' ]]
        ;;
    enable_chattr)
        [[ -e '/dev/syd/sandbox/chattr:on' ]]
        ;;
    disable_chattr)
        [[ -e '/dev/syd/sandbox/chattr:off' ]]
        ;;
    enabled_chroot)
        [[ -e '/dev/syd/sandbox/chroot?' ]]
        ;;
    enable_chroot)
        [[ -e '/dev/syd/sandbox/chroot:on' ]]
        ;;
    disable_chroot)
        [[ -e '/dev/syd/sandbox/chroot:off' ]]
        ;;
    enabled_utime)
        [[ -e '/dev/syd/sandbox/utime?' ]]
        ;;
    enable_utime)
        [[ -e '/dev/syd/sandbox/utime:on' ]]
        ;;
    disable_utime)
        [[ -e '/dev/syd/sandbox/utime:off' ]]
        ;;
    enabled_mkdev)
        [[ -e '/dev/syd/sandbox/mkdev?' ]]
        ;;
    enable_mkdev)
        [[ -e '/dev/syd/sandbox/mkdev:on' ]]
        ;;
    disable_mkdev)
        [[ -e '/dev/syd/sandbox/mkdev:off' ]]
        ;;
    enabled_mkfifo)
        [[ -e '/dev/syd/sandbox/mkfifo?' ]]
        ;;
    enable_mkfifo)
        [[ -e '/dev/syd/sandbox/mkfifo:on' ]]
        ;;
    disable_mkfifo)
        [[ -e '/dev/syd/sandbox/mkfifo:off' ]]
        ;;
    enabled_mktemp)
        [[ -e '/dev/syd/sandbox/mktemp?' ]]
        ;;
    enable_mktemp)
        [[ -e '/dev/syd/sandbox/mktemp:on' ]]
        ;;
    disable_mktemp)
        [[ -e '/dev/syd/sandbox/mktemp:off' ]]
        ;;
    enabled_net)
        [[ -e '/dev/syd/sandbox/net?' ]]
        ;;
    enable_net)
        [[ -e '/dev/syd/sandbox/net:on' ]]
        ;;
    disable_net)
        [[ -e '/dev/syd/sandbox/net:off' ]]
        ;;
    allow|allow_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        # Compatibility with syd-1:
        sydbox_internal_path_3 'allow/all' '+' "${@}"
        ;;
    disallow|disallow_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        # Compatibility with syd-1:
        sydbox_internal_path_3 'allow/all' '-' "${@}"
        ;;
    deny|deny_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        # Compatibility with syd-1:
        sydbox_internal_path_3 'deny/all' '+' "${@}"
        ;;
    nodeny|nodeny_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        # Compatibility with syd-1:
        sydbox_internal_path_3 'deny/all' '-' "${@}"
        ;;
    allow_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/stat' '+' "${@}"
        ;;
    disallow_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/stat' '-' "${@}"
        ;;
    deny_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/stat' '+' "${@}"
        ;;
    nodeny_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/stat' '-' "${@}"
        ;;
    allow_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/read' '+' "${@}"
        ;;
    disallow_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/read' '-' "${@}"
        ;;
    deny_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/read' '+' "${@}"
        ;;
    nodeny_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/read' '-' "${@}"
        ;;
    allow_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/write' '+' "${@}"
        ;;
    disallow_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/write' '-' "${@}"
        ;;
    deny_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/write' '+' "${@}"
        ;;
    nodeny_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/write' '-' "${@}"
        ;;
    allow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/exec' '+' "${@}"
        ;;
    disallow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/exec' '-' "${@}"
        ;;
    deny_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/exec' '+' "${@}"
        ;;
    nodeny_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/exec' '-' "${@}"
        ;;
    allow_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/ioctl' '+' "${@}"
        ;;
    disallow_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/ioctl' '-' "${@}"
        ;;
    deny_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/ioctl' '+' "${@}"
        ;;
    nodeny_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/ioctl' '-' "${@}"
        ;;
    allow_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/create' '+' "${@}"
        ;;
    disallow_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/create' '-' "${@}"
        ;;
    deny_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/create' '+' "${@}"
        ;;
    nodeny_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/create' '-' "${@}"
        ;;
    allow_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/delete' '+' "${@}"
        ;;
    disallow_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/delete' '-' "${@}"
        ;;
    deny_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/delete' '+' "${@}"
        ;;
    nodeny_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/delete' '-' "${@}"
        ;;
    allow_rename)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/rename' '+' "${@}"
        ;;
    disallow_rename)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/rename' '-' "${@}"
        ;;
    deny_rename)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/rename' '+' "${@}"
        ;;
    nodeny_rename)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/rename' '-' "${@}"
        ;;
    allow_symlink)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/symlink' '+' "${@}"
        ;;
    disallow_symlink)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/symlink' '-' "${@}"
        ;;
    deny_symlink)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/symlink' '+' "${@}"
        ;;
    nodeny_symlink)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/symlink' '-' "${@}"
        ;;
    allow_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/truncate' '+' "${@}"
        ;;
    disallow_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/truncate' '-' "${@}"
        ;;
    deny_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/truncate' '+' "${@}"
        ;;
    nodeny_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/truncate' '-' "${@}"
        ;;
    allow_chdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chdir' '+' "${@}"
        ;;
    disallow_chdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chdir' '-' "${@}"
        ;;
    deny_chdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chdir' '+' "${@}"
        ;;
    nodeny_chdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chdir' '-' "${@}"
        ;;
    allow_readdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/readdir' '+' "${@}"
        ;;
    disallow_readdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/readdir' '-' "${@}"
        ;;
    deny_readdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/readdir' '+' "${@}"
        ;;
    nodeny_readdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/readdir' '-' "${@}"
        ;;
    allow_mkdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mkdir' '+' "${@}"
        ;;
    disallow_mkdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mkdir' '-' "${@}"
        ;;
    deny_mkdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mkdir' '+' "${@}"
        ;;
    nodeny_mkdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mkdir' '-' "${@}"
        ;;
    allow_rmdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/rmdir' '+' "${@}"
        ;;
    disallow_rmdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/rmdir' '-' "${@}"
        ;;
    deny_rmdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/rmdir' '+' "${@}"
        ;;
    nodeny_rmdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/rmdir' '-' "${@}"
        ;;
    allow_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chown' '+' "${@}"
        ;;
    disallow_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chown' '-' "${@}"
        ;;
    deny_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chown' '+' "${@}"
        ;;
    nodeny_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chown' '-' "${@}"
        ;;
    allow_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chgrp' '+' "${@}"
        ;;
    disallow_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chgrp' '-' "${@}"
        ;;
    deny_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chgrp' '+' "${@}"
        ;;
    nodeny_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chgrp' '-' "${@}"
        ;;
    allow_chmod)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chmod' '+' "${@}"
        ;;
    disallow_chmod)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chmod' '-' "${@}"
        ;;
    deny_chmod)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chmod' '+' "${@}"
        ;;
    nodeny_chmod)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chmod' '-' "${@}"
        ;;
    allow_chattr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chattr' '+' "${@}"
        ;;
    disallow_chattr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chattr' '-' "${@}"
        ;;
    deny_chattr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chattr' '+' "${@}"
        ;;
    nodeny_chattr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chattr' '-' "${@}"
        ;;
    allow_chroot)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chroot' '+' "${@}"
        ;;
    disallow_chroot)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/chroot' '-' "${@}"
        ;;
    deny_chroot)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chroot' '+' "${@}"
        ;;
    nodeny_chroot)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/chroot' '-' "${@}"
        ;;
    allow_utime)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/utime' '+' "${@}"
        ;;
    disallow_utime)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/utime' '-' "${@}"
        ;;
    deny_utime)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/utime' '+' "${@}"
        ;;
    nodeny_utime)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/utime' '-' "${@}"
        ;;
    allow_mkdev)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mkdev' '+' "${@}"
        ;;
    disallow_mkdev)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mkdev' '-' "${@}"
        ;;
    deny_mkdev)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mkdev' '+' "${@}"
        ;;
    nodeny_mkdev)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mkdev' '-' "${@}"
        ;;
    allow_mkfifo)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mkfifo' '+' "${@}"
        ;;
    disallow_mkfifo)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mkfifo' '-' "${@}"
        ;;
    deny_mkfifo)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mkfifo' '+' "${@}"
        ;;
    nodeny_mkfifo)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mkfifo' '-' "${@}"
        ;;
    allow_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mktemp' '+' "${@}"
        ;;
    disallow_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'allow/mktemp' '-' "${@}"
        ;;
    deny_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mktemp' '+' "${@}"
        ;;
    nodeny_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'deny/mktemp' '-' "${@}"
        ;;
    allow_net)
        local c='allow/net/bind'
        case "${1}" in
        '--connect')
            c='allow/net/connect'
            shift;;
        '--sendfd')
            c='allow/net/sendfd'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '+' "${@}"
        ;;
    disallow_net)
        local c='allow/net/bind'
        case "${1}" in
        '--connect')
            c='allow/net/connect'
            shift;;
        '--sendfd')
            c='allow/net/sendfd'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '-' "${@}"
        ;;
    deny_net)
        local c='deny/net/bind'
        case "${1}" in
        '--connect')
            c='deny/net/connect'
            shift;;
        '--sendfd')
            c='deny/net/sendfd'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '+' "${@}"
        ;;
    nodeny_net)
        local c='deny/net/bind'
        case "${1}" in
        '--connect')
            c='deny/net/connect'
            shift;;
        '--sendfd')
            c='deny/net/sendfd'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '-' "${@}"
        ;;
    addfilter|addfilter_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/write' '+' "${@}"
        ;;
    rmfilter|rmfilter_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/write' '-' "${@}"
        ;;
    addfilter_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/stat' '+' "${@}"
        ;;
    rmfilter_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/stat' '-' "${@}"
        ;;
    addfilter_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/read' '+' "${@}"
        ;;
    rmfilter_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/read' '-' "${@}"
        ;;
    addfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/exec' '+' "${@}"
        ;;
    rmfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/exec' '-' "${@}"
        ;;
    addfilter_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/ioctl' '+' "${@}"
        ;;
    rmfilter_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/ioctl' '-' "${@}"
        ;;
    addfilter_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/create' '+' "${@}"
        ;;
    rmfilter_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/create' '-' "${@}"
        ;;
    addfilter_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/delete' '+' "${@}"
        ;;
    rmfilter_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/delete' '-' "${@}"
        ;;
    addfilter_rename)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/rename' '+' "${@}"
        ;;
    rmfilter_rename)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/rename' '-' "${@}"
        ;;
    addfilter_symlink)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/symlink' '+' "${@}"
        ;;
    rmfilter_symlink)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/symlink' '-' "${@}"
        ;;
    addfilter_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/truncate' '+' "${@}"
        ;;
    rmfilter_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/truncate' '-' "${@}"
        ;;
    addfilter_chdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chdir' '+' "${@}"
        ;;
    rmfilter_chdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chdir' '-' "${@}"
        ;;
    addfilter_readdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/readdir' '+' "${@}"
        ;;
    rmfilter_readdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/readdir' '-' "${@}"
        ;;
    addfilter_mkdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mkdir' '+' "${@}"
        ;;
    rmfilter_mkdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mkdir' '-' "${@}"
        ;;
    addfilter_rmdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/rmdir' '+' "${@}"
        ;;
    rmfilter_rmdir)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/rmdir' '-' "${@}"
        ;;
    addfilter_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chown' '+' "${@}"
        ;;
    rmfilter_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chown' '-' "${@}"
        ;;
    addfilter_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chgrp' '+' "${@}"
        ;;
    rmfilter_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chgrp' '-' "${@}"
        ;;
    addfilter_chmod)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chmod' '+' "${@}"
        ;;
    rmfilter_chmod)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chmod' '-' "${@}"
        ;;
    addfilter_chattr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chattr' '+' "${@}"
        ;;
    rmfilter_chattr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chattr' '-' "${@}"
        ;;
    addfilter_chroot)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chroot' '+' "${@}"
        ;;
    rmfilter_chroot)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/chroot' '-' "${@}"
        ;;
    addfilter_utime)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/utime' '+' "${@}"
        ;;
    rmfilter_utime)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/utime' '-' "${@}"
        ;;
    addfilter_mkdev)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mkdev' '+' "${@}"
        ;;
    rmfilter_mkdev)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mkdev' '-' "${@}"
        ;;
    addfilter_mkfifo)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mkfifo' '+' "${@}"
        ;;
    rmfilter_mkfifo)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mkfifo' '-' "${@}"
        ;;
    addfilter_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mktemp' '+' "${@}"
        ;;
    rmfilter_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/mktemp' '-' "${@}"
        ;;
    addfilter_net)
        local c='filter/net/bind'
        case "${1}" in
        '--connect')
            c='filter/net/connect'
            shift;;
        '--sendfd')
            c='filter/net/sendfd'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '+' "${@}"
        ;;
    rmfilter_net)
        local c='filter/net/bind'
        case "${1}" in
        '--connect')
            c='filter/net/connect'
            shift;;
        '--sendfd')
            c='filter/net/sendfd'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '-' "${@}"
        ;;
    exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        [[ -e "$(syd-exec ${@})" ]]
        ;;
    kill)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 'exec/kill' "+" "${@}"
        ;;
    resume)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        ebuild_notice 'warning' "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
        false;;
    hack_toolong|nohack_toolong)
        ebuild_notice 'warning' "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
        false;;
    *)
        die "${FUNCNAME} subcommand ${cmd} unrecognised"
        ;;
    esac
}

esandbox_1()
{
    local cmd="${1}"

    shift
    case "${cmd}" in
    api)
        echo -n 1
        ;;
    check)
        [[ -e /dev/sydbox ]]
        ;;
    lock)
        [[ -e '/dev/sydbox/core/trace/magic_lock:on' ]]
        ;;
    exec_lock)
        [[ -e '/dev/sydbox/core/trace/magic_lock:exec' ]]
        ;;
    wait_all)
        [[ -e '/dev/sydbox/core/trace/exit_wait_all:true' ]]
        ;;
    wait_eldest)
        [[ -e '/dev/sydbox/core/trace/exit_wait_all:false' ]]
        ;;
    enabled|enabled_path)
        [[ -e '/dev/sydbox/core/sandbox/write?' ]]
        ;;
    enable|enable_path)
        [[ -e '/dev/sydbox/core/sandbox/write:deny' ]]
        ;;
    disable|disable_path)
        [[ -e '/dev/sydbox/core/sandbox/write:off' ]]
        ;;
    enabled_stat)
        false
        ;;
    enable_stat)
        : # no-op, only supported for syd[>=3]
        ;;
    disable_stat)
        : # no-op, only supported for syd[>=3]
        ;;
    enabled_read)
        false
        ;;
    enable_read)
        : # no-op, only supported for syd[>=3]
        ;;
    disable_read)
        : # no-op, only supported for syd[>=3]
        ;;
    enabled_write|enabled_ioctl|enabled_create|enabled_delete|enabled_rename|enabled_symlink|enabled_truncate|enabled_chdir|enabled_readdir|enabled_mkdir|enabled_rmdir|enabled_chown|enabled_chgrp|enabled_chmod|enabled_chattr|enabled_chroot|enabled_utime|enabled_mkdev|enabled_mkfifo|enabled_mktemp)
        [[ -e '/dev/sydbox/core/sandbox/write?' ]]
        ;;
    enable_write|enable_ioctl|enable_create|enable_delete|enable_rename|enable_symlink|enable_truncate|enable_chdir|enable_readdir|enable_mkdir|enable_rmdir|enable_chown|enable_chgrp|enable_chmod|enable_chattr|enable_chroot|enable_utime|enable_mkdev|enable_mkfifo|enable_mktemp)
        [[ -e '/dev/sydbox/core/sandbox/write:deny' ]]
        ;;
    disable_write|disable_ioctl|disable_create|disable_delete|disable_rename|disable_symlink|disable_truncate|disable_chdir|disable_readdir|disable_mkdir|disable_rmdir|disable_chown|disable_chgrp|disable_chmod|disable_chattr|disable_chroot|disable_utime|disable_mkdev|disable_mkfifo|disable_mktemp)
        [[ -e '/dev/sydbox/core/sandbox/write:off' ]]
        ;;
    enabled_exec)
        [[ -e '/dev/sydbox/core/sandbox/exec?' ]]
        ;;
    enable_exec)
        [[ -e '/dev/sydbox/core/sandbox/exec:deny' ]]
        ;;
    disable_exec)
        [[ -e '/dev/sydbox/core/sandbox/exec:off' ]]
        ;;
    enabled_net)
        [[ -e '/dev/sydbox/core/sandbox/network?' ]]
        ;;
    enable_net)
        [[ -e '/dev/sydbox/core/sandbox/network:deny' ]]
        ;;
    disable_net)
        [[ -e '/dev/sydbox/core/sandbox/network:off' ]]
        ;;
    deny_net|nodeny_net)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    allow|allow_path|allow_write|allow_ioctl|allow_create|allow_delete|allow_rename|allow_symlink|allow_truncate|allow_chdir|allow_readdir|allow_mkdir|allow_rmdir|allow_chown|allow_chgrp|allow_chmod|allow_chroot|allow_utime|allow_mkdev|allow_mkfifo|allow_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'whitelist/write' '+' "${@}"
        ;;
    disallow|disallow_path|disallow_write|disallow_ioctl|disallow_create|disallow_delete|disallow_rename|disallow_symlink|disallow_truncate|disallow_chdir|disallow_readdir|disallow_mkdir|disallow_rmdir|disallow_chown|disallow_chgrp|disallow_chmod|disallow_chroot|disallow_utime|disallow_mkdev|disallow_mkfifo|disallow_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'whitelist/write' '-' "${@}"
        ;;
    deny_write|deny_ioctl|deny_create|deny_delete|deny_rename|deny_symlink|deny_truncate|deny_chdir|deny_readdir|deny_mkdir|deny_rmdir|deny_chown|deny_chgrp|deny_chmod|deny_chroot|deny_utime|deny_mkdev|deny_mkfifo|deny_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    nodeny_write|nodeny_ioctl|nodeny_create|nodeny_delete|nodeny_rename|nodeny_symlink|nodeny_truncate|nodeny_chdir|nodeny_readdir|nodeny_mkdir|nodeny_rmdir|nodeny_chown|nodeny_chgrp|nodeny_chmod|nodeny_chroot|nodeny_utime|nodeny_mkdev|nodeny_mkfifo|nodeny_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    allow_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    disallow_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    deny_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    nodeny_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    allow_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    disallow_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    deny_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    nodeny_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    allow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'whitelist/exec' '+' "${@}"
        ;;
    disallow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'whitelist/exec' '-' "${@}"
        ;;
    allow_net)
        local c='whitelist/network/bind'
        [[ "${1}" == '--connect' ]] && c='whitelist/network/connect' && shift
        [[ "${1}" == '--sendfd' ]] && c='whitelist/network/connect' && shift
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 "${c}" '+' "${@}"
        ;;
    disallow_net)
        local c='whitelist/network/bind'
        [[ "${1}" == '--connect' ]] && c='whitelist/network/connect' && shift
        [[ "${1}" == '--sendfd' ]] && c='whitelist/network/connect' && shift
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 "${c}" '-' "${@}"
        ;;
    addfilter|addfilter_path|addfilter_write|addfilter_ioctl|addfilter_create|addfilter_delete|addfilter_rename|addfilter_symlink|addfilter_truncate|addfilter_chdir|addfilter_readdir|addfilter_mkdir|addfilter_rmdir|addfilter_chown|addfilter_chgrp|addfilter_chmod|addfilter_chroot|addfilter_utime|addfilter_mkdev|addfilter_mkfifo|addfilter_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/write' '+' "${@}"
        ;;
    rmfilter|rmfilter_path|rmfilter_write|rmfilter_ioctl|rmfilter_create|rmfilter_delete|rmfilter_rename|rmfilter_symlink|rmfilter_truncate|rmfilter_chdir|rmfilter_readdir|rmfilter_mkdir|rmfilter_rmdir|rmfilter_chown|rmfilter_chgrp|rmfilter_chmod|rmfilter_chroot|rmfilter_utime|rmfilter_mkdev|rmfilter_mkfifo|rmfilter_mktemp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/write' '-' "${@}"
        ;;
    addfilter_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    rmfilter_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    addfilter_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    rmfilter_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    addfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/exec' '+' "${@}"
        ;;
    rmfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'filter/exec' '-' "${@}"
        ;;
    addfilter_net)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 'filter/network' '+' "${@}"
        ;;
    rmfilter_net)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 'filter/network' '-' "${@}"
        ;;
    exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        [[ -e "$(sydfmt exec -- ${@})" ]]
        ;;
    kill)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'exec/kill_if_match' "+" "${@}"
        ;;
    resume)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 'exec/resume_if_match' "+" "${@}"
        ;;
    hack_toolong|nohack_toolong)
        ebuild_notice 'warning' "${FUNCNAME} ${cmd} is not implemented for sydbox-1"
        false;;
    *)
        die "${FUNCNAME} subcommand ${cmd} unrecognised"
        ;;
    esac
}

esandbox() {
    local api

    # We must run check before API check because it's special.
    if [[ "${1}" == check ]]; then
        if test -e /dev/syd || test -e /dev/sydbox; then
            return 0
        else
            return 1
        fi
    fi

    api="$(sydbox_internal_api)"
    case "${api}" in
    3)
        esandbox_3 "${@}";;
    1)
        esandbox_1 "${@}";;
    0)
        die "${FUNCNAME}: unsupported sydbox API '${api}'"
        ;;
    *)
        die "${FUNCNAME}: unrecognised sydbox API '${api}'"
        ;;
    esac
}

sydboxcheck()
{
    ebuild_notice 'warning' "${FUNCNAME} is deprecated, use \"esandbox check\" instead"
    esandbox check
}

sydboxcmd()
{
    die "${FUNCNAME} is dead, use \"esandbox <command>\" instead"
}

addread()
{
    die "${FUNCNAME} not implemented for sydbox yet"
}

addwrite()
{
    ebuild_notice 'warning' "${FUNCNAME} is deprecated, use \"esandbox allow\" instead"
    esandbox allow "${1}"
}

adddeny()
{
    die "${FUNCNAME} not implemented for sydbox yet"
}

addpredict()
{
    die "${FUNCNAME} is dead, use \"esandbox addfilter\" instead"
}

rmwrite()
{
    ebuild_notice 'warning' "${FUNCNAME} is deprecated, use \"esandbox disallow\" instead"
    esandbox disallow "${1}"
}

rmpredict()
{
    die "${FUNCNAME} is dead, use \"esandbox rmfilter\" instead"
}

addfilter()
{
    ebuild_notice 'warning' "${FUNCNAME} is deprecated, use \"esandbox addfilter\" instead"
    esandbox addfilter "${1}"
}

rmfilter()
{
    ebuild_notice 'warning' "${FUNCNAME} is deprecated, use \"esandbox rmfilter\" instead"
    esandbox rmfilter "${1}"
}

