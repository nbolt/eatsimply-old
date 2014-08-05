AppCtrl = ($scope, $http, $timeout) ->
  $scope.modal = {}

  $scope.openModal = ->
    angular.element('#modal').css('display', 'block')
    $timeout(->angular.element('#modal').css('opacity', 1))
    null

  $scope.openModalV = ->
    angular.element('#vegas-modal').css('display', 'block').css('opacity', 1)
    $timeout(->angular.element('#vegas-modal').css('opacity', 1))
    null

  $scope.openMealForm = ->
    $http.post(
      '/data/new_email',
      {
        email:
          email: $scope.modal.email
          zip: $scope.modal.zip
          comments: $scope.modal.comments
      }
    ).success (rsp) ->
      if rsp.success
        angular.element('#modal').css('opacity', 0)
        angular.element('#meal-form').css('display', 'block')
        $.scrollTo('#meal-form', 800, 'swing')
        $timeout(
          (->
            angular.element('#modal').css('display', 'none')
          ), 400
        )

  $scope.openMealFormV = ->
    $http.post(
      '/data/new_vegas_email',
      {
        email:
          email: $scope.modal.email
          zip: $scope.modal.zip
          comments: $scope.modal.comments
          vegas: true
      }
    ).success (rsp) ->
      if rsp.success
        angular.element('#vegas-modal').css('opacity', 0)
        angular.element('#meal-form').css('display', 'block')
        $.scrollTo('#meal-form', 800, 'swing')
        $timeout(
          (->
            angular.element('#vegas-modal').css('display', 'none')
          ), 400
        )

  $scope.openMealPlan = ->
    $http.post(
      '/data/recipes',
      {}
    ).success (rsp) ->
      $scope.days = rsp
      angular.element('#meal-plan').css('display', 'block')
      $timeout(->$.scrollTo('#meal-plan', 800, 'swing'))


HomeCtrl = ($http) ->


MealCtrl = ($scope, $http) ->

  $scope.form =
    weight: 180
    height: 180

  $scope.$watch 'form.diet', (n,o) ->
    if n && _(['a','e','i','o','u']).indexOf(n.text[0]) == -1
      angular.element('#aan').text "cm tall. I'm a"
    else
      angular.element('#aan').text "cm tall. I'm an"

  $scope.naturalHash = (hash) ->
    data =
      switch hash
        when 'gender'
          [{ id: 'm', text: 'male' }, { id: 'f', text: 'female' }]
        when 'diet'
          [{ id: 'omnivore', text: 'omnivore' }, { id: 'vegan', text: 'vegan' }, { id: 'pescatarian', text: 'pescatarian' }]
        when 'weight_goal'
          [{ id: 'maintain', text: 'maintain' }, { id: 'lose', text: 'lose' }, { id: 'gain', text: 'gain' }]

    {
      minimumResultsForSearch: 10
      dropdownCssClass: 'meal-plan-natural'
      data: data
      initSelection: (elem, cb) -> cb data[0]
    }

  $scope.multiHash = (hash) ->
    {
      multiple: true
      dropdownCssClass: 'meal-plan-classic'
      minimumInputLength: 3
      data: []
      ajax:
        url: "/data/#{hash}"
        data: (term) -> { term: term }
        quietMillis: 400
        results: (data) -> { results: _(data).map (i) -> { id: i.id, text: i.name } }
    }

PlanCtrl = ($scope, $http) ->

  #$http.get('/data/recipes').success (days) -> $scope.days = days


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
  .controller('meal',         MealCtrl)
  .controller('plan',         PlanCtrl)
  .config ['$httpProvider', ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr 'content'
  ]
  .directive('arrowNext', -> (scope, element) ->
    element.on 'click', ->
      if parseInt(angular.element('#meals').css('margin-left')) == -1340
        angular.element('.day:first').insertAfter '.day:last'
        angular.element('#meals').css 'margin-left', -1005
      angular.element('#meals').animate({
        'margin-left': '-=335'
      }, 400, 'swing')
  )
  .directive('arrowPrev', -> (scope, element) ->
    element.on 'click', ->
      if parseInt(angular.element('#meals').css('margin-left')) == 0
        angular.element('.day:last').insertBefore '.day:first'
        angular.element('#meals').css 'margin-left', -335
      angular.element('#meals').animate({
        'margin-left': '+=335'
      }, 400, 'swing')
  )

angular.element(document).on 'ready page:load', -> angular.bootstrap('body', ['eatt'])