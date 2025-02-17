#!/bin/bash
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup
        rlRun "pushd data"
    rlPhaseEnd

    rlPhaseStartTest "Explore Plans"
        rlRun -s "tmt plan"
        rlAssertNotGrep "warn" $rlRun_LOG
        rlAssertGrep "Found 5 plans" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Show Plans (deep)"
        rlRun -s "tmt plan show"
        rlAssertGrep "/plans/minimal" $rlRun_LOG
        rlAssertNotGrep "summary Just url and name" $rlRun_LOG
        rlAssertGrep "summary Metadata used by tmt itself are valid" $rlRun_LOG
        rlAssertNotGrep "import" $rlRun_LOG
        rlAssertNotGrep "ref 1.16.0" $rlRun_LOG
        rlAssertNotGrep "warn" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Show Plans (shallow)"
        rlRun -s "tmt plan show --shallow"
        rlAssertGrep "/plans/minimal" $rlRun_LOG
        rlAssertGrep "summary Just url and name" $rlRun_LOG
        rlAssertNotGrep "summary Metadata used by tmt itself are valid" $rlRun_LOG
        rlAssertNotGrep "import" $rlRun_LOG
        rlAssertNotGrep "ref 1.16.0" $rlRun_LOG
        rlAssertNotGrep "warn" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Show Plans (verbose, deep)"
        rlRun -s "tmt plan show --verbose"
        rlAssertGrep "/plans/minimal" $rlRun_LOG
        rlAssertNotGrep "summary Just url and name" $rlRun_LOG
        rlAssertGrep "summary Metadata used by tmt itself are valid" $rlRun_LOG
        rlAssertGrep "import" $rlRun_LOG
        rlAssertGrep "url https://github.com/teemtee/tmt" $rlRun_LOG
        rlAssertGrep "path /tests/run/worktree/data/prepare" $rlRun_LOG
        rlAssertGrep "name /plan" $rlRun_LOG
        rlAssertGrep "ref 1.16.0" $rlRun_LOG
        rlAssertNotGrep "warn" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Show Plans (verbose, shallow)"
        rlRun -s "tmt plan show --verbose --shallow"
        rlAssertGrep "/plans/minimal" $rlRun_LOG
        rlAssertGrep "summary Just url and name" $rlRun_LOG
        rlAssertNotGrep "summary Metadata used by tmt itself are valid" $rlRun_LOG
        rlAssertGrep "import" $rlRun_LOG
        rlAssertGrep "url https://github.com/teemtee/tmt" $rlRun_LOG
        rlAssertGrep "path /tests/run/worktree/data/prepare" $rlRun_LOG
        rlAssertGrep "name /plan" $rlRun_LOG
        rlAssertGrep "ref 1.16.0" $rlRun_LOG
        rlAssertNotGrep "warn" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Discover Tests"
        # Exclude /plans/dynamic-ref as dynamic ref cannot be evaluated in dry mode
        rlRun -s "tmt run discover -v plan -n '/plans/[^d]'"
        rlAssertGrep "/plans/full" $rlRun_LOG
        rlAssertGrep "/tests/basic/ls" $rlRun_LOG
        rlAssertGrep "/tests/basic/show" $rlRun_LOG
        rlAssertGrep "/plans/minimal" $rlRun_LOG
        rlAssertGrep "/lint/tests" $rlRun_LOG
        rlAssertGrep "/lint/plans" $rlRun_LOG
        rlAssertNotGrep "/plans/default" $rlRun_LOG
        # logging import plan details in verbose mode
        rlAssertGrep "import url: https://github.com/teemtee/tmt" $rlRun_LOG
        rlAssertGrep "import ref: 1.16.0" $rlRun_LOG
        rlAssertGrep "import path: /tests/run/worktree/data/prepare" $rlRun_LOG
        rlAssertGrep "import name: /plan" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Discover dynamic-ref plan in detail"
        rlRun -s "tmt -c branch=fedora run -dddvvv discover plan -n dynamic-ref"
        rlAssertGrep "Dynamic 'ref' definition file.*detected" $rlRun_LOG -E
        rlAssertGrep "Run command: git checkout fedora" $rlRun_LOG
        rlAssertGrep "Found 1 plan" $rlRun_LOG
        rlAssertGrep "import url: https://github.com/teemtee/tmt" $rlRun_LOG
        rlAssertGrep "import ref: fedora" $rlRun_LOG
        rlAssertGrep "import path: /tests/discover/data" $rlRun_LOG
        rlAssertGrep "import name: /plans/smoke" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Run Tests"
        # Exclude /plans/dynamic-ref as dynamic ref cannot be evaluated in dry mode
        rlRun -s "tmt run --verbose --dry plan -n '/plans/[^d]'" 0 "Run tests (dry mode)"
        rlRun -s "tmt run --verbose" 0 "Run tests"
        rlAssertGrep "pass /tests/basic/ls" $rlRun_LOG
        rlAssertGrep "pass /lint/tests" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
    rlPhaseEnd
rlJournalEnd
