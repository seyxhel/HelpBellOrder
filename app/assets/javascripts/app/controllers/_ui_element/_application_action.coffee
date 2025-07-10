# coffeelint: disable=camel_case_classes

###

UI Element options:

**attribute.notification**

- Allows to send notifications (default: false)

**attribute.ticket_delete**

- Allows to delete the ticket (default: false)

**attribute.user_action**

- Allows pre conditions like current_user.id or user session specific values (default: true)

**attribute.article_body_cc_only**

- Renders only article body and cc attributes (default: false)

**attribute.no_dates**

- Does not include `date` and `datetime` attributes (default: false)

**attribute.no_richtext_uploads**

- Removes support for uploads in richtext attributes (default: false)

**attribute.sender_type**

- Includes sender type as a ticket attribute (default: false)

**attribute.simple_attribute_selector**

- Renders a simpler attribute without operator support (default: false)

**attribute.skip_unknown_attributes**

- Skips rendering of unknown attributes (default: false)

###

class App.UiElement.ApplicationAction
  @defaults: (attribute, params = {}) ->
    defaults = ['ticket.state_id']

    groups =
      ticket:
        name: __('Ticket')
        model: 'Ticket'
      article:
        name: __('Article')
        model: if attribute.article_body_cc_only then 'TicketArticle' else 'Article'

    if attribute.notification
      groups.notification =
        name: __('Notification')
        model: 'Notification'

    if attribute.ai_agent
      groups.ai =
        name: __('AI')
        model: 'AI'

    # merge config
    elements = {}
    for groupKey, groupMeta of groups
      if !groupMeta.model || !App[groupMeta.model]
        switch groupKey
          when 'notification'
            elements["#{groupKey}.email"] = { name: 'email', display: __('Email') }
            elements["#{groupKey}.sms"] = { name: 'sms', display: __('SMS') }
            elements["#{groupKey}.webhook"] = { name: 'webhook', display: __('Webhook') }
          when 'article'
            elements["#{groupKey}.note"] = { name: 'note', display: __('Note') }
          when 'ai'
            elements["#{groupKey}.ai_agent"] = { name: 'ai_agent', display: __('AI Agent') }
      else
        for row in App[groupMeta.model].configure_attributes

          # ignore all article attributes except body and cc
          if attribute.article_body_cc_only
            if groupMeta.model is 'TicketArticle'
              if row.name isnt 'body' and row.name isnt 'cc'
                continue

          # ignore all date and datetime attributes
          if attribute.no_dates
            if row.tag is 'date' || row.tag is 'datetime'
              continue

          # ignore passwords and relations
          if row.type isnt 'password' && row.name.substr(row.name.length-4,4) isnt '_ids'

            # ignore readonly attributes
            if !row.readonly
              config = _.clone(row)

              config.objectName    = groupMeta.model
              config.attributeName = config.name

              # disable uploads in richtext attributes
              if attribute.no_richtext_uploads
                if config.tag is 'richtext'
                  config.upload = false

              switch config.tag
                when 'date'
                  config.operator = ['static', 'relative']
                when 'datetime'
                  config.operator = ['static', 'relative']
                when 'tag'
                  config.operator = ['add', 'remove']

              elements["#{groupKey}.#{config.name}"] = config

    # add ticket deletion action
    if attribute.ticket_delete
      elements['ticket.action'] =
        name: 'action'
        display: __('Action')
        tag: 'select'
        null: false
        translate: true
        options:
          delete: 'Delete'

    # add sender type selection as a ticket attribute
    if attribute.sender_type
      elements['ticket.formSenderType'] =
        name: 'formSenderType'
        display: __('Sender Type')
        tag: 'select'
        null: false
        translate: true
        options: [
          { value: 'phone-in', name: __('Inbound Call') },
          { value: 'phone-out', name: __('Outbound Call') },
          { value: 'email-out', name: __('Email') },
        ]

    if attribute.macro
      elements['ticket.subscribe'] =
        name: 'subscribe'
        display: __('Subscribe')
        tag: 'select'
        null: false
        translate: true
        options: [
          { value: 'current_user.id', name: __('current user') },
        ]

      elements['ticket.unsubscribe'] =
        name: 'unsubscribe'
        display: __('Unsubscribe')
        tag: 'select'
        null: false
        translate: true
        options: [
          { value: 'current_user.id', name: __('current user') },
        ]

    if attribute.trigger
      elements['ticket.subscribe'] =
        name: 'subscribe'
        display: __('Subscribe')
        tag: 'select'
        null: false
        translate: true
        permission: ['ticket.agent']
        relation: 'User'
        relation_condition: {roles: 'Agent'}

      elements['ticket.unsubscribe'] =
        name: 'unsubscribe'
        display: __('Unsubscribe')
        tag: 'select'
        null: true
        translate: true
        permission: ['ticket.agent']
        relation: 'User'
        relation_condition: {roles: 'Agent'}

    [defaults, groups, elements]

  @placeholder: (elementFull, attribute, params, groups, elements) ->
    item = $( App.view('generic/ticket_perform_action/row')( attribute: attribute ) )
    selector = @buildAttributeSelector(elementFull, groups, elements)
    item.find('.js-attributeSelector').prepend(selector)
    item

  @render: (attribute, params = {}) ->

    [defaults, groups, elements] = @defaults(attribute, params)

    # return item
    item = $( App.view('generic/ticket_perform_action/index')( attribute: attribute ) )

    # add filter
    item.on('click', '.js-rowActions .js-add', (e) =>
      element = $(e.target).closest('.js-filterElement')
      placeholder = @placeholder(item, attribute, params, groups, elements)
      if element.get(0)
        element.after(placeholder)
      else
        item.append(placeholder)
      placeholder.find('.js-attributeSelector select').trigger('change')
      @updateAttributeSelectors(item)
    )

    # remove filter
    item.on('click', '.js-rowActions .js-remove', (e) =>
      return if $(e.currentTarget).hasClass('is-disabled')
      elementRow = $(e.target).closest('.js-filterElement')
      @removeAlerts(item, elementRow)
      elementRow.remove()
      @updateAttributeSelectors(item)
    )

    # change attribute selector
    item.on('change', '.js-attributeSelector select', (e) =>
      elementRow = $(e.target).closest('.js-filterElement')
      groupAndAttribute = elementRow.find('.js-attributeSelector option:selected').attr('value')
      @rebuildAttributeSelectors(item, elementRow, groupAndAttribute, elements, {}, attribute)
      @updateAttributeSelectors(item)
      @refreshAlerts(item, elementRow, groupAndAttribute, elements, attribute)
    )

    # change operator selector
    item.on('change', '.js-operator select', (e) =>
      elementRow = $(e.target).closest('.js-filterElement')
      groupAndAttribute = elementRow.find('.js-attributeSelector option:selected').attr('value')
      @buildOperator(item, elementRow, groupAndAttribute, elements, {}, attribute)
    )

    # change value selector
    item.on('change', '.js-value select', (e) =>
      elementRow = $(e.target).closest('.js-filterElement')
      groupAndAttribute = elementRow.find('.js-attributeSelector option:selected').attr('value')
      @refreshAlerts(item, elementRow, groupAndAttribute, elements, attribute)
    )

    # build initial params
    if _.isEmpty(params[attribute.name])

      for groupAndAttribute in defaults

        # build and append
        element = @placeholder(item, attribute, params, groups, elements)
        item.append(element)
        @rebuildAttributeSelectors(item, element, groupAndAttribute, elements, {}, attribute)
        @refreshAlerts(item, element, groupAndAttribute, elements, attribute)

    else

      for groupAndAttribute, meta of params[attribute.name]
        # Skip unknown attributes.
        continue if attribute.skip_unknown_attributes and !_.includes(_.keys(elements), groupAndAttribute)

        # build and append
        element = @placeholder(item, attribute, params, groups, elements)
        @rebuildAttributeSelectors(item, element, groupAndAttribute, elements, meta, attribute)
        item.append(element)
        @refreshAlerts(item, element, groupAndAttribute, elements, attribute)

    @disableRemoveForOneAttribute(item)
    item

  @elementKeyGroup: (elementKey) ->
    elementKey.split(/\./)[0]

  @buildAttributeSelector: (elementFull, groups, elements) ->

    # find first possible attribute
    selectedValue = ''
    elementFull.find('.js-attributeSelector select option').each(->
      if !selectedValue && !$(@).prop('disabled')
        selectedValue = $(@).val()
    )

    selection = $('<select class="form-control"></select>')
    for groupKey, groupMeta of groups
      displayName = App.i18n.translateInline(groupMeta.name)
      selection.closest('select').append("<optgroup label=\"#{displayName}\" class=\"js-#{groupKey}\"></optgroup>")
      optgroup = selection.find("optgroup.js-#{groupKey}")
      for elementKey, elementGroup of elements
        elementGroup = @elementKeyGroup(elementKey)
        if elementGroup is groupKey
          attributeConfig = elements[elementKey]
          displayName = App.i18n.translateInline(attributeConfig.display)

          selected = ''
          if elementKey is selectedValue
            selected = 'selected="selected"'
          optgroup.append("<option value=\"#{elementKey}\" #{selected}>#{displayName}</option>")
    selection

  # disable - if we only have one attribute
  @disableRemoveForOneAttribute: (elementFull) ->
    if elementFull.find('.js-attributeSelector select').length > 1
      elementFull.find('.js-remove').removeClass('is-disabled')
    else
      elementFull.find('.js-remove').addClass('is-disabled')

  @updateAttributeSelectors: (elementFull) ->

    # enable all
    elementFull.find('.js-attributeSelector select option').prop('disabled', false)

    # disable all used attributes
    elementFull.find('.js-attributeSelector select').each(->
      keyLocal = $(@).val()
      elementFull.find('.js-attributeSelector select option[value="' + keyLocal + '"]').attr('disabled', true)
    )

    # disable - if we only have one attribute
    @disableRemoveForOneAttribute(elementFull)

  @rebuildAttributeSelectors: (elementFull, elementRow, groupAndAttribute, elements, meta, attribute) ->

    # set attribute
    if groupAndAttribute
      elementRow.find('.js-attributeSelector select').val(groupAndAttribute)

    groupAndTypeMatch = groupAndAttribute.match(/^([\w]+)\.([\w]+)$/) || []

    for elem in ['Notification', 'Attribute', 'Article', 'AI']
      if groupAndTypeMatch[1] isnt elem.toLowerCase()
        elementRow.find(".js-set#{elem}").html('').addClass('hide')

    if groupAndTypeMatch[1] == 'notification'
      @buildNotificationArea(groupAndTypeMatch[2], elementFull, elementRow, groupAndAttribute, elements, meta, attribute)
    else if groupAndTypeMatch[1] == 'ai'
      @buildAIArea(groupAndTypeMatch[2], elementFull, elementRow, groupAndAttribute, elements, meta, attribute)
    else if groupAndTypeMatch[1] == 'article' && !attribute.article_body_cc_only
      @buildArticleArea(groupAndTypeMatch[2], elementFull, elementRow, groupAndAttribute, elements, meta, attribute)
    else
      if !elementRow.find('.js-setAttribute div').get(0)
        attributeSelectorElement = $( App.view('generic/ticket_perform_action/attribute_selector')(
          attribute: attribute
          name: name
          meta: meta || {}
        ))
        elementRow.find('.js-setAttribute').html(attributeSelectorElement).removeClass('hide')

    if attribute.simple_attribute_selector
      @buildValue(elementFull, elementRow, groupAndAttribute, elements, meta, attribute)
    else
      @buildOperator(elementFull, elementRow, groupAndAttribute, elements, meta, attribute)

  @buildOperator: (elementFull, elementRow, groupAndAttribute, elements, meta, attribute) ->
    currentOperator = elementRow.find('.js-operator option:selected').attr('value')

    if !meta.operator
      meta.operator = currentOperator

    name = "#{attribute.name}::#{groupAndAttribute}::operator"

    selection = $("<select class=\"form-control\" name=\"#{name}\"></select>")
    attributeConfig = elements[groupAndAttribute]
    if !attributeConfig || !attributeConfig.operator
      elementRow.find('.js-operator').parent().addClass('hide')
    else
      elementRow.find('.js-operator').parent().removeClass('hide')
    if attributeConfig && attributeConfig.operator
      for operator in attributeConfig.operator
        operatorName = App.i18n.translateInline(operator)
        selected = ''
        if meta.operator is operator
          selected = 'selected="selected"'
        selection.append("<option value=\"#{operator}\" #{selected}>#{operatorName}</option>")
      selection

    elementRow.find('.js-operator select').replaceWith(selection)

    @buildPreCondition(elementFull, elementRow, groupAndAttribute, elements, meta, attribute)

  @buildPreCondition: (elementFull, elementRow, groupAndAttribute, elements, meta, attributeConfig) ->
    currentOperator = elementRow.find('.js-operator option:selected').attr('value')
    currentPreCondition = elementRow.find('.js-preCondition option:selected').attr('value')

    if !meta.pre_condition
      meta.pre_condition = currentPreCondition

    toggleValue = =>
      preCondition = elementRow.find('.js-preCondition option:selected').attr('value')
      if preCondition isnt 'specific'
        elementRow.find('.js-value select').html('')
        elementRow.find('.js-value').addClass('hide')
      else
        elementRow.find('.js-value').removeClass('hide')
        @buildValue(elementFull, elementRow, groupAndAttribute, elements, meta, attribute)

    # force to use auto complition on user lookup
    attribute = clone(attributeConfig, true)

    name = "#{attribute.name}::#{groupAndAttribute}::value"
    attributeSelected = elements[groupAndAttribute]

    preCondition = false
    if attributeSelected?.relation is 'User'
      preCondition = 'user'
      attribute.tag = 'user_autocompletion'
    if attributeSelected?.relation is 'Organization'
      preCondition = 'org'
      attribute.tag = 'autocompletion_ajax'
    if !preCondition || attribute.user_action is false
      elementRow.find('.js-preCondition select').html('')
      elementRow.find('.js-preCondition').closest('.controls').addClass('hide')
      toggleValue()
      @buildValue(elementFull, elementRow, groupAndAttribute, elements, meta, attribute)
      return

    elementRow.find('.js-preCondition').closest('.controls').removeClass('hide')
    name = "#{attribute.name}::#{groupAndAttribute}::pre_condition"

    selection = $("<select class=\"form-control\" name=\"#{name}\" ></select>")
    options = {}
    if preCondition is 'user'
      options =
        'current_user.id': App.i18n.translateInline('current user')
        'specific': App.i18n.translateInline('specific user')

      if attributeSelected.null is true
        options['not_set'] = if groupAndAttribute == 'ticket.unsubscribe'
          App.i18n.translateInline('all subscribers')
        else
          App.i18n.translateInline('unassign user')

    else if preCondition is 'org'
      options =
        'current_user.organization_id': App.i18n.translateInline('current user organization')
        'specific': App.i18n.translateInline('specific organization')

    for key, value of options
      selected = ''
      if key is meta.pre_condition
        selected = 'selected="selected"'
      selection.append("<option value=\"#{key}\" #{selected}>#{App.i18n.translateInline(value)}</option>")
    elementRow.find('.js-preCondition').closest('.controls').removeClass('hide')
    elementRow.find('.js-preCondition select').replaceWith(selection)

    elementRow.find('.js-preCondition select').on('change', (e) ->
      toggleValue()
    )

    @buildValue(elementFull, elementRow, groupAndAttribute, elements, meta, attribute)
    toggleValue()

  @buildValue: (elementFull, elementRow, groupAndAttribute, elements, meta, attribute) ->
    name = "#{attribute.name}::#{groupAndAttribute}::value"

    # build new item
    attributeConfig = elements[groupAndAttribute]
    config = clone(attributeConfig, true)

    if config?.relation is 'User'
      config.tag = 'user_autocompletion'
      config.disableCreateObject = true
    if config?.relation is 'Organization'
      config.tag = 'autocompletion_ajax'

    # render ui element
    item = ''
    if config && App.UiElement[config.tag]
      config['name'] = name
      if attribute.value && attribute.value[groupAndAttribute]
        config['value'] = _.clone(attribute.value[groupAndAttribute]['value'])
      config.multiple = false
      config.default = undefined
      config.nulloption = config.null
      if config.tag is 'multiselect' || config.tag is 'multi_tree_select'
        config.multiple = true
      if config.tag is 'checkbox'
        config.tag = 'select'
      if config.tag is 'datetime'
        config.validationContainer = 'self'
      item = App.UiElement[config.tag].render(config, {})

    relative_operators = [
      __('before (relative)'),
      __('within next (relative)'),
      __('within last (relative)'),
      __('after (relative)'),
      __('till (relative)'),
      __('from (relative)'),
      __('relative'),
    ]

    upcoming_operator = meta?.operator

    if !_.include(config?.operator, upcoming_operator)
      if Array.isArray(config?.operator)
        upcoming_operator = config.operator[0]
      else
        upcoming_operator = null

    if _.include(relative_operators, upcoming_operator)
      config['name'] = "#{attribute.name}::#{groupAndAttribute}"
      if attribute.value && attribute.value[groupAndAttribute]
        config['value'] = _.clone(attribute.value[groupAndAttribute])
      item = App.UiElement['time_range'].render(config, {})

    elementRow.find('.js-setAttribute > .flex > .js-value').removeClass('hide').html(item)

  @recpientVariables: ->
    {
      'article_last_sender': __('Sender of last article')
      'ticket_owner': __('Owner')
      'ticket_customer': __('Customer')
      'ticket_agents': __('All agents')
    }

  @buildNotificationArea: (notificationType, elementFull, elementRow, groupAndAttribute, elements, meta, attribute) ->

    return if elementRow.find(".js-setNotification .js-body-#{notificationType}").get(0)

    elementRow.find('.js-setNotification').empty()

    name = "#{attribute.name}::notification.#{notificationType}"

    messageLength = switch notificationType
      when 'sms' then 160
      else 200000

    # meta.recipient was a string in the past (single-select) so we convert it to array if needed
    if !_.isArray(meta.recipient)
      meta.recipient = [meta.recipient]

    columnSelectOptions = []
    for key, value of @recpientVariables()
      selected = undefined
      for recipient in meta.recipient
        if key is recipient
          selected = true
      columnSelectOptions.push({ value: key, name: App.i18n.translatePlain(value), selected: selected })

    columnSelectRecipientUserOptions = []
    for user in App.User.all()
      key = "userid_#{user.id}"
      selected = undefined
      for recipient in meta.recipient
        if key is recipient
          selected = true
      columnSelectRecipientUserOptions.push({ value: key, name: "#{user.firstname} #{user.lastname}", selected: selected })

    columnSelectRecipient = new App.ColumnSelect
      attribute:
        name:    "#{name}::recipient"
        options: [
          {
            label: __('Variables'),
            group: columnSelectOptions
          },
          {
            label: __('User'),
            group: columnSelectRecipientUserOptions
          },
        ]

    selectionRecipient = columnSelectRecipient.element()

    if notificationType is 'webhook'
      notificationElement = $( App.view('generic/ticket_perform_action/webhook')(
        attribute: attribute
        name: name
        notificationType: notificationType
        meta: meta || {}
      ))

      notificationElement.find('.js-recipient select').replaceWith(selectionRecipient)

      if App.Webhook.search(filter: { active: true }).length isnt 0 || !_.isEmpty(meta.webhook_id)
        webhookSelection = App.UiElement.select.render(
          name: "#{name}::webhook_id"
          multiple: false
          null: false
          relation: 'Webhook'
          value: meta.webhook_id
          translate: false
          nulloption: true
        )
      else
        webhookSelection = App.view('generic/ticket_perform_action/webhook_not_available')( attribute: attribute )

      notificationElement.find('.js-webhooks').html(webhookSelection)

    else
      notificationElement = $( App.view('generic/ticket_perform_action/notification')(
        attribute: attribute
        name: name
        notificationType: notificationType
        meta: meta || {}
      ))

      notificationElement.find('.js-recipient select').replaceWith(selectionRecipient)

      visibilitySelection = App.UiElement.select.render(
        name: "#{name}::internal"
        multiple: false
        null: false
        options: { true: __('internal'), false: __('public') }
        value: meta.internal || 'false'
        translate: true
      )

      includeAttachmentsCheckbox = App.UiElement.select.render(
        name: "#{name}::include_attachments"
        multiple: false
        null: false
        options: { true: __('Yes'), false: __('No') }
        value: meta.include_attachments || 'false'
        translate: true
      )

      notificationElement.find('.js-internal').html(visibilitySelection)
      notificationElement.find('.js-include_attachments').html(includeAttachmentsCheckbox)

      notificationElement.find('.js-body div[contenteditable="true"]').ce(
        mode: 'richtext'
        placeholder: __('message')
        maxlength: messageLength
      )
      new App.WidgetPlaceholder(
        el: notificationElement.find('.js-body div[contenteditable="true"]').parent()
        objects: [
          {
            prefix: 'ticket'
            object: 'Ticket'
            display: __('Ticket')
          },
          {
            prefix: 'article'
            object: 'TicketArticle'
            display: __('Article')
          },
          {
            prefix: 'user'
            object: 'User'
            display: __('Current User')
          },
        ]
      )

    elementRow.find('.js-setNotification').html(notificationElement).removeClass('hide')

    if App.Config.get('smime_integration') == true || App.Config.get('pgp_integration') == true
      selection = App.UiElement.select.render(
        name: "#{name}::sign"
        multiple: false
        options: {
          'no': __('Do not sign email')
          'discard': __('Sign email (if not possible, discard notification)')
          'always': __('Sign email (if not possible, send notification anyway)')
        }
        value: meta.sign
        translate: true
      )

      elementRow.find('.js-sign').html(selection)

      selection = App.UiElement.select.render(
        name: "#{name}::encryption"
        multiple: false
        options: {
          'no': __('Do not encrypt email')
          'discard': __('Encrypt email (if not possible, discard notification)')
          'always': __('Encrypt email (if not possible, send notification anyway)')
        }
        value: meta.encryption
        translate: true
      )

      elementRow.find('.js-encryption').html(selection)

  @buildAIArea: (aiType, elementFull, elementRow, groupAndAttribute, elements, meta, attribute) ->
    elementRow.find('.js-setAI').empty()

    name = "#{attribute.name}::ai.ai_agent"

    aiElement = $( App.view('generic/ticket_perform_action/ai_agent')(
      attribute: attribute
      name: name
      meta: meta || {}
    ))

    aiAgentSelection = if App.AIAgent.search(filter: { active: true }).length isnt 0 || !_.isEmpty(meta.ai_agent_id)
      App.UiElement.select.render(
        name: "#{name}::ai_agent_id"
        multiple: false
        null: false
        relation: 'AIAgent'
        value: meta.ai_agent_id
        translate: false
        nulloption: true
      )
    else
      App.view('generic/ticket_perform_action/ai_agent_not_available')( attribute: attribute )

    aiElement.find('.js-ai-agents').html(aiAgentSelection)

    elementRow.find('.js-setAI').html(aiElement).removeClass('hide')

  @buildArticleArea: (articleType, elementFull, elementRow, groupAndAttribute, elements, meta, attribute) ->

    return if elementRow.find(".js-setArticle .js-body-#{articleType}").get(0)

    elementRow.find('.js-setArticle').empty()

    name = "#{attribute.name}::article.#{articleType}"
    selection = App.UiElement.select.render(
      name: "#{name}::internal"
      multiple: false
      null: false
      label: __('Visibility')
      options: { true: 'internal', false: 'public' }
      value: meta.internal
      translate: true
    )
    articleElement = $( App.view('generic/ticket_perform_action/article')(
      attribute: attribute
      name: name
      articleType: articleType
      meta: meta || {}
    ))
    articleElement.find('.js-internal').html(selection)
    articleElement.find('.js-body div[contenteditable="true"]').ce(
      mode: 'richtext'
      placeholder: __('message')
      maxlength: 200000
    )
    new App.WidgetPlaceholder(
      el: articleElement.find('.js-body div[contenteditable="true"]').parent()
      objects: [
        {
          prefix: 'ticket'
          object: 'Ticket'
          display: __('Ticket')
        },
        {
          prefix: 'article'
          object: 'TicketArticle'
          display: __('Article')
        },
        {
          prefix: 'user'
          object: 'User'
          display: __('Current User')
        },
      ]
    )

    elementRow.find('.js-setArticle').html(articleElement).removeClass('hide')

  @refreshAlerts: (item, elementRow, groupAndAttribute, elements, attribute) =>
    @removeAlerts(item, elementRow)

    params = App.ControllerForm.params(elementRow)
    return if not params

    { value } = params[attribute.name]?[groupAndAttribute]
    return if not value

    { alerts } = elements[groupAndAttribute]
    return if not alerts?[value]

    message = alerts[value]
    return if not message

    # We need a reference to the parent row, since its attribute may be changed to something else.
    #   In this case, we will clean up all alerts tied to this row only.
    if not elementRow.data('id')
      elementRowId = 'elementRow-' + new Date().getTime() + '-' + Math.floor(Math.random() * 999999)
      elementRow.data('id', elementRowId)

    $('<div />')
      .addClass('alert alert--warning js-alert')
      .attr('role', 'alert')
      .attr('data-element-row-id', elementRow.data('id'))
      .text(App.i18n.translatePlain(message))
      .prependTo(item)

  @removeAlerts: (item, elementRow) ->
    item.find(".js-alert[data-element-row-id='#{elementRow.data('id')}']")
      .remove()
