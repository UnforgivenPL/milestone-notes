# written by Miki Olsz / (c) 2020 Unforgiven.pl
# released under Apache 2.0 License

require 'github_api'

unless ARGV[0]
  puts <<HELP
no parameters provided, which is probably NOT what was intended
this script supports the following parameters 
  0 = version number                     (default: Next)
  1 = owner/public repo                  (default: UnforgivenPL/milestone-notes)
  2 = regexp for matching version        (default: "^version-number "; use - to enforce default)
  3 = comma-separated labels to look for (default: enhancement, bug)
  4 = labels to exclude                  (default: invalid, wontfix)
  5 = output filename                    (default: milestone-notes.md)
HELP
end

version = ARGV[0] || 'Next'
owner, repository = (ARGV[1] || 'UnforgivenPL/milestone-notes').split('/')

regexp = Regexp.new(ARGV[2].nil? || ARGV[2]=='-' ? "^#{version} " : ARGV[2])

labels = Hash[(ARGV[3] || 'enhancement, bug').split(/\s*,\s*/).collect { |s| [s, []] }]
ignore = (ARGV[4] || 'invalid, wontfix').split(/\s*,\s*/)

filename = ARGV[5] || 'milestone-notes.md'

puts "milestone-notes for #{owner}/#{repository} - version #{version}"
puts "(accepted labels: #{labels.keys.join(', ')}; ignored: #{ignore.join(', ')})"

issues = Github::Client::Issues.new(user: owner, repo: repository)

if (milestone = issues.milestones.list(state: 'all', auto_pagination: true)
                      .find { |m| regexp.match?(m.title) })
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
  puts '...finished;'
  puts 'all done; goodbye!'
else
  puts "no milestone matching #{regexp} found for version [#{version}], nothing to do; goodbye"
end
