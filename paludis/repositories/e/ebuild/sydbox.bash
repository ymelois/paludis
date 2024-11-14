#!/usr/bin/env bash
# vim: set sw=4 sts=4 et :

# Copyright (c) 2009, 2010, 2011, 2012, 2021, 2023, 2024 Ali Polatel <alip@chesswob.org>
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
            [[ -e "/dev/syd/${cmd}${op}${1##unix-abstract:}" ]]
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
        # [[ -e /dev/syd ]]
        # The stat above will not work when SydB☮x is locked, however
        # syd-chk works regardless of the state of the sandbox lock.
        syd-chk
        ;;
    lock)
        [[ -e "/dev/syd/lock:on" ]]
        ;;
    exec_lock)
        [[ -e "/dev/syd/lock:exec" ]]
        ;;
    wait_all)
        ebuild_notice "warning" "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
        false;;
    wait_eldest)
        ebuild_notice "warning" "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
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
    enabled_read)
        [[ -e "/dev/syd/sandbox/read?" ]]
        ;;
    enable_read)
        [[ -e "/dev/syd/sandbox/read:on" ]]
        ;;
    disable_read)
        [[ -e "/dev/syd/sandbox/read:off" ]]
        ;;
    enabled_stat)
        [[ -e "/dev/syd/sandbox/stat?" ]]
        ;;
    enable_stat)
        [[ -e "/dev/syd/sandbox/stat:on" ]]
        ;;
    disable_stat)
        [[ -e "/dev/syd/sandbox/stat:off" ]]
        ;;
    enabled_write)
        [[ -e "/dev/syd/sandbox/write?" ]]
        ;;
    enable_write)
        [[ -e "/dev/syd/sandbox/write:on" ]]
        ;;
    disable_write)
        [[ -e "/dev/syd/sandbox/write:off" ]]
        ;;
    enabled_create)
        [[ -e "/dev/syd/sandbox/create?" ]]
        ;;
    enable_create)
        [[ -e "/dev/syd/sandbox/create:on" ]]
        ;;
    disable_create)
        [[ -e "/dev/syd/sandbox/create:off" ]]
        ;;
    enabled_delete)
        [[ -e "/dev/syd/sandbox/delete?" ]]
        ;;
    enable_delete)
        [[ -e "/dev/syd/sandbox/delete:on" ]]
        ;;
    disable_delete)
        [[ -e "/dev/syd/sandbox/delete:off" ]]
        ;;
    enabled_truncate)
        [[ -e "/dev/syd/sandbox/truncate?" ]]
        ;;
    enable_truncate)
        [[ -e "/dev/syd/sandbox/truncate:on" ]]
        ;;
    disable_truncate)
        [[ -e "/dev/syd/sandbox/truncate:off" ]]
        ;;
    enabled_attr)
        [[ -e "/dev/syd/sandbox/attr?" ]]
        ;;
    enable_attr)
        [[ -e "/dev/syd/sandbox/attr:on" ]]
        ;;
    disable_attr)
        [[ -e "/dev/syd/sandbox/attr:off" ]]
        ;;
    enabled_chown)
        [[ -e "/dev/syd/sandbox/chown?" ]]
        ;;
    enable_chown)
        [[ -e "/dev/syd/sandbox/chown:on" ]]
        ;;
    disable_chown)
        [[ -e "/dev/syd/sandbox/chown:off" ]]
        ;;
    enabled_chgrp)
        [[ -e "/dev/syd/sandbox/chgrp?" ]]
        ;;
    enable_chgrp)
        [[ -e "/dev/syd/sandbox/chgrp:on" ]]
        ;;
    disable_chgrp)
        [[ -e "/dev/syd/sandbox/chgrp:off" ]]
        ;;
    enabled_ioctl)
        [[ -e "/dev/syd/sandbox/ioctl?" ]]
        ;;
    enable_ioctl)
        [[ -e "/dev/syd/sandbox/ioctl:on" ]]
        ;;
    disable_ioctl)
        [[ -e "/dev/syd/sandbox/ioctl:off" ]]
        ;;
    enabled_node)
        [[ -e "/dev/syd/sandbox/node?" ]]
        ;;
    enable_node)
        [[ -e "/dev/syd/sandbox/node:on" ]]
        ;;
    disable_node)
        [[ -e "/dev/syd/sandbox/node:off" ]]
        ;;
    enabled_tmpfile)
        [[ -e "/dev/syd/sandbox/tmpfile?" ]]
        ;;
    enable_tmpfile)
        [[ -e "/dev/syd/sandbox/tmpfile:on" ]]
        ;;
    disable_tmpfile)
        [[ -e "/dev/syd/sandbox/tmpfile:off" ]]
        ;;
    enabled_exec)
        [[ -e "/dev/syd/sandbox/exec?" ]]
        ;;
    enable_exec)
        [[ -e "/dev/syd/sandbox/exec:on" ]]
        ;;
    disable_exec)
        [[ -e "/dev/syd/sandbox/exec:off" ]]
        ;;
    enabled_net)
        [[ -e "/dev/syd/sandbox/net?" ]]
        ;;
    enable_net)
        [[ -e "/dev/syd/sandbox/net:on" ]]
        ;;
    disable_net)
        [[ -e "/dev/syd/sandbox/net:off" ]]
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
    allow_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/read" '+' "${@}"
        ;;
    disallow_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/read" '-' "${@}"
        ;;
    deny_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/read" '+' "${@}"
        ;;
    nodeny_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/read" '-' "${@}"
        ;;
    allow_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/stat" '+' "${@}"
        ;;
    disallow_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/stat" '-' "${@}"
        ;;
    deny_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/stat" '+' "${@}"
        ;;
    nodeny_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/stat" '-' "${@}"
        ;;
    allow_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/write" '+' "${@}"
        ;;
    disallow_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/write" '-' "${@}"
        ;;
    deny_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/write" '+' "${@}"
        ;;
    nodeny_write)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/write" '-' "${@}"
        ;;
    allow_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/create" '+' "${@}"
        ;;
    disallow_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/create" '-' "${@}"
        ;;
    deny_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/create" '+' "${@}"
        ;;
    nodeny_create)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/create" '-' "${@}"
        ;;
    allow_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/delete" '+' "${@}"
        ;;
    disallow_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/delete" '-' "${@}"
        ;;
    deny_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/delete" '+' "${@}"
        ;;
    nodeny_delete)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/delete" '-' "${@}"
        ;;
    allow_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/truncate" '+' "${@}"
        ;;
    disallow_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/truncate" '-' "${@}"
        ;;
    deny_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/truncate" '+' "${@}"
        ;;
    nodeny_truncate)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/truncate" '-' "${@}"
        ;;
    allow_attr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/attr" '+' "${@}"
        ;;
    disallow_attr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/attr" '-' "${@}"
        ;;
    deny_attr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/attr" '+' "${@}"
        ;;
    nodeny_attr)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/attr" '-' "${@}"
        ;;
    allow_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/chown" '+' "${@}"
        ;;
    disallow_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/chown" '-' "${@}"
        ;;
    deny_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/chown" '+' "${@}"
        ;;
    nodeny_chown)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/chown" '-' "${@}"
        ;;
    allow_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/chgrp" '+' "${@}"
        ;;
    disallow_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/chgrp" '-' "${@}"
        ;;
    deny_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/chgrp" '+' "${@}"
        ;;
    nodeny_chgrp)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/chgrp" '-' "${@}"
        ;;
    allow_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/ioctl" '+' "${@}"
        ;;
    disallow_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/ioctl" '-' "${@}"
        ;;
    deny_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/ioctl" '+' "${@}"
        ;;
    nodeny_ioctl)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/ioctl" '-' "${@}"
        ;;
    allow_node)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/node" '+' "${@}"
        ;;
    disallow_node)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/node" '-' "${@}"
        ;;
    deny_node)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/node" '+' "${@}"
        ;;
    nodeny_node)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/node" '-' "${@}"
        ;;
    allow_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/tmpfile" '+' "${@}"
        ;;
    disallow_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/tmpfile" '-' "${@}"
        ;;
    deny_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/tmpfile" '+' "${@}"
        ;;
    nodeny_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/tmpfile" '-' "${@}"
        ;;
    allow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/exec" '+' "${@}"
        ;;
    disallow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "allow/exec" '-' "${@}"
        ;;
    deny_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/exec" '+' "${@}"
        ;;
    nodeny_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_3 "deny/exec" '-' "${@}"
        ;;
    allow_net)
        local c='allow/net/bind'
        case "${1}" in
        '--connect')
            c='allow/net/connect'
            shift;;
        '--send')
            c='allow/net/send'
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
        '--send')
            c='allow/net/send'
            shift;;
        esac
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_3 "${c}" '-' "${@}"
        ;;
    addfilter|addfilter_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/write" '+' "${@}"
        ;;
    rmfilter|rmfilter_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/write" '-' "${@}"
        ;;
    addfilter_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/read" '+' "${@}"
        ;;
    rmfilter_read)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/read" '-' "${@}"
        ;;
    addfilter_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/stat" '+' "${@}"
        ;;
    rmfilter_stat)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/stat" '-' "${@}"
        ;;
    addfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/exec" '+' "${@}"
        ;;
    rmfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/exec" '-' "${@}"
        ;;
    addfilter_net)
        local c='filter/net/bind'
        case "${1}" in
        '--connect')
            c='filter/net/connect'
            shift;;
        '--send')
            c='filter/net/send'
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
        '--send')
            c='filter/net/send'
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
        sydbox_internal_path_3 "exec/kill" "+" "${@}"
        ;;
    resume)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        ebuild_notice "warning" "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
        false;;
    hack_toolong|nohack_toolong)
        ebuild_notice "warning" "${FUNCNAME} ${cmd} is not implemented for sydbox-3"
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
        [[ -e "/dev/sydbox/core/trace/magic_lock:on" ]]
        ;;
    exec_lock)
        [[ -e "/dev/sydbox/core/trace/magic_lock:exec" ]]
        ;;
    wait_all)
        [[ -e "/dev/sydbox/core/trace/exit_wait_all:true" ]]
        ;;
    wait_eldest)
        [[ -e "/dev/sydbox/core/trace/exit_wait_all:false" ]]
        ;;
    enabled|enabled_path)
        [[ -e "/dev/sydbox/core/sandbox/write?" ]]
        ;;
    enable|enable_path)
        [[ -e "/dev/sydbox/core/sandbox/write:deny" ]]
        ;;
    disable|disable_path)
        [[ -e "/dev/sydbox/core/sandbox/write:off" ]]
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
    enabled_stat)
        false
        ;;
    enable_stat)
        : # no-op, only supported for syd[>=3]
        ;;
    disable_stat)
        : # no-op, only supported for syd[>=3]
        ;;
    enabled_write|enabled_create|enabled_delete|enabled_truncate|enabled_attr|enabled_chown|enabled_chgrp|enabled_iotl|enabled_node|enabled_tmpfile)
        [[ -e "/dev/sydbox/core/sandbox/write?" ]]
        ;;
    enable_write|enable_create|enable_delete|enable_truncate|enable_attr|enable_chown|enable_chgrp|enable_iotl|enable_node|enable_tmpfile)
        [[ -e "/dev/sydbox/core/sandbox/write:deny" ]]
        ;;
    disable_write|disable_create|disable_delete|disable_truncate|disable_attr|disable_chown|disable_chgrp|disable_iotl|disable_node|disable_tmpfile)
        [[ -e "/dev/sydbox/core/sandbox/write:off" ]]
        ;;
    enabled_exec)
        [[ -e "/dev/sydbox/core/sandbox/exec?" ]]
        ;;
    enable_exec)
        [[ -e "/dev/sydbox/core/sandbox/exec:deny" ]]
        ;;
    disable_exec)
        [[ -e "/dev/sydbox/core/sandbox/exec:off" ]]
        ;;
    enabled_net)
        [[ -e "/dev/sydbox/core/sandbox/network?" ]]
        ;;
    enable_net)
        [[ -e "/dev/sydbox/core/sandbox/network:deny" ]]
        ;;
    disable_net)
        [[ -e "/dev/sydbox/core/sandbox/network:off" ]]
        ;;
    allow|allow_path|allow_write|allow_create|allow_delete|allow_truncate|allow_attr|allow_chown|allow_chgrp|allow_ioctl|allow_node|allow_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "whitelist/write" '+' "${@}"
        ;;
    disallow|disallow_path|disallow_write|disallow_create|disallow_delete|disallow_truncate|disallow_attr|disallow_chown|disallow_chgrp|disallow_ioctl|disallow_node|disallow_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "whitelist/write" '-' "${@}"
        ;;
    deny_write|deny_create|deny_delete|deny_truncate|deny_attr|deny_chown|deny_chgrp|deny_ioctl|deny_node|deny_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    nodeny_write|nodeny_create|nodeny_delete|nodeny_truncate|nodeny_attr|nodeny_chown|nodeny_chgrp|nodeny_ioctl|nodeny_node|nodeny_tmpfile)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        : # no-op, only supported for syd[>=3]
        ;;
    nodeny_read)
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
    allow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "whitelist/exec" '+' "${@}"
        ;;
    disallow_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "whitelist/exec" '-' "${@}"
        ;;
    allow_net)
        local c="whitelist/network/bind"
        [[ "${1}" == "--connect" ]] && c="whitelist/network/connect" && shift
        [[ "${1}" == "--send" ]] && c="whitelist/network/connect" && shift
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 "${c}" '+' "${@}"
        ;;
    disallow_net)
        local c="whitelist/network/bind"
        [[ "${1}" == "--connect" ]] && c="whitelist/network/connect" && shift
        [[ "${1}" == "--send" ]] && c="whitelist/network/connect" && shift
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 "${c}" '-' "${@}"
        ;;
    addfilter|addfilter_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/write" '+' "${@}"
        ;;
    rmfilter|rmfilter_path)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/write" '-' "${@}"
        ;;
    addfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/exec" '+' "${@}"
        ;;
    rmfilter_exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "filter/exec" '-' "${@}"
        ;;
    addfilter_net)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 "filter/network" '+' "${@}"
        ;;
    rmfilter_net)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_net_1 "filter/network" '-' "${@}"
        ;;
    exec)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        [[ -e "$(sydfmt exec -- ${@})" ]]
        ;;
    kill)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "exec/kill_if_match" "+" "${@}"
        ;;
    resume)
        [[ ${#} < 1 ]] && die "${FUNCNAME} ${cmd} takes at least one extra argument"
        sydbox_internal_path_1 "exec/resume_if_match" "+" "${@}"
        ;;
    hack_toolong|nohack_toolong)
        ebuild_notice "warning" "${FUNCNAME} ${cmd} is not implemented for sydbox-1"
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
    ebuild_notice "warning" "${FUNCNAME} is deprecated, use \"esandbox check\" instead"
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
    ebuild_notice "warning" "${FUNCNAME} is deprecated, use \"esandbox allow\" instead"
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
    ebuild_notice "warning" "${FUNCNAME} is deprecated, use \"esandbox disallow\" instead"
    esandbox disallow "${1}"
}

rmpredict()
{
    die "${FUNCNAME} is dead, use \"esandbox rmfilter\" instead"
}

addfilter()
{
    ebuild_notice "warning" "${FUNCNAME} is deprecated, use \"esandbox addfilter\" instead"
    esandbox addfilter "${1}"
}

rmfilter()
{
    ebuild_notice "warning" "${FUNCNAME} is deprecated, use \"esandbox rmfilter\" instead"
    esandbox rmfilter "${1}"
}

