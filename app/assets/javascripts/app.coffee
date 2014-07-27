AppCtrl = ($http) ->


HomeCtrl = ($http) ->


RecipeEntry = ($scope, $http, $timeout) ->

  $scope.showRecipe = -> $scope.info && $scope.info.name

  $scope.profileHash = (ingredient) ->
    $scope.$watch 'ingredient.profile', (n,o) ->
      $scope.units = _($scope.combinedData[n]).map (h) -> h.fields.nf_serving_size_unit

    {
      dropdownCssClass: 'recipe-creation-ingredient'
      minimumInputLength: 3
      data: []
      ajax:
        url: "/admin/recipe/nutrient_profiles"
        data: (term) -> { term: term }
        quietMillis: 600
        results: (data) ->
          combinedData = _(data).groupBy (h) -> h.fields.item_name.split(' - ')[0]
          { results: _(combinedData).map (v,k) -> { id: k, text: k } }
    }

  $scope.ingredientHash = ->
    {
      dropdownCssClass: 'recipe-creation-ingredient'
      minimumInputLength: 3
      data: []
      ajax:
        url: "/admin/recipe/ingredients"
        data: (term) -> { term: term }
        quietMillis: 600
        results: (data) -> { results: _(data).map (h) -> { id: h.id, text: h.name } }
    }

  $scope.unitHash = ->
    {
      data: []
      dropdownCssClass: 'recipe-creation-unit'
      formatResultCssClass: -> 'recipe-creation-unit'
      formatSelection: (obj, con) -> obj.short
    }

  $scope.genHash = (hash) ->
    data = _($scope[hash]).map (h) -> { id: h.id, text: h.name }
    { multiple: true, tags: data, dropdownCssClass: 'recipe-creation-multi', formatResultCssClass: 'recipe-creation-multi' }


  $http.get('/admin/recipe/courses').success (courses) -> $scope.courses = courses
  $http.get('/admin/recipe/cuisines').success (cuisines) -> $scope.cuisines = cuisines
  #$http.get('/admin/recipe/units').success (units) -> $scope.units = units

  $scope.$watch 'yummly_url', (n,o) ->
    $scope.info = null
    if n && n.match(/yummly/)
      recipe_id = n.split('/')[n.split('/').length-1].split('?')[0]
      $http.get("/admin/recipe/info?recipe_id=#{recipe_id}").success (rsp) ->
        rsp.attributes.courses  = _(rsp.attributes.courses).map (c) -> { id: c, text: c }
        rsp.attributes.cuisines = _(rsp.attributes.cuisines).map (c) -> { id: c, text: c }
        $scope.info = rsp
        $timeout((->angular.element('.recipe .field.title img').attr 'src', $scope.info.images[0].hostedSmallUrl))
        $scope.info.ingredients = []
        _($scope.info.ingredientLines).each (line, i) ->
          $scope.info.ingredients[i] = {}
          $scope.info.ingredients[i].line = line
          $http.post('/admin/recipe/parse_line', { line: line }).success (rsp) ->
            $scope.info.ingredients[i].amount = rsp.amount
            $scope.info.ingredients[i].unit = rsp.unit
            $scope.info.ingredients[i].name = rsp.name

        null



app = angular.module('eatt', ['ngCookies', 'ui.select2'])#, 'ui.select2', 'ui.date', 'ui.mask'])
  .controller('app',          AppCtrl)
  .controller('home',         HomeCtrl)
  .controller('recipe_entry', RecipeEntry)
  .config ['$httpProvider', ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr 'content'
  ]

angular.element(document).on 'ready page:load', -> angular.bootstrap('body', ['eatt'])