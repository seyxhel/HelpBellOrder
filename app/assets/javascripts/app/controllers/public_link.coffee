class PublicLink extends App.ControllerSubContent
  @requiredPermission: 'admin.public_link'
  header: __('Public Links')
  constructor: ->
    super

    @genericController = new App.ControllerGenericIndex(
      el: @el
      id: @id
      genericObject: 'PublicLink'
      defaultSortBy: 'prio'
      searchBar: true
      searchQuery: @search_query
      pageData:
        home: 'public_links'
        object: __('Public Link')
        objects: __('Public Links')
        searchPlaceholder: __('Search for public links')
        pagerAjax: true
        pagerBaseUrl: '#manage/public_links/'
        pagerSelected: ( @page || 1 )
        pagerPerPage: 50
        navupdate: '#public_links'
        buttons: [
          { name: __('New Public Link'), 'data-type': 'new', class: 'btn--success' }
        ]
      container: @el.closest('.content')
      veryLarge: true
      dndCallback: (e, item) =>
        items = @el.find('table > tbody > tr')
        prios = []
        prio = 0
        for item in items
          prio += 1
          id = $(item).data('id')
          prios.push [id, prio]

        @ajax(
          id:          'public_links_prio'
          type:        'POST'
          url:         "#{@apiPath}/public_links_prio"
          processData: true
          data:        JSON.stringify(prios: prios)
        )
    )

  show: (params) =>
    for key, value of params
      if key isnt 'el' && key isnt 'shown' && key isnt 'match'
        @[key] = value

    @genericController.paginate(@page || 1, params)

App.Config.set('Public Links', { prio: 3325, name: __('Public Links'), parent: '#manage', target: '#manage/public_links', controller: PublicLink, permission: ['admin.public_links'] }, 'NavBarAdmin')
