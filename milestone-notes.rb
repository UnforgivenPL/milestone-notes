#!/bin/ruby

# written by Miki Olsz / (c) 2020 Unforgiven.pl
# released under Apache 2.0 License

# parameters:
# 0 = version number (default: Next)
# 1 = owner/repo (default: mikiolsz/milestone-notes)
# 2 = comma-separated labels to look for (default: enhancement, bug)
# 3 = labels to exclude (default: invalid, wontfix)
# 4 = output filename (default: milestone-notes.md)
require 'github_api'

version = ARGV[0] || 'Next'
owner, repository = (ARGV[1] || 'mikiolsz/milestone-notes').split('/')

labels = Hash[(ARGV[2] || 'enhancement, bug').split(/\s*,\s*/).collect { |s| [s, []] }]
ignore = (ARGV[3] || 'invalid, wontfix').split(/\s*,\s*/)

filename = ARGV[4] || 'milestone-notes.md'

puts "milestone-notes for #{owner}/#{repository} - version #{version}"
puts "(accepted labels: #{labels.keys.join(', ')}; ignored: #{ignore.join(', ')}"

issues = Github::Client::Issues.new(user: owner, repo: repository)

if (milestone = issues.milestones.list(state: 'closed', auto_pagination: true)
                      .find { |m| m.title =~ Regexp.new("^#{version} ") })
  puts "fetching closed issues for milestone <#{milestone.title}>, please wait..."
  to_include = issues.list(milestone: milestone.number,
                           state: 'closed',
                           user: owner, repo: repository, auto_pagination: true)
                     .reject(&:pull_request)
                     .filter { |i| i.labels.any? { |l| labels.keys.include?(l.name) } }
                     .reject { |i| i.labels.any? { |l| ignore.include?(l.name) } }
                     .sort_by(&:number)
  puts "...found #{to_include.size} issues; generating markup"
  to_include.each do |i|
    i.labels.filter { |l| labels.keys.include?(l.name) }
     .each { |l| labels[l.name] << "* \\##{i.number} - [#{i.title}](#{i.url})" }
  end

  result = ["# #{milestone.title}"]
  labels.each { |label, lines| (result << "## #{label}").append lines }

  puts "...done; saving file [#{filename}]..."
  File.open(filename, 'w') { |file| file.write(result.join("\n")) }
  puts '...finished; all done - goodbye!'
else
  puts "no milestone found for version #{version}, nothing to do; goodbye"
end
