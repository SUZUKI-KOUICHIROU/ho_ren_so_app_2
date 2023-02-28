FROM ruby:2.6.3

# Node.js、postgresql-client をインストール
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client\
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ルート直下にwebappという名前で作業ディレクトリを作成（コンテナ内のアプリケーションディレクトリ）
RUN mkdir /ho_ren_so_app
WORKDIR /ho_ren_so_app

# ホストのGemfileとGemfile.lockをコンテナにコピー
ADD Gemfile /webapp/Gemfile
ADD Gemfile.lock /webapp/Gemfile.lock

# bundle installの実行
RUN gem install bundler
RUN bundle install -j4

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
ADD . /ho_ren_so_app

EXPOSE 3000

CMD bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"