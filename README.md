# README
## 🌟リポジトリの所有者が行うこと
1. このリポジトリをコピーして別のリポジトリを作成する方法
   1.  https://github.com/shotaimai66/readme-develop/blob/main/%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC%E6%96%B9%E6%B3%95.md
2. mainブランチの保護設定とレビュー必須設定方法
   1. https://github.com/shotaimai66/readme-develop/blob/main/%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E3%81%AE%E4%BF%9D%E8%AD%B7%E8%A8%AD%E5%AE%9A%E3%81%A8%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC%E5%BF%85%E9%A0%88%E8%A8%AD%E5%AE%9A.md
3. 開発メンバーのリポジトリへの招待
   1. 開発メンバーをリポジトリにコラボレーターとして招待する。招待の仕方についてはググってください。
4. 開発メンバーに以降のreadmeを参考に環境構築をしてもらう
5. mainブランチから作業ブランチを切ってもらい開発を進める。

---

## 🌟招待されたメンバーが行うこと
1. リポジトリのgit cloneでローカルにソースをクローンする
2. 以降の記事を参考に環境構築を行う。
3. mainブランチから作業ブランチを切って開発を進める。

---

## 環境構築
1. まずはdockerの導入
    - https://github.com/shotaimai66/readme-develop/blob/main/Docker%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB.md
2. dockerの導入ができたら、以下のコマンドを打ち込んでいく。(アプリのディレクトリ内にcdコマンドで移動してから)

```
# イメージのビルド
docker-compose build

# bundle intall
docker-compose run --rm app bundle install

# yarn install
docker-compose run --rm app yarn install

# Vueコンポーネントのビルド
docker-compose run --rm app bin/webpack

# db:setup
docker-compose run --rm app bin/rails db:setup

# railsサーバー起動(ローカルPC用)
docker-compose up

# railsサーバー起動(cloud9の方)
bin/dev 8080
```

---

## 開発コマンド
```

# コンテナ起動
docker-compose up

# コンテナ起動(バックグラウンド起動):byebugを使うときに実行
docker-compose up -d

# コンテナのlogを出力(byebugの操作を行う)
docker attach ho_ren_so_app

# コンテナ停止
docker-compose down

　　# 挙動がおかしくなった時、一度docker-composeコマンドで作成したリソースを削除するコマンド
　　docker-compose down --rmi all --volumes --remove-orphans

# bundle install
docker-compose run --rm app bundle install

# rails db:create
docker-compose run --rm app bin/rails db:create

# rails db:migrate
docker-compose run --rm app bin/rails db:migrate

# rails db:seed
docker-compose run --rm app bin/rails db:seed

# rails db:seed_fu
docker-compose run --rm app bin/rails db:seed_fu

　　# その他のrails系コマンド（rails generate や rails routes など）にも共通する点
　　docker-compose run --rm app bin/
　　↑このDockerコマンドをrails系コマンドの「前」に加えて実行して下さい。↑

```

---

## ※※※※※※※PR上げる前に確認してください※※※※※※※
- rspecと構文チェックとERDの生成
  - rspecが通っているか？
  - 構文チェックでエラーが出ていないか？

テストで全てのチェックに合格すると以下のように表示されます。チェックに合格しない場合は自分で解決するか、メンバーに相談しながら解決してください。チェックに全て合格してPRを初めて上げることができます。
```
  ・・・・・・・・・・・・・・・・・・
```

---

## テストコマンド(gem 'rspec')
```
# rspec(全部実行)
docker-compose run --rm app bundle exec rspec

# rspec(個別実行):例 spec/models/article_spec.rbの17行目
docker-compose run --rm app bundle exec rspec spec/models/article_spec.rb:17
```

---

## 構文チェックコマンド(gem 'rubocop')
```
# rubocop
docker-compose run --rm app bundle exec rubocop

# rubocop(自動整形)
docker-compose run --rm app bundle exec rubocop -a
```


## その他開発用readme（こちらも必ず確認ください！！）
- https://github.com/shotaimai66/readme-develop
