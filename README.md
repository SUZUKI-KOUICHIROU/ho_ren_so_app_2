# README

## 🌟 リポジトリの所有者が行うこと

1. このリポジトリをコピーして別のリポジトリを作成する方法
   1. https://github.com/shotaimai66/readme-develop/blob/main/%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC%E6%96%B9%E6%B3%95.md
2. main ブランチの保護設定とレビュー必須設定方法
   1. https://github.com/shotaimai66/readme-develop/blob/main/%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E3%81%AE%E4%BF%9D%E8%AD%B7%E8%A8%AD%E5%AE%9A%E3%81%A8%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC%E5%BF%85%E9%A0%88%E8%A8%AD%E5%AE%9A.md
3. 開発メンバーのリポジトリへの招待
   1. 開発メンバーをリポジトリにコラボレーターとして招待する。招待の仕方についてはググってください。
4. 開発メンバーに以降の readme を参考に環境構築をしてもらう
5. main ブランチから作業ブランチを切ってもらい開発を進める。

---

## 🌟 招待されたメンバーが行うこと

1. リポジトリの git clone でローカルにソースをクローンする
2. 以降の記事を参考に環境構築を行う。
3. main ブランチから作業ブランチを切って開発を進める。

---

## 環境構築

1. まずは docker の導入
   - https://github.com/shotaimai66/readme-develop/blob/main/Docker%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB.md
2. docker の導入ができたら、以下のコマンドを打ち込んでいく。(アプリのディレクトリ内に cd コマンドで移動してから)

```
# イメージのビルド
docker-compose build

# bundle intall
docker
```