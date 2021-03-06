# Tenex Features

## General

- Reasonably quick operation in interactive use.
- No jumping content due to multiple renders.
- If a project uses Evergreen and Travis, results from both are shown
whenever results from one are shown and results from both systems are
presented in a similar fashion.

## Pull Request List

- Shows Evergreen & Travis build stats for each PR.
- Shows Github PR review approved/requested status.

![PR list](https://raw.githubusercontent.com/wiki/p-mongo/tenex/screenshots/pr-list.png) 

## Pull Request View

Tenex merges Evergreen and Travis CI statuses on a single page.
Travis statuses are expanded to job level.
Evergreen statuses are arranged in a matrix for supported projects
(Ruby driver).

Pull request view features:

### General CI Operations

- Bulk restart all failed CI builds.
- Restart individual CI builds (in any state).
- View CI logs for each build (task log for Evergreen, build log for Travis).
- Smart failure counting: top level Evergreen build is not included in
the number of the failing builds, and if Travis is ignored then Travis
failures also are not included in the number of failures. This makes the
number of failures shown accurate.
- Show individual failed examples based on the RSpec report, optionally
filtered only to MRI or JRuby configurations.

### Evergreen-Specific Operations

- Show detailed test suite execution results for each failed configuration
(specific failed tests, longest tests, etc.).
- Validate Evergreen configuration in the PR's branch. This uses a
local validator that produces accurate line numbers for errors and much
easier to understand and act on error messages, as well as the
Evergreen command line tool validator (which sends the configuration to
the Evergreen server, and should thus always produce the same set of errors
as the Evergreen server would).
- One-click restart of failed or all builds.
- One-click bump of task priority to predefined levels which also
activates/schedules the task.
- One-click bulk bump of task priorities for all pending builds in a PR.
- Authorize Evergreen's build for externally submitted PRs.
- Show individual server logs from the build with log level colorization.
- Submit the PR's diff to Evergreen as a patch build. Useful when Evergreen
is not processing pull requests or when the PR is to a non-master branch,
which Evergreen generally does not build.
- Ability to partially retrieve huge logs from Evergreen

### Git/Github Operations

- One-click jump to PR diff.
- Request PR review using the configured set of reviewers, bypassing Github's
reviewer selection UI.
- One-click PR approval.
- Rebase PR's branch on top of master.
- Reword PR's branch - squash all commits in the branch into a single commit
and replace commit messsages with the respective ticket title.
Ticket is automatically detected/inferred from branch name, PR
description and PR comments.
- Replace title and description of the PR with that of the head commit.
- Replace title of the PR with the title of the respective Jira ticket.
- One-click edit title and description of the PR.
- One-click edit of the commit message of the most recent commit in the PR's
branch, with the option to reset PR title and description to those derived from
the new commit message.

### Performance Information

- Time taken for each configuration to run.
- Builds ordered from slowest to fastest.
- Slowest 20 RSpec examples for each build.

![PR](https://raw.githubusercontent.com/wiki/p-mongo/tenex/screenshots/pr.png) 

## Evergreen Patch Status

Adds a link to jump to the patch status page for the newest version
of the branch being shown.

Adds ability to bulk bump task priorities for unfinished tasks in
a version, individually or in bulk for all unfinished tasks.

![PR](https://raw.githubusercontent.com/wiki/p-mongo/tenex/screenshots/version.png) 

![PR](https://raw.githubusercontent.com/wiki/p-mongo/tenex/screenshots/version-2.png) 

## Evergreen Log

Reinstates normal horizontal scrollbar in task logs.

Adds a quick jump to first RSpec failure.

## Travis Log

Full build log with color.

## Test Suite Result Reporting

Tenex parses RSpec results produced by the test suites and displays the
following information:

- Failure count per build
- Failed examples with stack traces
- 20 slowest examples per build
- SDAM logging output for failed and slow examples

Additionally, Tenex can aggregate RSpec results across all builds for a
given PR or Evergreen version, and display summary information. The summaries
are computed separately for MRI and JRuby builds. The following summary
information is displayed:

- Failure count per PR/version
- Failed examples with stack traces and SDAM logging output

## Toolchain Tarball Retrieval

Allows quickly getting URLs of built toolchain tarballs for:

- The most recent master commit of the toolchain:

![Toolchain URLs](https://raw.githubusercontent.com/wiki/p-mongo/tenex/screenshots/toolchain-urls.png) 

- Any toolchain build

## Evergreen Configuration Validation

Tenex provides its own validator of Evergreen configuration files, which
offers accurate, informative and actionable error reporting. Specifically:

- When parsing files, parse errors are reported with correct line numbers.
- Validation errors informatively describe the issue and what it affects.

Tenex can also run Evergreen binary's validator on the configuration file.

## Evergreen Spawn Hosts

Adds a list of recently spawned distros for quickly spawning more of
the same distros.

Adds a link to terminate all running spawned hosts.

Adds an SSH command copy-pastable to the terminal to connect to each
spawned host.

![Spawn page](https://raw.githubusercontent.com/wiki/p-mongo/tenex/screenshots/spawn.png) 

## Non-Project-Specific Evergreen Operations

- Get a list of all known distros based on currently running hosts.
Evergreen generally does not prevent configurations from referencing
nonexistent distros; such configurations end up sitting in the queue
indefinitely. This feature is intended to provide a list of valid distros.

## Jira operations

- More intelligent smart querying
  - Text is matched in summary in addition to description
- Recent smart query list
- View tickets in a version, export list to Markdown for changelog drafting
- Exclude ticket from being in changelog

## Paste

Tenex offers a non-intrusive frontend to Gist allowing quick pasting of
blobs.
