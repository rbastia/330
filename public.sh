#!/bin/bash

VER_REGEX="[0-9]+\.[0-9]+"

# https://stackoverflow.com/a/4025065/13159286
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

function test_versions () {
    pkgs=('ocaml' 'opam' 'rustc')
    vers=("5.2" "2.2" "1.84")

    for i in "${!pkgs[@]}"; do
        pkg="${pkgs[$i]}"
        ver="${vers[$i]}"

        if ! real_ver=$(eval "$pkg --version" | grep -Eo "$VER_REGEX"); then
            echo "$pkg not installed / could not parse version"
            exit 1
        fi

        vercomp "$real_ver" "$ver"
        if [[ $? -eq 2 ]]; then
            echo "$pkg version not high enough"
            exit 1
        fi

        echo "$pkg=$real_ver" >> p0.report
    done
}

function test_opam () {
    pkgs=('ounit' 'dune' 'utop' 'qcheck')

    for pkg in "${pkgs[@]}"; do
        if ! real_ver=$(opam info "$pkg" --field version); then
            echo "$pkg not installed / could not parse version"
            exit 1
        fi

        echo "$pkg=$real_ver" >> p0.report
    done
}

function test_misc () {
    pkgs=('graphviz')
    cmds=('dot -V')

    for i in "${!cmds[@]}"; do
        pkg="${pkgs[$i]}"
        cmd="${cmds[$i]}"

        if ! real_ver=$($cmd 2>&1 | grep -Eo "$VER_REGEX" | head -1); then
            echo "$pkg not installed / could not parse version"
            exit 1
        fi

        echo "$pkg=$real_ver" >> p0.report
    done
}

rm p0.report 2> /dev/null
test_versions 
test_opam 
test_misc
