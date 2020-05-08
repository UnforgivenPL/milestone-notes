## milestone-notes

Simple GitHub action for creating release notes.

## Requirements and overall philosophy

This action relies on *issues* and *milestones*. It fetches closed, labelled issues associated with a given milestone that are **not** pull requests, and then produces a neat `.md` file.

The resulting file gets created, but it is up to the next action to do something with it.

It is recommended to parse the file to provide meaningful headers, instead of `## label_name`. It can be done with `sed`.

This action uses Docker, Ruby 2.6 and [GitHub API gem](https://github.com/piotrmurach/github).

### Usage

#### Using milestone number

```
        uses: UnforgivenPL/milestone-notes@v1
        with:
          milestone-number: 1
          repository: ${{ github.repository }}
```

Replace `1` with whatever is the number of the milestone you want to generate milestone notes for.

#### Matching milestone title 

```
        uses: UnforgivenPL/milestone-notes@v1
        with:
          match-milestone: "your-pattern-here"
          repository: ${{ github.repository }}
```

First matching milestone will be used.

### Why labels? What labels?

Only issues that are labelled are included in the final milestone notes. You are labelling your issues, aren't you?

By default issues labelled with `enhancement` and `bug` are included, but only if they do not contain `wontfix` or `invalid` label. These are the defaults, you can override them.

### Why milestones?

Just because these are a logical grouping point for issues. In the world of continuous deployment this may be a little old-fashioned, but I personally prefer this approach.

### What is the format of the output file?

It is a markdown file, structured like this:

```
# milestone.title
## label_1
* #XY [issue.title](issue.url)
...
## label_2
* #AB [issue.title](issue.url)
...
```

It is possible for one issue to be included in many sections - one for each label.

### Can I contribute?

Sure. Feel free to submit issues, make PRs or star this repository. Thank you :)

### I think this sucks.

Too bad. Feel free to submit an issue about how I can make it better. Be verbose. Thank you :)

## Inputs

### `milestone-number`

Milestone number. **Either this or `match-milestone` must be provided.** Has precedence if both are.

### `match-milestone`

Regular expression to match milestone title. **Either this or `milestone-number` must be provided.**

### `repository`

**Required** - `username/repository` to get milestone and issues for. The repository **must** be public, as the API call does not do any authentication or authorisation.

### `labels`

Comma-separated labels of issues to include in the milestone notes. Defaults to `enhancement, bug`.

### `ignore`

Comma-separated labels of issues to exclude from the milestone notes. Defaults to `invalid, wontfix`.

### `filename`

Name of the file to write milestone notes to. Defaults to `milestone-notes.md`.

## Outputs

This action creates a file, specified by `inputs.filename` (default `milestone-notes.md`).

## About

This action is released under Apache 2.0 License. It has been written by Miki Olsz from [Unforgiven.pl](https://www.unforgiven.pl).
