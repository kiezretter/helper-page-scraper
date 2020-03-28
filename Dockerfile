FROM ruby:2.6.5

RUN gem install --no-document bundler

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

COPY . ./

CMD ["ruby", "/usr/src/app/scraper.rb"]
