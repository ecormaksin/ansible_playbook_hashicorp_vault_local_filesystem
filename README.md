# 概要

[Ansible](https://www.ansible.com/)でCentOS7のローカルに [HashiCorp Vault](https://www.vaultproject.io/)をインストールするためのPlaybookです。

実行後はValutがサービスとして開始された状態になります。

再起動後も`vault`サービスが自動起動します。

想定構成は、サーバー1台でのVaultのServerとClientです。
Vault のデータは[ファイルシステム](https://www.vaultproject.io/docs/configuration/storage/filesystem)で保持します。

`vault operate init 〜`の初期処理については、各環境の要件に応じた適切なオプションで実行ください。

https://learn.hashicorp.com/vault/getting-started/deploy#initializing-the-vault
https://www.vaultproject.io/docs/commands/operator/init


# 注意事項

**このPlaybookを使ってVaultをセットアップすると、シェルの実行履歴に`valut`コマンドに関するものが残らなくなります。**

`vault kv put〜`でパスワードなどの資格情報をシェルから直接指定した時にシェルの実行履歴に残ってしまい、セキュリティ上の問題があるためです。

https://learn.hashicorp.com/vault/secrets-management/sm-static-secrets#additional-discussion

対応しているシェルはBash, Fish, ZSHです。

https://learn.hashicorp.com/vault/getting-started/advanced-shell-configuration#command-completion

# OSやHashiCorp Vaultのバージョン

## OS

```shell
$ cat /usr/lib/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```

## Ansible

```shell
$ ansible --version
ansible 2.9.9
  config file = /home/vagrant/.ansible.cfg
  configured module search path = [u'/home/vagrant/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Apr  2 2020, 13:16:51) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
```

## Vault

```shell
$ vault --version
Vault v1.4.2
```

# 使い方

## 1. Ansibleのインストール

当プロジェクト フォルダ内の`./install_ansible.sh`を実行します。

## 2. Ansible Playbookの実行

当プロジェクト フォルダ内の`./run_playbook.sh`を実行します。

### （参考）Ansible Playbook実行時のコマンド オプション

```
# シンタックス チェック
ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 site.yml -vv --syntax-check

# ドライ ラン
ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 site.yml -vv --check

# 実行
ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 site.yml -vv 

# 途中から実行
ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 site.yml -vv  --start-at="<途中から開始したいタスク名>"
```

### （参考）リセット用

**書き込んだ資格情報がなくなってしまうので、実行には十分ご注意ください。**

Vaultのインストール・セットアップをやり直したい場合に、以下のコマンドを管理者権限で実行します。

- サービスを停止・無効化
- systemdサービス用ファイルを削除
- 設定用・データ用ディレクトリを削除
- `vault`のグループ・ユーザーを削除
- Vaultの実行ファイル本体を削除

```shell
systemctl stop vault
systemctl disable vault
rm -f /etc/systemd/system/vault.service

rm -fr /etc/vault.d
rm -fr /var/vault/data

userdel -r vault
groupdel vault

rm -f /usr/local/bin/vault
```

シェルの設定ファイルに書き込まれた`complete -C /usr/local/bin/vault vault`と`export HISTIGNORE="&:vault*"`の削除は行っていないので、個別に削除や環境変数のクリアを行ってください。
