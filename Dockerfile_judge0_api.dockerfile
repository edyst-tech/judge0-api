FROM edyst/judge0-api-base:latest

RUN sed -i -e 's|disco|eoan|g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
    libpq-dev \
    nodejs \
    npm \
    sudo

#ENV PATH "/usr/local/ruby-2.3.3/bin:/opt/.gem/bin:$PATH"
#ENV GEM_HOME "/opt/.gem/"
RUN echo "gem: --no-document" > /root/.gemrc && \
    gem install \
    bundler \
    pg && \
    /usr/bin/npm install -g npm@latest && \
    sudo /usr/local/bin/npm install -g aglio --unsafe-perm=true --allow-root

EXPOSE 3000

WORKDIR /usr/src/api
COPY Gemfile /usr/src/api
RUN RAILS_ENV=production bundle

COPY . /usr/src/api
RUN RAILS_ENV=production bundle && \
    ./scripts/prod-gen-api-docs

CMD rm -f tmp/pids/server.pid && \
    rails db:create db:migrate db:seed && \
    rails s -b 0.0.0.0

# Install python dependencies
RUN pip3 install -r python_requirements.txt

LABEL maintainer="Abhinandan Panigrahi, abhi@edyst.com" \
    version="1.0.0"
