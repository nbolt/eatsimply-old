AppCtrl = ['$scope', '$http', '$timeout', ($scope, $http, $timeout) ->
  $scope.modal = {}

  $scope.openModal = ->
    angular.element('#modal').css('display', 'block')
    $timeout(-> angular.element('#modal').css('opacity', 1))
    null

  $scope.openModalV = ->
    angular.element('#vegas-modal').css('display', 'block').css('opacity', 1)
    $timeout(-> angular.element('#vegas-modal').css('opacity', 1))
    null

  $scope.showEmail = ->
    angular.element('.go-button .icon, .go-button .text').css('opacity', 0)
    $timeout(
      (->
        angular.element('.go-button .icon, .go-button .text').css('display', 'none')
        angular.element('.go-button .button, .go-button input').css('display', 'block')
      ), 400
    )
    $timeout(
      (->
        angular.element('.go-button .button, .go-button input').css('opacity', 1)
      ), 500
    )

  $scope.openMealForm = ->
    $http.post(
      '/data/new_email',
      {
        email:
          email: $scope.email
      }
    ).success (rsp) ->
      if rsp.success
        angular.element('#modal').css('opacity', 0)
        angular.element('#meal-form').css('display', 'block')
        $.scrollTo('#meal-form', 800, 'swing')
        $timeout(-> angular.element('#meal-form').css('opacity', 1))
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
          email: $scope.vegas_email
          vegas: true
      }
    ).success (rsp) ->
      if rsp.success
        angular.element('#vegas-modal').css('opacity', 0)
        angular.element('#meal-form').css('display', 'block')
        $.scrollTo('#meal-form', 800, 'swing')
        $timeout(-> angular.element('#meal-form').css('opacity', 1))
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
      $timeout(-> angular.element('#meal-plan').css('opacity', 1))
      $timeout(->$.scrollTo('#meal-plan', 800, 'swing'))
]

HomeCtrl = ['$scope', '$http', ($scope, $http) ->


]

MealCtrl = ['$scope', '$http', ($scope, $http) ->

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
]


PlanCtrl = ['$scope', '$http', '$timeout', ($scope, $http, $timeout) ->

  $scope.shuffle = (day, meal) ->
    $http.post(
      '/data/new_recipes',
      {
        recipes: _(_(_($scope.days).map( (d) -> _(d.meals).map( (m) -> m.recipes ) )).flatten()).map (r) -> r.id
      }
    ).success (rsp) ->
      angular.element("##{day.name} .meal:eq(#{meal}) .recipes").css 'opacity', 0
      $timeout(
        (->
          day.meals[meal].recipes = rsp
          angular.element("##{day.name} .meal:eq(#{meal}) .recipes").css 'opacity', 1
        ), 400
      )
]

RecipeEntry = ['$scope', '$http', '$timeout', '$window', ($scope, $http, $timeout, $window) ->

  $scope.showRecipe = -> $scope.info && $scope.info.name

  $scope.nutriHash = (ingredient) ->
    {
      dropdownCssClass: 'recipe-creation-ingredient'
      minimumInputLength: 3
      data: []
      ajax:
        url: "/admin/recipe/nutritionix"
        data: (term) -> { term: term }
        quietMillis: 600
        results: (data) ->
          if (data && data[0])
            ingredient.combinedData = _(data).groupBy (h) -> h.fields.item_name.split(' - ')[0]
            { results: _(ingredient.combinedData).map (v,k) -> { id: k, text: k } }
    }

  $scope.unitHash = (ingredient) ->
    {
      dropdownCssClass: 'recipe-creation-unit'
      formatResultCssClass: -> 'recipe-creation-unit'
      formatSelection: (obj, con) -> obj.abbr
      minimumResultsForSearch: 10
      initSelection: (element, callback) ->
        if $(element).val()
          $http.get('/admin/recipe/unit?id=' + $(element).val()).success (unit) -> callback({id:unit.id,text:unit.name,abbr:unit.abbr})
      query: (query) -> query.callback({ results: ingredient.units })
    }

  $scope.genHash = (hash) ->
    {
      tags: []
      multiples: true
      dropdownCssClass: 'recipe-creation-multi'
      formatResultCssClass: -> 'recipe-creation-multi'
      query: (query) -> query.callback({ results: _($scope[hash]).map (h) -> { id: h.id, text: h.name } })
    }

  $scope.submit = ->
    $http.post('/admin/recipe/create', $scope.info).success (rsp) ->
      if rsp.success
        $window.location = "/admin/recipe/manage"

  $http.get('/admin/recipe/courses').success (courses) -> $scope.courses = courses
  $http.get('/admin/recipe/cuisines').success (cuisines) -> $scope.cuisines = cuisines
  $http.get('/admin/recipe/diets').success (diets) -> $scope.diets = diets
  $http.get('/admin/recipe/units').success (units) -> $scope.units = units

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
            $scope.info.ingredients[i].notes = $scope.info.ingredients[i].line
            $scope.info.ingredients[i].units = []
          $scope.$watch (-> $scope.info.ingredients[i].profile), (n,o) ->
            ingredient = $scope.info.ingredients[i]
            if ingredient.combinedData
              units = _(ingredient.combinedData[n.text]).map (h) -> h.fields.nf_serving_size_unit
              $http.post('/admin/recipe/unitData', { units: units }).success (rsp) ->
                ingredient.units = _(rsp).map (u) -> { id: u.name, text: u.name }
                angular.element("#i#{ingredient.$$hashKey} .field.unit .select2-container").select2('enable', true)

        null
]


app = angular.module('eatt', ['ngCookies', 'ui.select2'])
  .controller('app',           AppCtrl)
  .controller('meal',          MealCtrl)
  .controller('plan',          PlanCtrl)
  .controller('recipe_entry',  RecipeEntry)
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