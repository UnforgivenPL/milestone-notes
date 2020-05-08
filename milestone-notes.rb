# written by Miki Olsz / (c) 2020 Unforgiven.pl
# released under Apache 2.0 License

require 'github_api'

unless ARGV[0]
  puts <<HELP
no parameters provided, which is probably NOT what was intended
this script supports the following parameters 
  0 = milestone number                   (default: -, but either this or regexp must be non-default)
  1 = regexp for matching version        (default: -, but either this or milestone number must be non-default)
  2 = owner/public repo                  (default: UnforgivenPL/milestone-notes)
  3 = comma-separated labels to look for (default: enhancement, bug)
  4 = labels to exclude                  (default: invalid, wontfix)
  5 = output filename                    (default: milestone-notes.md)
HELP
end

milestone_number = ARGV[0] || '-'
regexp = ARGV[1] || '-'

puts('either milestone number or regexp MUST be defined') || exit(1) if milestone_number == '-' && regexp == '-'
regexp = Regexp.new(regexp)

owner, repository = (ARGV[2] || 'UnforgivenPL/milestone-notes').split('/')

labels = Hash[(ARGV[3] || 'enhancement, bug').split(/\s*,\s*/).collect { |s| [s, []] }]
ignore = (ARGV[4] || 'invalid, wontfix').split(/\s*,\s*/)

filename = ARGV[5] || 'milestone-notes.md'

issues = Github::Client::Issues.new

puts "milestone-notes for #{owner}/#{repository}"
puts "(accepted labels: #{labels.keys.join(', ')}; ignored: #{ignore.join(', ')})"
milestone = if milestone_number != '-'
                 puts "(using milestone number #{milestone_number})"
                 begin
                   issues.milestones.get(user: owner, repo: repository, number: milestone_number)
                 rescue
                   nil
                 end
            else
                 puts "using milestone matching #{regexp}"
                 issues.milestones
                       .list(state: 'all', auto_pagination: true, user: owner, repo: repository)
                       .find { |m| regexp.match?(m.title) }
            end

if milestone
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
  puts "no milestone found matching #{regexp} or number #{milestone_number}"
  puts "nothing to do; goodbye!"
end
