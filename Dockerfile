FROM ruby:2.6

COPY Gemfile Gemfile.lock milestone-notes.rb ./
RUN chmod +x /milestone-notes.rb
RUN bundle install

ENTRYPOINT ["/milestone-notes.rb"]
