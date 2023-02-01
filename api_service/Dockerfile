FROM ruby:3.1.3

ENV API /api_service
RUN mkdir $API
WORKDIR $API
COPY Gemfile* $API/
RUN bundle install

ADD . $API
EXPOSE 4567

CMD [ "ruby", "main.rb" ]
