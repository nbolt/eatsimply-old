FROM nepalez/ruby
RUN apt-get update -qq && apt-get install -y build-essential git nodejs libpq-dev libmagickwand-dev
RUN mkdir /eatt
WORKDIR /eatt
ADD . /eatt
RUN cp config/database.yml.example config/database.yml
RUN bundle install

ENV RAILS_ENV production
ENV YUM_API_ID af94c6f0
ENV YUM_API_KEY 3a317c635b88342faedd44473b486955
ENV NUTRI_API_ID 6b39bc51
ENV NUTRI_API_KEY 1e40b2f38742739ad3ef7b6a9a27e2b1
ENV PUSHER_SECRET 961ce7571d73c1c80571
ENV PUSHER_KEY 37bdb1b5ae481d8711f2
ENV FILEPICKER_KEY A4bM4KcPTRp2VRySoMraxz
ENV SECRET_KEY_BASE bed6b4c10bb0ad22841575d2260e7c8179a8542767176bd599d604ff85f09e217833841025a5ead6f1f9e7947fddaed94a446f05d20b73d425402c36bac656d8
