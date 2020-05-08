FROM ruby:2.6

COPY Gemfile Gemfile.lock milestone-notes.sh milestone-notes.rb ./
RUN chmod +x milestone-notes.sh
RUN bundle install

ENTRYPOINT ["milestone-notes.sh"]
