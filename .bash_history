docker-compose -f docker-compose.dev.yml exec zammad bash
forego version
exit
rails db:seed
rails db:setup
exit
rails db:seed
rails db:setup
bundle exec rails db:seed
exit
ls /opt/zammad/db/seeds/locale/
ls /opt/zammad/db/locale/
ls /opt/zammad/locale/
clear
mv /opt/zammad/locale/*.po /tmp/
ls /opt/zammad/db/seeds/locale/
ls /opt/zammad/db/locale/
ls /opt/zammad/locale/
ls /opt/zammad/tmp/
ls /opt/zammad/
clear
ls /opt/zammad/i18n/
ls /opt/zammad/i18n/*.po
mv /opt/zammad/i18n/*.po /tmp/
bundle exec rails db:seed
exit
bundle exec rails db:migrate
