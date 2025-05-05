class Macro extends App.ControllerSubContent
  @requiredPermission: 'admin.macro'
  header: __('Macros')
  constructor: ->
    super

    @genericController = new App.ControllerGenericIndex(
      el: @el
      id: @id
      genericObject: 'Macro'
      defaultSortBy: 'name'
      searchBar: true
      searchQuery: @search_query
      pageData:
        home: 'macros'
        object: __('Macro')
        objects: __('Macros')
        searchPlaceholder: __('Search for macros')
        pagerAjax: true
        pagerBaseUrl: '#manage/macros/'
        pagerSelected: ( @page || 1 )
        pagerPerPage: 50
        navupdate: '#macros'
        buttons: [
          { name: __('New Macro'), 'data-type': 'new', class: 'btn--success' }
        ]
      container: @el.closest('.content')
    )

  show: (params) =>
    for key, value of params
      if key isnt 'el' && key isnt 'shown' && key isnt 'match'
        @[key] = value

    @genericController.paginate(@page || 1, params)

App.Config.set('Macros', { prio: 2310, name: __('Macros'), parent: '#manage', target: '#manage/macros', controller: Macro, permission: ['admin.macro'] }, 'NavBarAdmin')
