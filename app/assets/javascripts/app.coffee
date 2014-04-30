AppCtrl = ($http) ->


HomeCtrl = ($http) ->



app = angular.module('eatt', ['ngCookies'])#, 'ui.select2', 'ui.date', 'ui.mask'])
  .controller('app',      AppCtrl)
  .controller('home',     HomeCtrl)
  .config [$httpProvider], ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr 'content'


angular.element(document).on 'ready page:load', -> angular.bootstrap('body', ['eatt'])