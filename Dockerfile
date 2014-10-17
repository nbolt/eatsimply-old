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
ENV FIREBASE_URL https://scorching-heat-4297.firebaseio.com
ENV FIREBASE_SECRET n5TtnxB9XJfTam7RIOiMvZO0YHBdc3GHOPmC7FBG
ENV FILEPICKER_KEY A4bM4KcPTRp2VRySoMraxz
ENV SEGMENT_KEY kh5x5t8aqo
ENV MAILCHIMP_API 3af7f4ec0760eee07e054910d8f1d452-us9
ENV SECRET_KEY_BASE bed6b4c10bb0ad22841575d2260e7c8179a8542767176bd599d604ff85f09e217833841025a5ead6f1f9e7947fddaed94a446f05d20b73d425402c36bac656d8
