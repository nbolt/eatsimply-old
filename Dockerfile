FROM nepalez/ruby
RUN apt-get update -qq && apt-get install -y build-essential git nodejs libpq-dev libmagickwand-dev
RUN mkdir /eatt
WORKDIR /eatt
ADD . /eatt
RUN bundle install

ENV SECRET_KEY_BASE bed6b4c10bb0ad22841575d2260e7c8179a8542767176bd599d604ff85f09e217833841025a5ead6f1f9e7947fddaed94a446f05d20b73d425402c36bac656d8