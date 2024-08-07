#!/usr/bin/env bash
#' TODO: bash -> sh for portability
#' Gets the x86-64 Microarchitecture Level on the Current Machine
#'
#' Queries the CPU information to infer which level of x86-64
#' microarchitecture is supported by the CPU on the current machine,
#' i.e. x86-64-v1, x86-64-v2, x86-64-v3, or x86-64-v4.
#'
#' Usage:
#' x86-64-version
#'
#' Options:
#'   --help     Show this help
#'   --version  Show the version of this tool
#'   --verbose  Explain the identified level
#'
#' Examples:
#' $ x86-64-level
#' 3
#'
#' $ level=$(x86-64-level)
#' $ echo "x86-64-v${level}"
#' x86-64-v3
#'
#' $ x86-64-level --verbose
#' Identified x86-64-v3, because x86-64-v4 requires 'avx512f', which
#' this CPU [Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz] does not support
#' 3
#'
#' Authors:
#' * Henrik Bengtsson (expanded on Gilles implementation [2])
#' * StackExchange user 'Gilles'
#'   <https://stackexchange.com/users/164368/>
#' * StackExchange user 'gioele'
#'   <https://unix.stackexchange.com/users/14861/>
#'
#' References:
#' [1] https://www.wikipedia.org/wiki/X86-64#Microarchitecture_levels
#' [2] https://unix.stackexchange.com/a/631320
#'
#' Version: 0.1.0
#' Original Source: https://github.com/ucsf-wynton/wynton-tools
#' Further modifications:
#' https://github.com/mikeshardmind'

#---------------------------------------------------------------------
# CLI functions
#---------------------------------------------------------------------
help() {
    grep "^#'" "$0" | sed -E "s/^#' ?//"
}

version() {
    grep "^#' Version:" "$0" | sed 's/.* //'
}


#---------------------------------------------------------------------
# CPU functions
#---------------------------------------------------------------------
get_cpu_name() {
    local name
    name=$(grep -E "^model name[[:space:]]*:" /proc/cpuinfo | head -1)
    name="${name#model name*:}"
    echo "${name## }"
}

get_cpu_flags() {
    local flags
    flags=$(grep "^flags[[:space:]]*:" < /proc/cpuinfo | head -n 1)
    ## Note, it's important to keep a trailing space
    echo "${flags#*:} "
}


has_cpu_flags() {
    local flag
    for flag; do
        case "$flags" in
            *" $flag "*)
                :
                ;;
            *)
                if "$verbose"; then
                               echo >&2 "Identified x86-64-v${level}, because x86-64-v$((level + 1)) requires '$flag', which this CPU [$(get_cpu_name)] does not support"
                fi
                return 1
                ;;
        esac
    done
}


determine_cpu_version() {
    ## x86-64
    level=0
    has_cpu_flags lm cmov cx8 fpu fxsr mmx syscall sse2 || return 0

    ## x86-64-v1
    level=1
    has_cpu_flags cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3 || return 0

    ## x86-64-v2
    level=2
    has_cpu_flags avx avx2 bmi1 bmi2 f16c fma abm movbe xsave || return 0

    ## x86-64-v3
    level=3

    ## x86-64-v4
    has_cpu_flags avx512f avx512bw avx512cd avx512dq avx512vl || return 0
    level=4
}


report_cpu_version() {
    flags=$(get_cpu_flags)
    level=0
    determine_cpu_version
    echo "$level"
}


#---------------------------------------------------------------------
# MAIN
#---------------------------------------------------------------------
verbose=false

# Parse command-line options
while [[ $# -gt 0 ]]; do
    ## Options (--flags):
    if [[ "$1" == "--help" ]]; then
        help
        exit 0
    elif [[ "$1" == "--version" ]]; then
        version
        exit 0
    elif [[ "$1" == "--verbose" ]]; then
        verbose=true
    else
        echo >&2 "ERROR: Unknown option: $1"
        exit 2
    fi
    shift
done


report_cpu_version