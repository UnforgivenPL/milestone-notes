FROM ruby:2.6

COPY Gemfile Gemfile.lock milestone-notes.sh milestone-notes.rb ./
RUN bundle install
RUN chmod +x /milestone-notes.sh

ENTRYPOINT ["/milestone-notes.sh"]